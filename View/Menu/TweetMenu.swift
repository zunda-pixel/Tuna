//
//  TweetMenu.swift
//  Tuna
//
//  Created by zunda on 2022/06/16.
//

import SwiftUI

struct TweetMenu: View {
  @State var isPresentedDeleteTweetAlert = false
  func removeTweet() {

  }

  var body: some View {
    Menu {
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
    TweetMenu()
  }
}
