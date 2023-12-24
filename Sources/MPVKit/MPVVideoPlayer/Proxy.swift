import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import CoreMedia
import LibMPV

public extension MPVVideoPlayer {
    class Proxy: ObservableObject {
        public var mediaPlayer: MPVMediaPlayer?
        weak var videoPlayerView: UIMPVVideoPlayerView?

        public init() {
            self.mediaPlayer = nil
            self.videoPlayerView = nil
        }

        /// Play the current media
        public func play() {
            mediaPlayer?.play()
        }

        /// Pause the current media
        public func pause() {
            mediaPlayer?.pause()
        }

        /// Stop the current media
        public func stop() {
            mediaPlayer?.stop()
        }

        /// Jump forward a given amount of seconds
        public func jumpForward(_ seconds: Int) {
            mediaPlayer?.jumpForward(seconds)
        }

        /// Jump backward a given amount of seconds
        public func jumpBackward(_ seconds: Int) {
            mediaPlayer?.jumpBackward(seconds)
        }

        /// Go to the next frame
        ///
        /// **Note**: media will be paused
        public func gotoNextFrame() {
            mediaPlayer?.gotoNextFrame()
        }

        /// Set the subtitle track index
        ///
        /// **Note**: If there is no valid track with the given index, the track will default to disabled
        public func setSubtitleTrack(_ index: ValueSelector<Int>) {
            guard let mediaPlayer = mediaPlayer else { return }
        }

        public func addSubtitleTrack(_ url: URL) {
            guard let mediaPlayer = mediaPlayer else { return }
            mediaPlayer.addSubTrack(url)
        }

        public func subReload() {
            guard let mediaPlayer = mediaPlayer else { return }
            mediaPlayer.subReload()
        }

        /// Set the audio track index
        ///
        /// **Note**: If there is no valid track with the given index, the track will default to disabled
        public func setAudioTrack(_ index: ValueSelector<Int>) {
            guard let mediaPlayer = mediaPlayer else { return }
        }

        /// Set the subtitle delay
        public func setSubtitleDelay(_ interval: TimeSelector) {
            let delay = interval.asTicks * 1000
        }

        /// Set the audio delay
        public func setAudioDelay(_ interval: TimeSelector) {
            let delay = interval.asTicks * 1000
        }

        /// Set the player rate
        public func setRate(_ rate: ValueSelector<Float>) {
            guard let mediaPlayer = mediaPlayer else { return }
            let newRate = mediaPlayer.rate(from: rate)
            mediaPlayer.fastForward(atRate: newRate)
        }

        /// Aspect fill depending on the video's content size and the view's bounds, based
        /// on the given percentage of completion
        ///
        /// **Note**: Does not work on macOS
        public func aspectFill(_ percentage: Float) {
            videoPlayerView?.setAspectFill(with: percentage)
        }

        /// Set the player time
        public func setTime(_ time: TimeSelector) {
            guard let mediaPlayer = mediaPlayer else { return }

            guard time.asTicks >= 0 && time.asTicks <= mediaPlayer.length * 1000 else { return }

            let seconds = CMTime.secondsInDefaultTimescale(Double(time.asTicks.asInt32 / 1000))
            mediaPlayer.seek(to: seconds)
        }

        /// Set the media subtitle size
        ///
        /// **Note**: Due to MPVKit, a given size does not accurately represent a font size and magnitudes are inverted.
        /// Larger values indicate a smaller font and smaller values indicate a larger font.
        ///
        /// **Note**: Does not work on macOS
        public func setSubtitleSize(_ size: ValueSelector<Int>) {
            mediaPlayer?.setSubtitleSize(size)
        }

        /// Set the subtitle font using the font name of the given `UIFont`
        ///
        /// **Note**: Does not work on macOS
        public func setSubtitleFont(_ font: ValueSelector<_PlatformFont>) {
            mediaPlayer?.setSubtitleFont(font)
        }

        /// Set the subtitle font using the given font name
        ///
        /// **Note**: Does not work on macOS
        public func setSubtitleFont(_ fontName: String) {
            mediaPlayer?.setSubtitleFont(fontName)
        }

        /// Set the subtitle font color using the RGB values of the given `UIColor`
        ///
        /// **Note**: Does not work on macOS
        public func setSubtitleColor(_ color: ValueSelector<_PlatformColor>) {
            mediaPlayer?.setSubtitleColor(color)
        }

        /// Add a playback child
        public func addPlaybackChild(_ child: PlaybackChild) {}

        /// Play new media given a configuration
        public func playNewMedia(_ newConfiguration: Configuration) {
            mediaPlayer?.loadFile(newConfiguration.url)
            // videoPlayerView?.setupMPVMediaPlayer(with: newConfiguration)
        }

        public func getCurrentPosition() -> Int? {
            mediaPlayer?.getInt("time-pos")
        }
    }
}
