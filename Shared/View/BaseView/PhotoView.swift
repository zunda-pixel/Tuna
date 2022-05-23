//
//  PhotoView.swift
//  Tuna
//
//  Created by zunda on 2022/04/07.
//

import AVKit
import PhotosUI
import SwiftUI

struct PhotoView: View {
  let provider: NSItemProvider

  @Binding var item: NSItemProviderReading?
  @State var tappedImage = false
  @State var tappedLivePhoto = false
  @State var isPresentedVideoPlayer = false

  var body: some View {
    GeometryReader { geometry in
      if let item = item {
        if let livePhoto = item as? PHLivePhoto {
          LivePhoto(livePhoto: livePhoto)
            .onTapGesture {
              tappedLivePhoto = true
            }
            .sheet(isPresented: $tappedLivePhoto) {
              LivePhoto(livePhoto: livePhoto)
            }
        } else if let uiImage = item as? UIImage {
          Image(uiImage: uiImage)
            .resizable()
            .onTapGesture {
              tappedImage = true
            }
            .sheet(isPresented: $tappedImage) {
              Image(uiImage: uiImage)
                .resizable()
            }
        } else if let url = item as? URL {
          ZStack {
            let uiImage = try! UIImage(videoURL: url)
            Image(uiImage: uiImage)
              .resizable()

            Image(systemName: "play")
          }
          .onTapGesture {
            isPresentedVideoPlayer.toggle()
          }
          .sheet(isPresented: $isPresentedVideoPlayer) {
            let player: AVPlayer = .init(url: url)
            VideoPlayer(player: player)
              .onAppear {
                player.play()
              }
          }
        }
      }
    }
    .onAppear {
      Task {
        if item == nil {
          do {
            item = try await provider.loadPhoto()
          } catch {
            print(error)
          }
        }
      }
    }
  }
}
