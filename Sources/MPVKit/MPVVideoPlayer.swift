//
//  MPVVideoPlayer.swift
//
import SwiftUI

public struct MPVVideoPlayer: View {
    public init(player: MPVPlayer) {
        self.player = player
    }

    static let defaultAspectRatio = 16 / 9.0
    @ObservedObject public var player: MPVPlayer
    public var body: some View {
        player.view
            .onAppear {
                player.playCurrentUrl()
            }
            .ignoresSafeArea()
    }
}
