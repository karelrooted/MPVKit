import CoreMedia
import Foundation
import LibMPV
import Logging
import QuartzCore

#if !os(macOS)
    import UIKit
#endif

public class MPVClient: ObservableObject {
    static var logFile: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("mpvkit-mpv-log.txt")
    }

    private var logger = Logger(label: "mpv-client")

    var mpv: OpaquePointer!
    var queue: DispatchQueue!
    var metalLayer = CAMetalLayer()

    var seeking = false
    var loadedVideo = false
    var isLoadingVideo = true

    var isPlaying = true
    var enableLogging = true
    private var onFileLoaded: (() -> Void)?

    func create(frame: CGRect? = nil) {
        mpv = mpv_create()
        if mpv == nil {
            print("failed creating context\n")
            exit(1)
        }

        if enableLogging {
            checkError(mpv_set_option_string(
                mpv,
                "log-file",
                Self.logFile.absoluteString.replacingOccurrences(of: "file://", with: "")
            ))
            checkError(mpv_request_log_messages(mpv, "debug"))
        } else {
            #if DEBUG
                checkError(mpv_request_log_messages(mpv, "debug"))
            #else
                checkError(mpv_request_log_messages(mpv, "no"))
            #endif
        }

        #if os(macOS)
            checkError(mpv_set_option_string(mpv, "input-media-keys", "yes"))
        #endif
        checkError(mpv_set_option_string(mpv, "sub-fonts-dir", Bundle.main.bundleURL.path + "/fonts"))
        checkError(mpv_set_option_string(mpv, "sub-font", "SF Pro"))
        checkError(mpv_set_option_string(mpv, "cache-pause-initial", "yes"))
        checkError(mpv_set_option_string(mpv, "cache-secs", "120"))
        checkError(mpv_set_option_string(mpv, "cache-pause-wait", "3"))
        checkError(mpv_set_option_string(mpv, "keep-open", "yes"))
        // checkError(mpv_set_option_string(mpv, "hwdec", machine == "x86_64" ? "no" : "auto-safe"))

        metalLayer.frame = frame!
        #if !os(macOS)
            metalLayer.contentsScale = UIScreen.main.nativeScale
        #endif
        // metalLayer.wantsExtendedDynamicRangeContent = true
        // metalLayer.pixelFormat = .rgba16Float
        // metalLayer.isOpaque = true
        // metalLayer.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearITUR_2020)
        // metalLayer.edrMetadata = .hdr10(minLuminance: 0.5, maxLuminance: 1000, opticalOutputScale: 100)
        metalLayer.device = MTLCreateSystemDefaultDevice()!
        metalLayer.framebufferOnly = true
        //        metalLayer.displaySyncEnabled = false
        mpv_set_option(mpv, "wid", MPV_FORMAT_INT64, &metalLayer)

        mpv_set_property_string(mpv, "vo", "gpu-next")
        mpv_set_property_string(mpv, "gpu-api", "vulkan")
        mpv_set_property_string(mpv, "gpu-context", "moltenvk")
        mpv_set_property_string(mpv, "hwdec", "videotoolbox")

        checkError(mpv_set_option_string(mpv, "slang", "eng,chi"))
        // checkError(mpv_set_option_string(mpv, "dither-depth", "auto"));
        // checkError(mpv_set_option_string(mpv, "hwdec-codecs", "all"));
        // checkError(mpv_set_option_string(mpv, "gpu-hwdec-interop", "auto"));
        checkError(mpv_set_option_string(mpv, "demuxer-lavf-analyzeduration", "1"))

        checkError(mpv_initialize(mpv))

        queue = DispatchQueue(label: "mpv")

        mpv_set_wakeup_callback(mpv, wakeUp, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_FLAG)
        mpv_observe_property(mpv, 0, "core-idle", MPV_FORMAT_FLAG)
        // command("script-binding", args: ["stats/display-stats-toggle"])
    }

    func readEvents() {
        queue?.async { [self] in
            while self.mpv != nil {
                let event = mpv_wait_event(self.mpv, 0)
                if event!.pointee.event_id == MPV_EVENT_NONE {
                    break
                }
                handle(event)
            }
        }
    }

    func loadFile(
        _ url: URL,
        audio: URL? = nil,
        sub: URL? = nil,
        time: CMTime? = nil,
        forceSeekable: Bool = false,
        completionHandler: ((Int32) -> Void)? = nil
    ) {
        var args = [url.absoluteString]
        var options = [String]()

        args.append("replace")

        if let time, time.seconds > 0 {
            options.append("start=\(Int(time.seconds))")
        }

        if let audioURL = audio?.absoluteString {
            options.append("audio-files-append=\"\(audioURL)\"")
        }

        if let subURL = sub?.absoluteString {
            options.append("sub-files-append=\"\(subURL)\"")
        }

        if forceSeekable {
            options.append("force-seekable=yes")
            // this is needed for peertube?
            // options.append("stream-lavf-o=seekable=0")
        }

        if !options.isEmpty {
            args.append(options.joined(separator: ","))
        }

        command("loadfile", args: args, returnValueCallback: completionHandler)
    }

    func play() {
        isPlaying = true
        setFlagAsync("pause", false)
    }

    func pause() {
        isPlaying = false
        setFlagAsync("pause", true)
    }

    func togglePlay() {
        isPlaying = isPlaying ? false : true
        command("cycle", args: ["pause"])
    }

    func stop() {
        command("stop")
    }

    var currentTime: CMTime {
        CMTime.secondsInDefaultTimescale(mpv == nil ? -1 : getDouble("time-pos"))
    }

    var frameDropCount: Int {
        mpv == nil ? 0 : getInt("frame-drop-count")
    }

    var outputFps: Double {
        mpv == nil ? 0.0 : getDouble("estimated-vf-fps")
    }

    var hwDecoder: String {
        mpv == nil ? "unknown" : getString("hwdec-current") ?? "unknown"
    }

    var bufferingState: Double {
        mpv == nil ? 0.0 : getDouble("cache-buffering-state")
    }

    var cacheDuration: Double {
        mpv == nil ? 0.0 : getDouble("demuxer-cache-duration")
    }

    var videoFormat: String {
        stringOrUnknown("video-format")
    }

    var videoCodec: String {
        stringOrUnknown("video-codec")
    }

    var currentVo: String {
        stringOrUnknown("current-vo")
    }

    var width: String {
        stringOrUnknown("width")
    }

    var height: String {
        stringOrUnknown("height")
    }

    var videoBitrate: Double {
        mpv == nil ? 0.0 : getDouble("video-bitrate")
    }

    var audioFormat: String {
        stringOrUnknown("audio-params/format")
    }

    var audioCodec: String {
        stringOrUnknown("audio-codec")
    }

    var currentAo: String {
        stringOrUnknown("current-ao")
    }

    var audioChannels: String {
        stringOrUnknown("audio-params/channels")
    }

    var audioSampleRate: String {
        stringOrUnknown("audio-params/samplerate")
    }

    var aspectRatio: Double {
        guard mpv != nil else { return MPVVideoPlayer.defaultAspectRatio }
        let aspect = getDouble("video-params/aspect")
        return aspect.isZero ? MPVVideoPlayer.defaultAspectRatio : aspect
    }

    var dh: Double {
        let defaultDh = 500.0
        guard mpv != nil else { return defaultDh }

        let dh = getDouble("video-params/dh")
        return dh.isZero ? defaultDh : dh
    }

    var duration: CMTime {
        CMTime.secondsInDefaultTimescale(mpv == nil ? -1 : getDouble("duration"))
    }

    var pausedForCache: Bool {
        mpv == nil ? false : getFlag("paused-for-cache")
    }

    var eofReached: Bool {
        mpv == nil ? false : getFlag("eof-reached")
    }

    func seek(relative time: CMTime, completionHandler: ((Bool) -> Void)? = nil) {
        guard !seeking else {
            logger.warning("ignoring seek, another in progress")
            return
        }

        seeking = true
        command("seek", args: [String(time.seconds)]) { [weak self] _ in
            self?.seeking = false
            completionHandler?(true)
        }
    }

    func seek(to time: CMTime, completionHandler: ((Bool) -> Void)? = nil) {
        guard !seeking else {
            logger.warning("ignoring seek, another in progress")
            return
        }

        seeking = true
        command("seek", args: [String(time.seconds), "absolute"]) { [weak self] _ in
            self?.seeking = false
            completionHandler?(true)
        }
    }

    func handle(_ event: UnsafePointer<mpv_event>!) {
        logger.info(.init(stringLiteral: "RECEIVED  event: \(String(cString: mpv_event_name(event.pointee.event_id)))"))

        switch event.pointee.event_id {
        case MPV_EVENT_SHUTDOWN:
            mpv_destroy(mpv)
            mpv = nil

        case MPV_EVENT_LOG_MESSAGE:
            let logmsg = UnsafeMutablePointer<mpv_event_log_message>(OpaquePointer(event.pointee.data))
            logger.info(.init(stringLiteral: "\(String(cString: (logmsg!.pointee.prefix)!)), "
                    + "\(String(cString: (logmsg!.pointee.level)!)), "
                    + "\(String(cString: (logmsg!.pointee.text)!))"))

        case MPV_EVENT_FILE_LOADED:
            onFileLoaded?()
            startClientUpdates()
            onFileLoaded = nil

        case MPV_EVENT_PROPERTY_CHANGE:
            let dataOpaquePtr = OpaquePointer(event.pointee.data)
            if let property = UnsafePointer<mpv_event_property>(dataOpaquePtr)?.pointee {
                let propertyName = String(cString: property.name)
                handlePropertyChange(propertyName, property)
            }

        case MPV_EVENT_PLAYBACK_RESTART:
            isLoadingVideo = false
            seeking = false

            onFileLoaded?()
            startClientUpdates()
            onFileLoaded = nil

        case MPV_EVENT_VIDEO_RECONFIG:
            updateAspectRatio()

        case MPV_EVENT_SEEK:
            seeking = true

        case MPV_EVENT_END_FILE:
            let reason = event!.pointee.data.load(as: mpv_end_file_reason.self)

            if reason != MPV_END_FILE_REASON_STOP {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.close(finished: true)
                    self.getTimeUpdates()
                    self.eofPlaybackModeAction()
                }
            } else {
                DispatchQueue.main.async { [weak self] in self?.handleEndOfFile() }
            }

        default:
            logger.info(.init(stringLiteral: "UNHANDLED event: \(String(cString: mpv_event_name(event.pointee.event_id)))"))
        }
    }

    func command(
        _ command: String,
        args: [String?] = [],
        checkForErrors: Bool = true,
        returnValueCallback: ((Int32) -> Void)? = nil
    ) {
        guard mpv != nil else {
            return
        }
        var cargs = makeCArgs(command, args).map { $0.flatMap { UnsafePointer<CChar>(strdup($0)) } }
        defer {
            for ptr in cargs where ptr != nil {
                free(UnsafeMutablePointer(mutating: ptr!))
            }
        }
        logger.info("\(command) -- \(args)")
        let returnValue = mpv_command(mpv, &cargs)
        if checkForErrors {
            checkError(returnValue)
        }
        if let cb = returnValueCallback {
            cb(returnValue)
        }
    }

    func addVideoTrack(_ url: URL) {
        command("video-add", args: [url.absoluteString])
    }

    func addSubTrack(_ url: URL) {
        command("sub-add", args: [url.absoluteString])
    }

    func removeSubs() {
        command("sub-remove")
    }

    func setVideoToAuto() {
        setString("video", "1")
    }

    func setVideoToNo() {
        setString("video", "no")
    }

    var tracksCount: Int {
        Int(getString("track-list/count") ?? "-1") ?? -1
    }

    private func getFlag(_ name: String) -> Bool {
        var data = Int64()
        mpv_get_property(mpv, name, MPV_FORMAT_FLAG, &data)
        return data > 0
    }

    private func setFlagAsync(_ name: String, _ flag: Bool) {
        guard mpv != nil else { return }
        var data: Int = flag ? 1 : 0
        mpv_set_property_async(mpv, 0, name, MPV_FORMAT_FLAG, &data)
    }

    func setDoubleAsync(_ name: String, _ value: Double) {
        guard mpv != nil else { return }
        var data = value
        mpv_set_property_async(mpv, 0, name, MPV_FORMAT_DOUBLE, &data)
    }

    private func getDouble(_ name: String) -> Double {
        guard mpv != nil else { return 0.0 }
        var data = Double()
        mpv_get_property(mpv, name, MPV_FORMAT_DOUBLE, &data)
        return data
    }

    private func getInt(_ name: String) -> Int {
        guard mpv != nil else { return 0 }
        var data = Int64()
        mpv_get_property(mpv, name, MPV_FORMAT_INT64, &data)
        return Int(data)
    }

    func getString(_ name: String) -> String? {
        guard mpv != nil else { return nil }
        let cstr = mpv_get_property_string(mpv, name)
        let str: String? = cstr == nil ? nil : String(cString: cstr!)
        mpv_free(cstr)
        return str
    }

    private func setString(_ name: String, _ value: String) {
        guard mpv != nil else { return }
        mpv_set_property_string(mpv, name, value)
    }

    private func makeCArgs(_ command: String, _ args: [String?]) -> [String?] {
        if !args.isEmpty, args.last == nil {
            fatalError("Command do not need a nil suffix")
        }

        var strArgs = args
        strArgs.insert(command, at: 0)
        strArgs.append(nil)

        return strArgs
    }

    private func checkError(_ status: CInt) {
        if status < 0 {
            logger.error(.init(stringLiteral: "MPV API error: \(String(cString: mpv_error_string(status)))\n"))
        }
    }

    private func stringOrUnknown(_ name: String) -> String {
        mpv == nil ? "unknown" : (getString(name) ?? "unknown")
    }

    private var machine: String {
        var systeminfo = utsname()
        uname(&systeminfo)
        return withUnsafeBytes(of: &systeminfo.machine) { bufPtr -> String in
            let data = Data(bufPtr)
            if let lastIndex = data.lastIndex(where: { $0 != 0 }) {
                return String(data: data[0 ... lastIndex], encoding: .isoLatin1)!
            }
            return String(data: data, encoding: .isoLatin1)!
        }
    }

    private func handlePropertyChange(_ name: String, _ property: mpv_event_property) {
        switch name {
        case "pause":
            if let paused = UnsafePointer<Bool>(OpaquePointer(property.data))?.pointee {
                if paused {
                    DispatchQueue.main.async { [weak self] in self?.handleEndOfFile() }
                } else {
                    isLoadingVideo = false
                    seeking = false
                }
                isPlaying = !paused
            }
        case "core-idle":
            if let idle = UnsafePointer<Bool>(OpaquePointer(property.data))?.pointee {
                if !idle {
                    isLoadingVideo = false
                    seeking = false
                }
            }
        default:
            logger.info("MPV backend received unhandled property: \(name)")
        }
    }

    func handleEndOfFile() {
        guard eofReached else {
            return
        }

        // getTimeUpdates()
        // eofPlaybackModeAction()
    }

    func startClientUpdates() {
        // clientTimer.start()
    }

    func updateAspectRatio() {
        // updateAspectRatio()
    }

    func getTimeUpdates() {}

    func eofPlaybackModeAction() {}

    func close(finished: Bool = true) {
        pause()
        stop()
    }
}

private func wakeUp(_ context: UnsafeMutableRawPointer?) {
    let client = unsafeBitCast(context, to: MPVClient.self)
    client.readEvents()
}
