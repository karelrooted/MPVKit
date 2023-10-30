// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MPVKit",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MPVKit",
            targets: ["MPVKit"]
        ),
        .library(
            name: "LibMPV",
            type: .static,
            targets: ["LibMPV"]
        ),
        .library(
            name: "FFmpegKit",
            targets: ["FFmpegKit"]
        ),
        .library(
            name: "Libffmpeg",
            type: .static,
            targets: ["Libffmpeg"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-log.git",
                 from: "1.5.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LibMPV",
            dependencies: [
                "Libavcodec", "Libavdevice", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz", "Libuchardet",
                "Liblcms2", "Libplacebo", "Libluajit", "Libshaderc", "Libmpv", "MoltenVK", "Libdav1d", "Libbluray", "Libpng",
                .target(name: "Libdovi", condition: .when(platforms: [.iOS]))
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("AudioToolbox"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("CoreText"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Metal"),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("bz2"),
                .linkedLibrary("xml2"),
                .linkedLibrary("iconv"),
                .linkedLibrary("z"),
                .linkedLibrary("c++")
            ]
        ),
        .testTarget(
            name: "MPVKitTests",
            dependencies: ["MPVKit"]
        ),
        .target(
            name: "Libffmpeg",
            dependencies: [
                "Libavcodec", "Libavdevice", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz", "Libplacebo", "Libshaderc", "MoltenVK", "Libdav1d", "Libbluray", "Libpng",
                .target(name: "Libdovi", condition: .when(platforms: [.iOS]))
            ],
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreText"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Metal"),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("bz2"),
                .linkedLibrary("xml2"),
                .linkedLibrary("iconv"),
                .linkedLibrary("z"),
                .linkedLibrary("c++")
            ]
        ),
        .target(
            name: "MPVKit",
            dependencies: ["LibMPV",
                           .product(name: "Logging", package: "swift-log")]
        ),
        .target(
            name: "FFmpegKit",
            dependencies: ["Libffmpeg"]
        ),
        .binaryTarget(
            name: "Libass",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libass.xcframework.zip",
            checksum: "f854fd3da12111c34ddc6129fcbaec2f3dfc03b3d0f26227412b2c251ae15824"
        ),
        .binaryTarget(
            name: "Libavcodec",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libavcodec.xcframework.zip",
            checksum: "e6e4a406894da67cf2daf884f640cf80385457b5aa39cf89cd196d93acefdac4"
        ),
        .binaryTarget(
            name: "Libavdevice",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libavdevice.xcframework.zip",
            checksum: "aa056fe7c7ed78bb29c3b4d86df5c085486b8395405ead293336f5c648e62b27"
        ),
        .binaryTarget(
            name: "Libavfilter",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libavfilter.xcframework.zip",
            checksum: "820c916ef48609607fa4dd7c5d8008d6ea9a76c8dc08f804e8a964dd2c2e3e8b"
        ),
        .binaryTarget(
            name: "Libavformat",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libavformat.xcframework.zip",
            checksum: "91f48ed37f7360ea1fa83d09d1e26cb156b74192b5de2b9417a115aad9d7e1dd"
        ),
        .binaryTarget(
            name: "Libavutil",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libavutil.xcframework.zip",
            checksum: "94faef320167b059fe438aa998ef3d138b078e3adf6f6fff57791fc3e9902191"
        ),
        .binaryTarget(
            name: "Libbluray",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libbluray.xcframework.zip",
            checksum: "f6e1055e4907cc5fac718302a9a39038c8dc0137ab9f8787b43cd87736909601"
        ),
        .binaryTarget(
            name: "Libcrypto",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libcrypto.xcframework.zip",
            checksum: "af4795290f4d1c83546d7a6c4ddfa74d7cc0352f16096ca7ba1b49f3eac8bf10"
        ),
        .binaryTarget(
            name: "Libdav1d",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libdav1d.xcframework.zip",
            checksum: "91a447147c25477ec6f84d26f0e35245bcb6a9aa47e348f988d4f66fe8d8e6ad"
        ),
        .binaryTarget(
            name: "Libdovi",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libdovi.xcframework.zip",
            checksum: "68b09f68af5ea8c0c1c5ee8e5143064e2bf8d9f849854505b7eb6082252bdeb0"
        ),
        .binaryTarget(
            name: "Libeffcee",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libeffcee.xcframework.zip",
            checksum: "d8b4c9673f5d0530ea8240ec235915cba6bffe72bf553ef454fe6a5f3bfd0826"
        ),
        .binaryTarget(
            name: "Libfreetype",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libfreetype.xcframework.zip",
            checksum: "e1f32bbd569fc29b7bc15bb1e2a13698444f4233450d6e33d3a897829ab3cfe1"
        ),
        .binaryTarget(
            name: "Libfribidi",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libfribidi.xcframework.zip",
            checksum: "393c928cac7c895c3da328eb58cd2030d7ec47936be38972c4359260dcaebb3c"
        ),
        .binaryTarget(
            name: "Libglslang",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libglslang.xcframework.zip",
            checksum: "7d7843df4099313350d3e0aadf7f8f024d1b026f5b3d29362b442ff708204ec4"
        ),
        .binaryTarget(
            name: "Libgmp",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libgmp.xcframework.zip",
            checksum: "fd15de28241de7af2d5940926bf2888ed6c812922773cdc67fda5be6088eafab"
        ),
        .binaryTarget(
            name: "Libgnutls",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libgnutls.xcframework.zip",
            checksum: "2ef4a1fa9af4940ea4aff19ec8bd2d072a8db56dc537f7ee4017de13da6c2d7f"
        ),
        .binaryTarget(
            name: "Libharfbuzz",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libharfbuzz.xcframework.zip",
            checksum: "9e85337f12224632f8d519bace2565b03958f5fbcdd73da691b9ff41d94d57bd"
        ),
        .binaryTarget(
            name: "Libhogweed",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libhogweed.xcframework.zip",
            checksum: "2e03033324786b8eeefb20e5f4edbe249e2dad142e24bd62f1ff0af23977739b"
        ),
        .binaryTarget(
            name: "Liblcms2",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Liblcms2.xcframework.zip",
            checksum: "764ba49fb9dbfd300cc83fe74ee9090edec6d0cce2c9bd679b2a80b592d471df"
        ),
        .binaryTarget(
            name: "Libluajit",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libluajit-5.1.xcframework.zip",
            checksum: "0eae84fc010b1730581f942a883389f29862f9e7911301a7065d4f363b25c6ac"
        ),
        .binaryTarget(
            name: "Libmpv",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libmpv.xcframework.zip",
            checksum: "169dca1c5d19e4749b5f0e7a889d3bc1cbb2b180902c761585de87063ff55a4a"
        ),
        .binaryTarget(
            name: "Libnettle",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libnettle.xcframework.zip",
            checksum: "03810283d4750a57b006c237cfb1e68caadc9a6304716af62ec4e24b33a01627"
        ),
        .binaryTarget(
            name: "Libnfs",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libnfs.xcframework.zip",
            checksum: "0f7bd725190226ab8ebaf0c053f3b8289f8609c217fb4ffcff8245af0e2cf361"
        ),
        .binaryTarget(
            name: "Libplacebo",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libplacebo.xcframework.zip",
            checksum: "751b20844a64cdba660ee8f49c316a6a27ab40a4c277350a8f33ce9086f5b707"
        ),
        .binaryTarget(
            name: "Libpng",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libpng.xcframework.zip",
            checksum: "218220d82b3028041a0f11c033bbd32dbdf742f10c3d4b77a76f31f479eefd97"
        ),
        .binaryTarget(
            name: "Libreadline",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libreadline.xcframework.zip",
            checksum: "4325cd6b78455ecf35eab505063afea6bd4ed3b1c3cb6ae2ffc92632855d4347"
        ),
        .binaryTarget(
            name: "Libshaderc",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libshaderc_combined.xcframework.zip",
            checksum: "bcaf0d034c7b5d56209ad5ba36c08349a4c3bcf9807ff42734592b4c2b0cefa7"
        ),
        .binaryTarget(
            name: "Libsmbclient",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libsmbclient.xcframework.zip",
            checksum: "7d28045335067ec6d72f294fe34b5a8069bc1e122d970e8f5d7a59a1fe8df957"
        ),
        .binaryTarget(
            name: "Libssl",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libssl.xcframework.zip",
            checksum: "0815b270f6740e8c4b4e4ba0093ebbe05b7f8c9dee8b5655af83fb70a8af2272"
        ),
        .binaryTarget(
            name: "Libswresample",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libswresample.xcframework.zip",
            checksum: "715f05f1bf368588a75d3f5ef2d906f58fa8d31d9a9158f5af69962046aaf43f"
        ),
        .binaryTarget(
            name: "Libswscale",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libswscale.xcframework.zip",
            checksum: "11db9fb6e176b58007d1b46e4a5dc537933f91585b0080996870cd686b928bd4"
        ),
        .binaryTarget(
            name: "Libuchardet",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/Libuchardet.xcframework.zip",
            checksum: "8da536a83136d2e5a859e72755a74a44b84db4cca7714153c305d2c5853e3633"
        ),
        .binaryTarget(
            name: "MoltenVK",
            url: "https://github.com/karelrooted/libmpv/releases/download/v0.0.1-beta/MoltenVK.xcframework.zip",
            checksum: "846b1b8a4b86a55cd11c81686f5f7928779ba0f1e3f2c933320375b4588fca04"
        )
//        .binaryTarget(
//            name: "Libsrt",
//            path: "Framework/Libsrt.xcframework"
//        ),
    ]
)
