import SwiftUI

#if !os(macOS)
import UIKit

final class MPVViewController: UIViewController {
    var client: MPVClient!

    init(client: MPVClient) {
        self.client = client
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.loadView()
        client.create(frame: view.frame)
        view.layer.addSublayer(client.metalLayer)
        super.viewDidLoad()
    }
}

struct MPVPlayerView: UIViewControllerRepresentable {
    var controller: MPVViewController!

    init(controller: MPVViewController) {
        self.controller = controller
    }

    func makeUIViewController(context _: Context) -> some UIViewController {
        controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}
#else
struct MPVPlayerView: NSViewRepresentable {
    var client: MPVClient!

    init(client: MPVClient) {
        self.client = client
    }

    func makeNSView(context _: Context) -> some NSView {
        let view = NSView()
        client.create(frame: view.frame)

        view.wantsLayer = true
        view.layer = client.metalLayer

        return view
    }

    func updateNSView(_: NSViewType, context _: Context) {}
}
#endif
