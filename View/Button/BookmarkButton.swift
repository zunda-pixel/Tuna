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
    guard !loading else { return }

    loading.toggle()

    do {
      if isBookmarked {
        try await Sweet(userID: userID).addBookmark(userID: userID, tweetID: tweetID)
      } else {
        try await Sweet(userID: userID).deleteBookmark(userID: userID, tweetID: tweetID)
      }

      isBookmarked.toggle()

    } catch let newError {
      error = newError
      didError.toggle()
    }

    loading.toggle()
  }
}

struct BookmarkButton: View {
  @StateObject var viewModel: BookmarkButtonViewModel

  var body: some View {
    let imageName = viewModel.isBookmarked ? "bookmark.slash" : "bookmark"
    Label("Bookmark", systemImage: imageName)
      .labelStyle(.iconOnly)
      .onTapGesture {
        Task {
          await viewModel.addOrDeleteBookmark()
        }
      }
      .alert("Error", isPresented: $viewModel.didError) {
        Button("Close") {
          print(viewModel.error!)
        }
      }
  }
}

struct BookmarkButton_Previews: PreviewProvider {
  static var previews: some View {
    BookmarkButton(viewModel: .init(user: "", tweet: ""))
  }
}


