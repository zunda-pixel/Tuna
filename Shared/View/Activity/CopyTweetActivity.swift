//
//  CopyActivity.swift
//  Tuna
//
//  Created by zunda on 2022/06/01.
//

import Foundation
import UIKit

class CopyTweetActivity: UIActivity {
  override var activityType: UIActivity.ActivityType? { .copyToPasteboard }
  override var activityTitle: String? { "Copy Tweet"}

  override func prepare(withActivityItems activityItems: [Any]) {
    for item in activityItems {
      if let source = item as? ShareActivityItemSource {
        if let text = source.item as? String {
          UIPasteboard.general.string = text
          return
        }
      }
    }
  }

  override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
    activityItems.contains { $0 is String }
  }
}
