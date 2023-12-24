import Foundation

public protocol MPVVideoPlayerLogger {

    /// Called when the MPVVideoPlayer logs a message
    func mpvVideoPlayer(didLog message: String, at level: MPVVideoPlayer.LoggingLevel)
}
