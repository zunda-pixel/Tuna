//
//  CustomContextMenu.swift
//  Tuna
//
//  Created by zunda on 2022/05/19.
//

import SwiftUI

struct CustomContextMenu<Content: View, Preview: View>: View {
  var content: Content
  var preview: Preview
  var menu: UIMenu
  var onEnd: () -> ()

  init(@ViewBuilder content: @escaping () -> Content,
       @ViewBuilder preview: @escaping () -> Preview,
       action: @escaping () -> UIMenu,
       onEnd: @escaping () -> ()) {
    self.content = content()
    self.preview = preview()
    self.menu = action()
    self.onEnd = onEnd
  }

  var body: some View {
    ZStack {
      content
        .hidden()
        .overlay {
          ContextMenuHelper(content: content, preview: preview, action: menu, onEnd: onEnd)
        }
    }
  }
}

struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable {
  var content: Content
  var preview: Preview
  var action: UIMenu
  var onEnd: () -> ()

  init(content:Content, preview: Preview, action: UIMenu, onEnd: @escaping () -> ()) {
    self.content = content
    self.preview = preview
    self.action = action
    self.onEnd = onEnd
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(parent: self)
  }

  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear

    let hostView = UIHostingController(rootView: content)

    hostView.view.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
      hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor),
    ]

    view.addSubview(hostView.view)
    view.addConstraints(constraints)

    let interaction = UIContextMenuInteraction(delegate: context.coordinator)

    view.addInteraction(interaction)

    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
  }

  class Coordinator: NSObject, UIContextMenuInteractionDelegate {
    var parent: ContextMenuHelper

    init(parent: ContextMenuHelper) {
      self.parent = parent
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
      return UIContextMenuConfiguration(identifier: nil) {
        let previewController = UIHostingController(rootView: self.parent.preview)

        previewController.view.backgroundColor = .clear

        return previewController
      } actionProvider: { items in
        return self.parent.action
      }
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
      animator.addCompletion {
        self.parent.onEnd()
      }
    }
  }
}
