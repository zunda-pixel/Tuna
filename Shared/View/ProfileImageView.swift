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
  let size: CGFloat

  init(_ url: URL?, size: CGFloat) {
    self.url = url
    self.size = size
  }

  var body: some View {
    KFImage(url)
      .resizable()
      .frame(width: size, height: size)
      .clipShape(Circle())
  }
}

struct ProfileImageView_Previews: PreviewProvider {
  static var previews: some View {
    let url: URL = .init(
      string: "https://abs.twimg.com/sticky/default_profile_images/default_profile_400x400.png")!
    let size = UIScreen.main.bounds.width
    ProfileImageView(url, size: size)
  }
}
