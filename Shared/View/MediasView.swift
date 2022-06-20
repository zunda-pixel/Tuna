//
//  MediasView.swift
//  Tuna
//
//  Created by zunda on 2022/06/19.
//

import SwiftUI
import Sweet
import Kingfisher

struct MediasView: View {
  let medias: [Sweet.MediaModel]

  @State var selectedMedia: Sweet.MediaModel?
  @State var isPresentedImageView = false

  var body: some View {
    let gridItem: GridItem = .init(.flexible())

    LazyVGrid(columns: [gridItem, gridItem]) {
      ForEach(medias) { media in
        let mediaURL = media.url ?? media.previewImageURL!

        KFImage(mediaURL)
          .placeholder { p in
            ProgressView(p)
          }
          .resizable()
          .scaledToFill()
          .frame(height: 100)
          .clipped()
          .onTapGesture {
            selectedMedia = media
            isPresentedImageView.toggle()
          }
      }
    }
    .fullScreenCover(isPresented: $isPresentedImageView) {
      ScrollImagesView(medias: medias, selectedMedia: $selectedMedia)
    }
  }
}

struct MediasView_Previews: PreviewProvider {
  static var previews: some View {
    MediasView(medias: [.init(key: "", type: .animatedGig, size: .init(width: 3, height: 4))])
  }
}
