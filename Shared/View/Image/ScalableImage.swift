//
//  ScalableImage.swift
//  Tuna
//
//  Created by zunda on 2022/06/20.
//

import SwiftUI
import Kingfisher

struct ScalableImage: View {
  @State var scale: Double = 1
  let mediaURL: URL

  func restScale() {
    withAnimation(.easeInOut) {
      scale = 1
    }
  }

  var body: some View {
    let magnification = MagnificationGesture()
      .onChanged { value in
       scale = value
      }
      .onEnded { value in
        if value < 1 {
          restScale()
        }
      }

    ZStack {
      Color.black
      KFImage(mediaURL)
        .resizable()
        .scaleEffect(scale)
        .scaledToFit()
        .onTapGesture(count: 2) {
          restScale()
        }
        .gesture(magnification)
        .padding(.horizontal)
    }
      .gesture(magnification)
  }
}

struct ScalableImage_Previews: PreviewProvider {
    static var previews: some View {
      ScalableImage(mediaURL: .init(string: "")!)
    }
}
