import Combine
import Foundation
import MediaPlayer

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import LibMPV

public enum MPVMediaPlayerState: Int {
    case stopped
    case opening
    case buffering
    case ended
    case error
    case playing
    case paused
}

public class UIMPVVideoPlayerView: _PlatformView {
    private var configuration: MPVVideoPlayer.Configuration
    private var proxy: MPVVideoPlayer.Proxy?
    private let onTicksUpdated: (Int, MPVVideoPlayer.PlaybackInformation) -> Void
    private let onStateUpdated: (MPVVideoPlayer.State, MPVVideoPlayer.PlaybackInformation) -> Void
    private let loggingInfo: (logger: MPVVideoPlayerLogger, level: MPVVideoPlayer.LoggingLevel)?
    private var currentMediaPlayer: MPVMediaPlayer?

    private var hasSetCurrentConfigurationValues: Bool = false
    private var lastPlayerTicks: Int32 = 0
    private var lastPlayerState: MPVMediaPlayerState = .opening

    private var aspectFillScale: CGFloat {
        guard let currentMediaPlayer = currentMediaPlayer else { return 1 }
        let videoSize = currentMediaPlayer.videoSize
        let fillSize = CGSize.aspectFill(aspectRatio: videoSize, minimumSize: bounds.size)
        return fillSize.scale(other: bounds.size)
    }

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
        super.init(frame: .infinite)

        proxy?.videoPlayerView = self

        #if os(macOS)
        layer?.backgroundColor = .clear
        #else
        backgroundColor = .clear
        #endif

        setupMPVMediaPlayer(with: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupMPVMediaPlayer(with newConfiguration: MPVVideoPlayer.Configuration) {
        currentMediaPlayer?.stop()
        currentMediaPlayer = nil

        let newMediaPlayer = MPVMediaPlayer(configuration: newConfiguration,
                                            onTicksUpdated: onTicksUpdated,
                                            onStateUpdated: onStateUpdated,
                                            loggingInfo: loggingInfo)
        newMediaPlayer.create(frame: frame)
        #if !os(macOS)
        layer.addSublayer(newMediaPlayer.metalLayer)
        #else
        wantsLayer = true
        layer = newMediaPlayer.metalLayer
        #endif

        if let loggingInfo = loggingInfo {
            /* newMediaPlayer.libraryInstance.debugLogging = true
             newMediaPlayer.libraryInstance.debugLoggingLevel = loggingInfo.level.rawValue.asInt32
             newMediaPlayer.libraryInstance.debugLoggingTarget = self */
        }

        for child in newConfiguration.playbackChildren {
            // newMediaPlayer.addPlaybackSlave(child.url, type: child.type.asMPVSlaveType, enforce: child.enforce)
        }

        configuration = newConfiguration
        currentMediaPlayer = newMediaPlayer
        proxy?.mediaPlayer = newMediaPlayer
        hasSetCurrentConfigurationValues = false
        lastPlayerTicks = 0
        lastPlayerState = .opening
        newMediaPlayer.loadFile(configuration.url)

        if newConfiguration.autoPlay {
            newMediaPlayer.play()
        }
    }

    func setAspectFill(with percentage: Float) {
        guard percentage >= 0, percentage <= 1 else { return }
        let scale = 1 + CGFloat(percentage) * (aspectFillScale - 1)
        self.scale(x: scale, y: scale)
    }
}

// MARK: constructPlaybackInformation

extension UIMPVVideoPlayerView {
    private func constructPlaybackInformation(player: MPVMediaPlayer) -> MPVVideoPlayer.PlaybackInformation {
        let subtitleTracks = player.subtitleTracks
        let audioTracks = player.audioTracks

        let currentSubtitleTrack = player.currentSubtitleTrack
        let currentAudioTrack = player.currentAudioTrack

        return MPVVideoPlayer.PlaybackInformation(
            startConfiguration: configuration,
            position: player.position,
            length: player.length,
            isSeekable: player.seekable,
            playbackRate: player.rate,
            currentSubtitleTrack: currentSubtitleTrack,
            currentAudioTrack: currentAudioTrack,
            subtitleTracks: subtitleTracks,
            audioTracks: audioTracks,
            numberOfReadBytesOnInput: 0,
            inputBitrate: 0,
            numberOfReadBytesOnDemux: 0,
            demuxBitrate: 0,
            numberOfDecodedVideoBlocks: 0,
            numberOfDecodedAudioBlocks: 0,
            numberOfDisplayedPictures: 0,
            numberOfLostPictures: 0,
            numberOfPlayedAudioBuffers: 0,
            numberOfLostAudioBuffers: 0,
            numberOfSentPackets: 0,
            numberOfSentBytes: 0,
            streamOutputBitrate: 0,
            numberOfCorruptedDataPackets: 0,
            numberOfDiscontinuties: 0
        )
    }
}
