# MPVKit

[![ffmpeg](https://img.shields.io/badge/ffmpeg-n6.1-blue.svg)](https://github.com/FFmpeg/FFmpeg)
[![mpv](https://img.shields.io/badge/mpv-v0.37.0-blue.svg)](https://github.com/mpv-player/mpv)

libmpv bindings for macOS, iOS, iPadOS and tvOS in Swift

## Table of content

- [Features](#features)
- [Use-case](#use-case)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage) 
- [Build](#build)
- [License](#license)


## Features

- Wrapper of **libMPV**, the C API of the popular command line media player *MPV*.
- Easily integratable via [SwiftPM](https://www.swift.org/package-manager/).
- A basic SwiftUI view and control overlay panel [example](https://github.com/karelrooted/MPVKitExample), you can customied it as you like (WIP)
- protocol support: http, https, bluray... and more
    - please note only bdmv folder support is available on iOS, tvOS, bluray ISO support is only available on MacOS, 
- codec support: h264, h265, av1, vp9... and more
- other features: LuaJIT, shaderc, vulkan(MoltenVK)

## Use-case

When will you need MPVKit?

Frankly, you will need it whenever you need to play media not supported by QuickTime / AVFoundation or if you require more flexibility.

Here are some other common use-cases:

- Playing something else besides H264/AAC files or HLS streams.
- Need subtitles beyond QuickTime’s basic support for Closed Captions.
- and more!

## Requirements

- iOS 17.0+ / macOS 14.0+ / tvOS 17.0+
- Xcode 15.0+

## Installation

### Swift Package Manager

In Xcode:

* File → Swift Packages → Add Package Dependency…
* Enter `https://github.com/karelrooted/MPVKit` in the URL field and click Next.
* The defaults for the version settings are good for most projects. Click Next.
* Check the checkbox next to MPVKit.”
    - Also check LibMPV if you want libmpv C Binding.
    - Also check FFmpegKit if you want swift binding of ffmpeg c library.
    - Also check Libffmpeg if you want ffmpeg c library.
* Click “Finish.”

## Usage

> MPVKit is a WIP(vo=gpu-next is not production ready), currently you have to use libmpv c binding to build your own

MPVKit is structured mostly like [VLCUI](https://github.com/LePips/VLCUI), so can be easily imported in project already support VLCUI as a alternative player

```swift
import SwiftUI
import MPVKit

struct ContentView: View {
    var body: some View {
        VStack {
            MPVVideoPlayer(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        }
    }
}
```

## Build

The building script of binary frameworks(libmpv, libffmpeg, etc...) is at : [karelrooted/libmpv](https://github.com/karelrooted/libmpv.git)

## Credits

- [mpv](https://mpv.io)
- [ffmpeg](https://ffmpeg.org)
- [sunlubo/SwiftFFmpeg](https://github.com/sunlubo/SwiftFFmpeg)

## License
MPVKit is under the [LGPL 3.0](https://www.gnu.org/licenses/lgpl-3.0.en.html) license. Check [mpv](https://mpv.io) and [ffmpeg](https://ffmpeg.org) for more license requirement.
Please note samba is under GPL v3 license, so if you enable smbclient, this library's license became GPL v3 too
