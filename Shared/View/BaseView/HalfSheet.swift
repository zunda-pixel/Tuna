//
//  HalfSheet.swift
//  Tuna
//
//  Created by zunda on 2022/06/01.
//

import Foundation
import SwiftUI

extension View {
  func halfSheet<Sheet: View>(isPresented: Binding<Bool>, @ViewBuilder sheet: @escaping () -> Sheet, onEnd: @escaping () -> ()) -> some View {
    return self
      .background(
        HalfSheetViewController(isPresented: isPresented, content: sheet(), onEnd: onEnd)
      )
  }
}

struct HalfSheetViewController<Sheet: View>: UIViewControllerRepresentable {
  @Binding var isPresented: Bool

  var content: Sheet
  var onEnd: (() -> Void)?

  init(isPresented: Binding<Bool>, content: Sheet, onEnd: (() -> Void)?) {
    self.content = content
    self.onEnd = onEnd
    self._isPresented = isPresented
  }

  func makeUIViewController(context: Context) -> UIViewController {
    return UIViewController()
  }

  func updateUIViewController(_ viewController: UIViewController, context: Context) {
    if isPresented {
      let sheetController = CustomHostingController(rootView: content)
      sheetController.presentationController?.delegate = context.coordinator
      viewController.present(sheetController, animated: true)
    } else {
      viewController.dismiss(animated: true) { onEnd?() }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  class Coordinator: NSObject, UISheetPresentationControllerDelegate {
    var parent: HalfSheetViewController

    init(parent: HalfSheetViewController) {
      self.parent = parent
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
      parent.isPresented = false
    }
  }

  class CustomHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
      super.viewDidLoad()
      if let sheet = self.sheetPresentationController {
        sheet.detents = [.medium()]
        sheet.prefersGrabberVisible = true
      }
    }
  }
}