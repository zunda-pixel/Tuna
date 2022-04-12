//
//  MediaModel+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/24.
//

import Foundation
import Sweet
import CoreGraphics

extension Sweet.MediaModel {
	init(media: Media) {
    let size: CGSize = .init(width: media.width, height: media.height)
    let type: Sweet.MediaType = .init(rawValue: media.type!)!
    self.init(key: media.key!, type: type, size: size, previewImageURL: media.previewImageURL, url: media.url)
  }
}
