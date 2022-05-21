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
        .clipShape(Circle())
    }
  }
}

struct ProfileImageView_Previews: PreviewProvider {
  static var previews: some View {
    let url: URL = .init(
      string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_400x400.png")!
    ProfileImageView(url)
      .frame(width: 100, height: 100)
  }
}
