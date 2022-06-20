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
  let medias: [Sweet.MediaModel]
  @State var scales: [String: Double] = [:]
  @Binding var selectedMedia: Sweet.MediaModel
  @Environment(\.dismiss) var dismiss

  init(medias: [Sweet.MediaModel], selectedMedia: Binding<Sweet.MediaModel>) {
    self.medias = medias
    self._selectedMedia = selectedMedia

    medias.forEach { media in
      scales[media.id] = 1
    }
  }

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()
      TabView(selection: $selectedMedia) {
        ForEach(medias) { media in
          let mediaURL = media.url ?? media.previewImageURL!
          let magnification = MagnificationGesture()
            .onChanged { value in
              scales[media.id] = value
            }
            .onEnded { value in
              if value < 1 {
                withAnimation(.easeInOut) {
                  scales[media.id] = 1
                }
              }
            }
          ZStack {
            Color.black
            KFImage(mediaURL)
              .resizable()
              .scaleEffect(scales[media.id] ?? 1)
              .scaledToFit()
              .onTapGesture(count: 2) {
                withAnimation(.easeInOut) {
                  scales[media.id] = 1
                }
              }
              .onTapGesture(count: 1) {
                dismiss()
              }
              .gesture(magnification)
              .padding(.horizontal)
          }
            .gesture(magnification)
            .tag(media)
        }
      }
      .tabViewStyle(.page)
    }
  }
}
