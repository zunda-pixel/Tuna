//
//  MuteButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

@MainActor final class MuteButtonViewModel: ObservableObject {
  let fromUserID: String
  let toUserID: String

  var error: Error?

  @Published var loading = false
  @Published var didError = false
  @Published var isMuted = false

  init(from fromUserID: String, to toUserID: String) {
    self.fromUserID = fromUserID
    self.toUserID = toUserID
  }

  func muteOrUnMuteUser() async {
    do {
      if isMuted {
        try await Sweet().unMuteUser(from: fromUserID, to: toUserID)
      } else {
        try await Sweet().muteUser(from: fromUserID, to: toUserID)
      }

      isMuted.toggle()
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  func fetchMutingUser(paginationToken: String? = nil) async {
    loading = true

    defer {
      loading = false
    }

    do {
      let response = try await Sweet().fetchMuting(by: fromUserID, paginationToken: paginationToken)

      let isContain = response.users.contains { $0.id == fromUserID }

      isMuted = isContain

      if let nextToken = response.meta?.nextToken, !isContain {
        await fetchMutingUser(paginationToken: nextToken)
      }
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

}

struct MuteButton: View {
  @StateObject var viewModel: MuteButtonViewModel

  var body: some View {
    Button {
      Task {
        await viewModel.muteOrUnMuteUser()
      }
    } label: {
      Text(viewModel.isMuted ? "UnMute" : "Mute")
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
        await viewModel.fetchMutingUser()
      }
    }

  }
}

struct MuteButton_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel: MuteButtonViewModel = .init(from: "", to: "")
    MuteButton(viewModel: viewModel)
  }
}
