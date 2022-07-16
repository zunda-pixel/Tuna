//
//  Media+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/24.
//

import Foundation
import Sweet

extension Media {
  func setMediaModel(_ media: Sweet.MediaModel) {
    self.key = media.key
    self.width = media.size.width
    self.height = media.size.height
    self.url = media.url
    self.previewImageURL = media.previewImageURL
    self.type = media.type.rawValue
  }
}
