//
//  ProfileImageView.swift
//  Tuna
//
//  Created by zunda on 2022/03/24.
//

import Kingfisher
import SwiftUI

struct ProfileImageView: View {
  let url: URL?

  init(_ url: URL?) {
    guard let url = url else {
      self.url = nil
      return
    }

    let urlString = url.absoluteString.replacingOccurrences(of: "_normal", with: "")

    self.url = .init(string: urlString)!
  }

  var body: some View {
    GeometryReader{ geometry in
      KFImage(url)
        .resizable()
        .frame(width: geometry.size.width, height: geometry.size.height)
        .background(.gray.opacity(0.1))
        .clipShape(Circle())
        .overlay {
            Circle().stroke(.gray, lineWidth: 2)
              .shadow(radius: 7)
        }
    }
  }
}

struct ProfileImageView_Previews: PreviewProvider {
  static var previews: some View {
    let url: URL = .init(
      string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk.jpg")!
    ProfileImageView(url)
      .frame(width: 100, height: 100)
  }
}
