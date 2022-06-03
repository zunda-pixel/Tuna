//
//  BookmarkButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

@MainActor final class BookmarkButtonViewModel: ObservableObject {
  let userID: String
  let tweetID: String

  var error: Error?

  @Published var loading = false
  @Published var didError = false
  @Published var isBookmarked = false

  init(user userID: String, tweet tweetID: String) {
    self.userID = userID
    self.tweetID = tweetID
  }

  func addOrDeleteBookmark() async {
    do {
      if isBookmarked {
        try await Sweet().addBookmark(userID: userID, tweetID: tweetID)
      } else {
        try await Sweet().deleteBookmark(userID: userID, tweetID: tweetID)
      }

      isBookmarked.toggle()
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }
}

struct BookmarkButton: View {
  @StateObject var viewModel: BookmarkButtonViewModel

  var body: some View {
    Button {
      Task {
        await viewModel.addOrDeleteBookmark()
      }
    } label: {
      Image(systemName: viewModel.isBookmarked ? "bookmark.slash" : "bookmark")
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

struct BookmarkButton_Previews: PreviewProvider {
    static var previews: some View {
      BookmarkButton(viewModel: .init(user: "", tweet: ""))
    }
}


