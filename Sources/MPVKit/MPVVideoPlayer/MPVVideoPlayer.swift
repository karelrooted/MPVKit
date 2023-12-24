import Combine
import Foundation
import SwiftUI

#if !os(macOS)
import UIKit

final class MPVViewController: UIViewController {
    private var configuration: MPVVideoPlayer.Configuration
    private var proxy: MPVVideoPlayer.Proxy?
    private let onTicksUpdated: (Int, MPVVideoPlayer.PlaybackInformation) -> Void
    private let onStateUpdated: (MPVVideoPlayer.State, MPVVideoPlayer.PlaybackInformation) -> Void
    private let loggingInfo: (logger: MPVVideoPlayerLogger, level: MPVVideoPlayer.LoggingLevel)?
    private var currentMediaPlayer: MPVMediaPlayer
    init(
        configuration: MPVVideoPlayer.Configuration,
        proxy: MPVVideoPlayer.Proxy?,
        onTicksUpdated: @escaping (Int, MPVVideoPlayer.PlaybackInformation) -> Void,
        onStateUpdated: @escaping (MPVVideoPlayer.State, MPVVideoPlayer.PlaybackInformation) -> Void,
        loggingInfo: (MPVVideoPlayerLogger, MPVVideoPlayer.LoggingLevel)?
    ) {
        self.configuration = configuration
        self.proxy = proxy
        self.onTicksUpdated = onTicksUpdated
        self.onStateUpdated = onStateUpdated
        self.loggingInfo = loggingInfo
        self.currentMediaPlayer = MPVMediaPlayer(
            configuration: configuration,
            onTicksUpdated: onTicksUpdated,
            onStateUpdated: onStateUpdated,
            loggingInfo: loggingInfo
        )
        self.proxy?.mediaPlayer = currentMediaPlayer
        // self.proxy?.videoPlayerView = self
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.configuration = MPVVideoPlayer.Configuration(url: URL(string: "http://test")!)
        self.onTicksUpdated = { _, _ in
        }
        self.onStateUpdated = { _, _ in
        }
        self.loggingInfo = nil
        self.currentMediaPlayer = MPVMediaPlayer(
            configuration: configuration,
            onTicksUpdated: onTicksUpdated,
            onStateUpdated: onStateUpdated,
            loggingInfo: loggingInfo
        )
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.loadView()

        currentMediaPlayer.create(frame: view.frame)
        view.layer.addSublayer(currentMediaPlayer.metalLayer)
        currentMediaPlayer.loadFile(configuration.url)

        super.viewDidLoad()
    }
}

public struct MPVVideoPlayer: UIViewControllerRepresentable {
    static let defaultAspectRatio = 16 / 9.0
    private var configuration: MPVVideoPlayer.Configuration
    private var proxy: MPVVideoPlayer.Proxy?
    private var onTicksUpdated: (Int, MPVVideoPlayer.PlaybackInformation) -> Void
    private var onStateUpdated: (MPVVideoPlayer.State, MPVVideoPlayer.PlaybackInformation) -> Void
    private var loggingInfo: (MPVVideoPlayerLogger, LoggingLevel)?
    public func makeUIViewController(context _: Context) -> some UIViewController {
        return MPVViewController(configuration: configuration,
                                 proxy: proxy,
                                 onTicksUpdated: onTicksUpdated,
                                 onStateUpdated: onStateUpdated,
                                 loggingInfo: loggingInfo)
    }

    public func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}
#else
public struct MPVVideoPlayer: _PlatformRepresentable {
    static let defaultAspectRatio = 16 / 9.0
    private var configuration: MPVVideoPlayer.Configuration
    private var proxy: MPVVideoPlayer.Proxy?
    private var onTicksUpdated: (Int, MPVVideoPlayer.PlaybackInformation) -> Void
    private var onStateUpdated: (MPVVideoPlayer.State, MPVVideoPlayer.PlaybackInformation) -> Void
    private var loggingInfo: (MPVVideoPlayerLogger, LoggingLevel)?

    #if os(macOS)
    public func makeNSView(context: Context) -> UIMPVVideoPlayerView {
        makeVideoPlayerView()
    }

    public func updateNSView(_ nsView: UIMPVVideoPlayerView, context: Context) {}
    #else
    public func makeUIView(context: Context) -> UIMPVVideoPlayerView {
        makeVideoPlayerView()
    }

    public func updateUIView(_ uiView: UIMPVVideoPlayerView, context: Context) {}
    #endif

    private func makeVideoPlayerView() -> UIMPVVideoPlayerView {
        UIMPVVideoPlayerView(
            configuration: configuration,
            proxy: proxy,
            onTicksUpdated: onTicksUpdated,
            onStateUpdated: onStateUpdated,
            loggingInfo: loggingInfo
        )
    }
}
#endif

public extension MPVVideoPlayer {
    init(configuration: MPVVideoPlayer.Configuration) {
        self.init(
            configuration: configuration,
            proxy: nil,
            onTicksUpdated: { _, _ in },
            onStateUpdated: { _, _ in },
            loggingInfo: nil
        )
    }

    init(url: URL) {
        self.init(configuration: MPVVideoPlayer.Configuration(url: url))
    }

    init(_ configure: @escaping () -> MPVVideoPlayer.Configuration) {
        self.init(configuration: configure())
    }

    /// Sets the proxy for events
    func proxy(_ proxy: MPVVideoPlayer.Proxy) -> Self {
        copy(modifying: \.proxy, with: proxy)
    }

    /// Sets the action that fires when the media ticks have been updated
    func onTicksUpdated(_ action: @escaping (Int, MPVVideoPlayer.PlaybackInformation) -> Void) -> Self {
        copy(modifying: \.onTicksUpdated, with: action)
    }

    /// Sets the action that fires when the media state has been updated
    func onStateUpdated(_ action: @escaping (MPVVideoPlayer.State, MPVVideoPlayer.PlaybackInformation) -> Void) -> Self {
        copy(modifying: \.onStateUpdated, with: action)
    }

    func logger(_ logger: MPVVideoPlayerLogger, level: LoggingLevel) -> Self {
        copy(modifying: \.loggingInfo, with: (logger, level))
    }
}
