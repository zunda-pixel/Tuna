//
//  LikeButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

@MainActor final class LikeButtonViewModel: ObservableObject {
  let userID: String
  let tweetID: String

  var error: Error?

  @Published var loading = false
  @Published var didError = false
  @Published var isLiked = false

  init(user userID: String, tweet tweetID: String) {
    self.userID = userID
    self.tweetID = tweetID
  }

  func likeOrLikeUser() async {
    do {
      if isLiked {
        try await Sweet().like(userID: userID, tweetID: tweetID)
      } else {
        try await Sweet().unLike(userID: userID, tweetID: tweetID)
      }

      isLiked.toggle()
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }
}

struct LikeButton: View {
  @StateObject var viewModel: LikeButtonViewModel

  var body: some View {
    Button {
      Task {
        await viewModel.likeOrLikeUser()
      }
    } label: {
      Image(systemName: "heart")
        .tint(viewModel.isLiked ? .pink : .blue)
    }
    .disabled(viewModel.loading)
    .alert("Error", isPresented: $viewModel.didError) {
      Button {
        print(viewModel.error!)
      } label: {
        Text("Close")
      }
    }
  }
}

struct LikeButton_Previews: PreviewProvider {
    static var previews: some View {
      LikeButton(viewModel: .init(user: "", tweet: ""))
    }
}
