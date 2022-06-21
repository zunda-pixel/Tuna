//
//  ScrollImagesView.swift
//  Tuna
//
//  Created by zunda on 2022/06/20.
//

import SwiftUI
import Sweet

struct ScrollImagesView: View {
  let medias: [Sweet.MediaModel]

  @Binding var selectedMedia: Sweet.MediaModel
  @Environment(\.dismiss) var dismiss

  init(medias: [Sweet.MediaModel], selectedMedia: Binding<Sweet.MediaModel>) {
    self.medias = medias
    self._selectedMedia = selectedMedia
  }

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()
      TabView(selection: $selectedMedia) {
        ForEach(medias) { media in
          let mediaURL = media.url ?? media.previewImageURL!

          ScalableImage(mediaURL: mediaURL)
            .tag(media)
        }
      }
      .tabViewStyle(.page)
    }
  }
}
