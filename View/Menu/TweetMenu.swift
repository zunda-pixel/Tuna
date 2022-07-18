//
//  TweetMenu.swift
//  Tuna
//
//  Created by zunda on 2022/06/16.
//

import SwiftUI

struct TweetMenu: View {
  @State var isPresentedDeleteTweetAlert = false

  let userID: String
  let tweetID: String

  func removeTweet() {

  }

  var body: some View {
    Menu {
      let url: URL = .init(string: "https://twitter.com/\(userID)/status/\(tweetID)")!
      ShareLink(item: url) {
        Label("Share", systemImage: "square.and.arrow.up")
      }

      Button {
        isPresentedDeleteTweetAlert.toggle()
      } label: {
        Label("Delete Tweet", systemImage: "minus.square")
      }
    } label: {
      Image(systemName: "gear")
    }
    .alert("Delete Tweet", isPresented: $isPresentedDeleteTweetAlert) {
      Button(role: .cancel) {
      } label: {
        Text("Cancel")
      }

      Button(role: .destructive) {
        removeTweet()
      } label: {
        Text("Delete")
      }
    }
  }
}

struct TweetMenu_Previews: PreviewProvider {
  static var previews: some View {
    TweetMenu(userID: "", tweetID: "'")
  }
}
