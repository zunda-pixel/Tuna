//
//  FollowButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

@MainActor final class FollowButtonViewModel: ObservableObject {
  let fromUserID: String
  let toUserID: String

  var error: Error?

  @Published var loading = false
  @Published var didError = false
  @Published var isFollowed = false

  init(from fromUserID: String, to toUserID: String) {
    self.fromUserID = fromUserID
    self.toUserID = toUserID
  }

  func followOrUnFollowUser() async {
    do {
      if isFollowed {
        try await Sweet().unFollow(from: fromUserID, to: toUserID)
      } else {
        _ = try await Sweet().follow(from: fromUserID, to: toUserID)
      }

      isFollowed.toggle()
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  func fetchFollowingUsers(paginationToken: String? = nil) async {
    loading = true

    defer {
      loading = false
    }

    do {
      let response = try await Sweet().fetchFollowing(by: fromUserID, paginationToken: paginationToken)

      let isContain = response.users.contains { $0.id == fromUserID }

      isFollowed = isContain

      if let nextToken = response.meta?.nextToken, !isContain {
        await fetchFollowingUsers(paginationToken: nextToken)
      }
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }
}


struct FollowButton: View {
  @StateObject var viewModel: FollowButtonViewModel

  var body: some View {
    Button {
      Task {
        await viewModel.followOrUnFollowUser()
      }
    } label: {
      Text(viewModel.isFollowed ? "UnFollow" : "Follow")
    }
    .disabled(viewModel.loading)
    .alert("Error", isPresented: $viewModel.didError) {
      Button {
        print(viewModel.error!)
      } label: {
        Text("Close")
      }
    }
    .onAppear {
      Task {
        await viewModel.fetchFollowingUsers()
      }
    }

  }
}

struct FollowButton_Previews: PreviewProvider {
    static var previews: some View {
      let viewModel: FollowButtonViewModel = .init(from: "", to: "")
      FollowButton(viewModel: viewModel)
    }
}
