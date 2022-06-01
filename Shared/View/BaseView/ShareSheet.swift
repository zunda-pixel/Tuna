//
//  ShareSheet.swift
//  Tuna
//
//  Created by zunda on 2022/05/31.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
  // String > URL > UIActivityItemSource(ShareActivityItemSource)
  let items: [Any]
  let activities: [UIActivity]

  func makeUIViewController(context: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)

    return controller
  }

  func updateUIViewController(_ vc: UIActivityViewController, context: Context) {
  }
}

struct ShareSheet_Previews: PreviewProvider {
  static var previews: some View {
    ShareSheet(items: [], activities: [])
  }
}
