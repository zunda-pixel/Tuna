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
  @State var image: Any?

  func load(item: NSItemProviderReading?) async throws -> Any? {
    switch item {
      case let livePhoto as PHLivePhoto:
        return livePhoto
      case let uiImage as UIImage:
        return uiImage
      case let url as URL:
        let thumbnail = try await UIImage.thumbnail(viewURL: url)
        return (url: url, thumbnail: thumbnail)
      default:
        return nil
    }
  }

  var body: some View {
    GeometryReader { geometry in
      if let image {
        switch image {
          case let livePhoto as PHLivePhoto:
            LivePhoto(livePhoto: livePhoto)
              .onTapGesture {
                tappedLivePhoto = true
              }
              .sheet(isPresented: $tappedLivePhoto) {
                LivePhoto(livePhoto: livePhoto)
              }
          case let uiImage as UIImage:
            Image(uiImage: uiImage)
              .resizable()
              .onTapGesture {
                tappedImage = true
              }
              .sheet(isPresented: $tappedImage) {
                Image(uiImage: uiImage)
                  .resizable()
              }
          case let videoItem as (url: URL, thumbnail: UIImage):
            ZStack {
              Image(uiImage: videoItem.thumbnail)
                .resizable()

              Image(systemName: "play")
            }
            .onTapGesture {
              isPresentedVideoPlayer.toggle()
            }
            .sheet(isPresented: $isPresentedVideoPlayer) {
              let player: AVPlayer = .init(url: videoItem.url)
              VideoPlayer(player: player)
                .onAppear {
                  player.play()
                }
            }
          default:
            EmptyView()
        }
      }

    }
    .onAppear {
      Task {
        if item == nil {
          do {
            item = try await provider.loadPhoto()
            image = try await load(item: item)
          } catch {
            print(error)
          }
        }
      }
    }
  }
}
