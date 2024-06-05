// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Cocoa

private class DragDestinationView: NSView {
    var onDraggedFileURLs: (([URL]) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    private func setup() {
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard.availableType(from: [.fileURL]) != nil {
            return .copy
        } else {
            return NSDragOperation()
        }
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        sender.draggingPasteboard.availableType(from: [.fileURL]) != nil
    }

    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        guard let files = draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)
        else {
            return false
        }
        let urls = files.compactMap { $0 as? URL }.filter { $0.pathExtension == "conf" }
        guard !urls.isEmpty else {
            return false
        }
        onDraggedFileURLs?(urls)
        return true
    }
}

class ButtonedDetailViewController: NSViewController {

    var onButtonClicked: (() -> Void)?
    var onDraggedFileURLs: (([URL]) -> Void)? {
        get {
            (view as? DragDestinationView)?.onDraggedFileURLs
        }
        set {
            loadView()
            (view as? DragDestinationView)?.onDraggedFileURLs = newValue
        }
    }

    let button: NSButton = {
        let button = NSButton()
        button.title = ""
        button.setButtonType(.momentaryPushIn)
        button.bezelStyle = .rounded
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = DragDestinationView()

        button.target = self
        button.action = #selector(buttonClicked)

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 320),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])

        view.registerForDraggedTypes([.URL])

        self.view = view
    }

    func setButtonTitle(_ title: String) {
        button.title = title
    }

    @objc func buttonClicked() {
        onButtonClicked?()
    }
}
