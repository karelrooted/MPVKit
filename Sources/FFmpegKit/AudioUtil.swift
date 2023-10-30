//
//  AudioUtil.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/8/2.
//

import Libffmpeg
@_exported
import struct Libffmpeg.AVChannelLayout
@_exported
import let Libffmpeg.AVChannelLayoutMono
@_exported
import let Libffmpeg.AVChannelLayoutStereo
@_exported
import let Libffmpeg.AVChannelLayout2Point1
@_exported
import let Libffmpeg.AVChannelLayout2_1
@_exported
import let Libffmpeg.AVChannelLayoutSurround
@_exported
import let Libffmpeg.AVChannelLayout3Point1
@_exported
import let Libffmpeg.AVChannelLayout4Point0
@_exported
import let Libffmpeg.AVChannelLayout4Point1
@_exported
import let Libffmpeg.AVChannelLayout2_2
@_exported
import let Libffmpeg.AVChannelLayoutQuad
@_exported
import let Libffmpeg.AVChannelLayout5Point0
@_exported
import let Libffmpeg.AVChannelLayout5Point1
@_exported
import let Libffmpeg.AVChannelLayout5Point0Back
@_exported
import let Libffmpeg.AVChannelLayout5Point1Back
@_exported
import let Libffmpeg.AVChannelLayout6Point0
@_exported
import let Libffmpeg.AVChannelLayout6Point0Front
@_exported
import let Libffmpeg.AVChannelLayoutHexagonal
@_exported
import let Libffmpeg.AVChannelLayout6Point1
@_exported
import let Libffmpeg.AVChannelLayout6Point1Back
@_exported
import let Libffmpeg.AVChannelLayout6Point1Front
@_exported
import let Libffmpeg.AVChannelLayout7Point0
@_exported
import let Libffmpeg.AVChannelLayout7Point0Front
@_exported
import let Libffmpeg.AVChannelLayout7Point1
@_exported
import let Libffmpeg.AVChannelLayout7Point1Wide
@_exported
import let Libffmpeg.AVChannelLayout7Point1WideBack
@_exported
import let Libffmpeg.AVChannelLayoutOctagonal
@_exported
import let Libffmpeg.AVChannelLayoutHexadecagonal
@_exported
import let Libffmpeg.AVChannelLayoutStereoDownmix
@_exported
import let Libffmpeg.AVChannelLayout22Point2

public extension AVChannelLayout {
    /// Initialize a channel layout from a given string description.
    ///
    /// The input string can be represented by:
    ///  - the formal channel layout name (returned by av_channel_layout_describe())
    ///  - single or multiple channel names (returned by av_channel_name(), eg. "FL",
    ///    or concatenated with "+", each optionally containing a custom name after
    ///    a "@", eg. "FL@Left+FR@Right+LFE")
    ///  - a decimal or hexadecimal value of a native channel layout (eg. "4" or "0x4")
    ///  - the number of channels with default layout (eg. "4c")
    ///  - the number of unordered channels (eg. "4C" or "4 channels")
    ///  - the ambisonic order followed by optional non-diegetic channels (eg.
    ///    "ambisonic 2+stereo")
    ///
    /// - Parameter name: string describing the channel layout
    init?(name: String) {
        var cl = AVChannelLayout()
        let r = av_channel_layout_from_string(&cl, name)
        guard r != 0 else {
            return nil
        }
        self = cl
    }

    /// The number of channels in the channel layout.
    var channelCount: Int {
        Int(nb_channels)
    }

    /// Get the index of a given channel in a channel layout.
    /// In case multiple channels are found, only the first match will be returned.
    func index(for channel: AVChannel) -> Int? {
        let i = withUnsafePointer(to: self) { ptr in
            av_channel_layout_index_from_channel(ptr, channel)
        }
        return i >= 0 ? Int(i) : nil
    }

    /// Get the channel with the given index in a channel layout.
    func channel(at index: Int) -> AVChannel? {
        let c = withUnsafePointer(to: self) { ptr in
            av_channel_layout_channel_from_index(ptr, UInt32(index))
        }
        return c != AV_CHAN_NONE ? c : nil
    }

    /// Get the default channel layout for a given number of channels.
    static func `default`(for channelCount: Int) -> AVChannelLayout {
        var cl = AVChannelLayout()
        av_channel_layout_default(&cl, Int32(channelCount))
        return cl
    }
}

extension AVChannelLayout: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.u.mask == rhs.u.mask
    }
}

extension AVChannelLayout: CustomStringConvertible {
    public var description: String {
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: 256)
        buf.initialize(to: 0)
        defer { buf.deallocate() }
        let r = withUnsafePointer(to: self) { p in
            av_channel_layout_describe(p, buf, 256)
        }
        return r >= 0 ? String(cString: buf) : "Invalid"
    }
}
