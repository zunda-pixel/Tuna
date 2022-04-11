//
//  UIImage+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/04/07.
//

import Foundation
import SwiftUI
import AVKit

extension UIImage {
  public convenience init(videoURL url: URL) throws {
    let asset: AVAsset = .init(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    let cgImage = try generator.copyCGImage(at: asset.duration, actualTime: nil)
    self.init(cgImage: cgImage)
  }
}
