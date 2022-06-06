//
//  ShareButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/31.
//

import SwiftUI

class ShareActivityItemSource: NSObject, UIActivityItemSource {
  let item: Any

  init(_ item: Any) {
    self.item = item
    super.init()
  }

  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    item
  }

  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    item
  }
}

struct ShareButton: View {
  @State var isPresentedShareSheet = false

  let items: [Any]

  let activities: [UIActivity] = [CopyTweetLinkActivity()]

  init(userID: String, tweetID: String, tweet: String) {
    let url: URL = .init(string: "https://twitter.com/\(userID)/status/\(tweetID)")!
    items = [url, ShareActivityItemSource(tweet)]
  }

  var body: some View {
    Button {
      isPresentedShareSheet.toggle()
    } label: {
      Image(systemName: "square.and.arrow.up")
    }
    .halfSheet(isPresented: $isPresentedShareSheet) {
      ShareSheet(items: items, activities: activities)
    }
  }
}

struct ShareButton_Previews: PreviewProvider {
  static var previews: some View {
    ShareButton(userID: "zunda_pixel", tweetID: "4234324242424233", tweet: "")
  }
}
