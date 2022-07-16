import SwiftUI
import PhotosUI

struct LivePhotoView: UIViewRepresentable {
  let livePhoto: PHLivePhoto

  func makeUIView(context: Context) -> PHLivePhotoView {
    let livePhotoView = PHLivePhotoView(frame: .zero)
    livePhotoView.livePhoto = livePhoto
    return livePhotoView
  }

  func updateUIView(_ livePhotoView: PHLivePhotoView, context: Context) {
  }
}
