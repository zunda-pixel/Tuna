import SwiftUI
import Photos

struct PhotoView: View {
  let photo: Photo

  var body: some View {
    switch photo.item {
      case let livePhoto as PHLivePhoto:
        LivePhotoView(livePhoto: livePhoto)
      case let movie as Movie:
        Text(movie.url.absoluteString)
      case let uiImage as UIImage:
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
      default:
        Text("hello")
    }
  }
}
