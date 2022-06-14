//
//  RetweetButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

@MainActor final class RetweetButtonViewModel: ObservableObject {
  let userID: String
  let tweetID: String
  let retweetCount: Int
  var error: Error?


  @Published var loading = false
  @Published var didError = false
  @Published var isRetweeted = false

  init(user userID: String, tweet tweetID: String, retweetCount: Int) {
    self.userID = userID
    self.tweetID = tweetID
    self.retweetCount = retweetCount
  }

  func retweetOrRetweetUser() async {
    do {
      if isRetweeted {
        try await Sweet().retweet(userID: userID, tweetID: tweetID)
      } else {
        try await Sweet().deleteRetweet(userID: userID, tweetID: tweetID)
      }

      isRetweeted.toggle()
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }
}

struct RetweetButton: View {
  @StateObject var viewModel: RetweetButtonViewModel

  var body: some View {
    Button {
      Task {
        await viewModel.retweetOrRetweetUser()
      }
    } label: {
      Text("\(Image(systemName: "arrow.rectanglepath")) \(viewModel.retweetCount)")
    }
    .tint(viewModel.isRetweeted ? .green : .gray)
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

struct RetweetButton_Previews: PreviewProvider {
  static var previews: some View {
    RetweetButton(viewModel: .init(user: "", tweet: "", retweetCount: 12))
  }
}

