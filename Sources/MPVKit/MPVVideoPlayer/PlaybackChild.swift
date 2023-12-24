import Foundation
import LibMPV

public enum MPVMediaPlaybackSlaveType: Int {
    case subtitle = 0
    case audio = 1
}

public extension MPVVideoPlayer {
    struct PlaybackChild {
        public let url: URL
        public let type: PlaybackChildType
        public let enforce: Bool

        public init(url: URL, type: PlaybackChildType, enforce: Bool) {
            self.url = url
            self.type = type
            self.enforce = enforce
        }

        // Wrapper so that MPVKit imports are not necessary
        public enum PlaybackChildType {
            case subtitle
            case audio

            var asMPVSlaveType: MPVMediaPlaybackSlaveType {
                switch self {
                case .subtitle: return .subtitle
                case .audio: return .audio
                }
            }
        }
    }
}
