//
//  ScrollImagesView.swift
//  Tuna
//
//  Created by zunda on 2022/06/20.
//

import SwiftUI
import Sweet
import Kingfisher

struct ScrollImagesView: View {
  @Environment(\.dismiss) var dismiss

  let medias: [Sweet.MediaModel]

  @Binding var selectedMedia: Sweet.MediaModel

  var body: some View {
    TabView(selection: $selectedMedia) {
      ForEach(medias) { media in
        let mediaURL = media.url ?? media.previewImageURL!
        ZStack {
          Color.black
            .ignoresSafeArea()
          KFImage(mediaURL)
            .resizable()
            .scaledToFit()
            .onTapGesture {
              dismiss()
            }
        }
        .tag(media)
      }
    }
    .ignoresSafeArea()
    .tabViewStyle(.page)
  }
}
