import Foundation

public extension MPVVideoPlayer {
    // Wrapper so that MPVKit imports are not necessary
    enum State: Int {
        case stopped
        case opening
        case loaded
        case buffering
        case ended
        case error
        case playing
        case paused
        case esAdded
    }
}
