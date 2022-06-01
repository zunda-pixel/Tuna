//
//  CopyTweetLinkActivity.swift
//  Tuna
//
//  Created by zunda on 2022/06/01.
//

import Foundation
import UIKit

class CopyTweetLinkActivity: UIActivity {
  override var activityType: UIActivity.ActivityType? { .copyToPasteboard }
  override var activityTitle: String? { "Copy Tweet Link "}

  override func prepare(withActivityItems activityItems: [Any]) {
    for item in activityItems {
      if let url = item as? URL {
        UIPasteboard.general.url = url
      }
    }
  }

  override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
    activityItems.contains { $0 is URL }
  }
}
