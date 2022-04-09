//
//  LivePhoto.swift
//  Tuna
//
//  Created by zunda on 2022/04/07.
//

import SwiftUI
import PhotosUI

struct LivePhoto: UIViewRepresentable {
  let livePhoto: PHLivePhoto
  
  func makeUIView(context: Context) -> PHLivePhotoView {
      let livePhotoView = PHLivePhotoView()
      livePhotoView.livePhoto = livePhoto
      return livePhotoView
  }
  
  func updateUIView(_ livePhotoView: PHLivePhotoView, context: Context) {
  }
}
