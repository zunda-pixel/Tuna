//
//  UIImage+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/04/07.
//

import AVKit
import Foundation
import SwiftUI

extension UIImage {
  static func thumbnail(viewURL url: URL) async throws -> Self {
    let asset: AVAsset = .init(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    let duration = try await asset.load(.duration)
    let cgImage = try generator.copyCGImage(at: duration, actualTime: nil)
    return self.init(cgImage: cgImage)
  }
}
