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
  let likeCount: Int

  var error: Error?

  @Published var loading = false
  @Published var didError = false
  @Published var isLiked = false

  init(user userID: String, tweet tweetID: String, likeCount: Int) {
    self.userID = userID
    self.tweetID = tweetID
    self.likeCount = likeCount
  }

  func likeOrLikeUser() async {
    do {
      if isLiked {
        try await Sweet(userID: userID).like(userID: userID, tweetID: tweetID)
      } else {
        try await Sweet(userID: userID).unLike(userID: userID, tweetID: tweetID)
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
      Text("\(Image(systemName: "heart")) \(viewModel.likeCount)")
    }
    .tint(viewModel.isLiked ? .pink : .gray)
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
      LikeButton(viewModel: .init(user: "", tweet: "", likeCount: 12))
    }
}
