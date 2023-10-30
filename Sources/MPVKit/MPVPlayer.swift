import Foundation

public final class MPVPlayer: ObservableObject {
    public init(url: URL) {
        self.url = url
        self.client = MPVClient()
        #if os(macOS)
            self.view = MPVPlayerView(client: client)
        #else
            self.mpvController = MPVViewController(client: client)
            self.view = MPVPlayerView(controller: mpvController)
        #endif
    }

    var url: URL
    public var client: MPVClient!
    var view: MPVPlayerView!
    #if !os(macOS)
        var mpvController: MPVViewController!
    #endif
    public var isPlaying: Bool {
        client.isPlaying
    }

    public func play() {
        client.play()
    }

    public func pause() {
        client.pause()
    }

    public func toggle() {
        client.isPlaying ? client.pause() : client.play()
    }

    public func close() {
        client.close()
    }

    func playUrl(url: URL) {
        client.loadFile(url) { [weak self] _ in
            self?.client.isLoadingVideo = true
        }
    }

    public func playCurrentUrl() {
        playUrl(url: url)
    }
}
