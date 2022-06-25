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
        try await Sweet(userID: fromUserID).unMuteUser(from: fromUserID, to: toUserID)
      } else {
        try await Sweet(userID: fromUserID).muteUser(from: fromUserID, to: toUserID)
      }

      isMuted.toggle()
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
      Label(viewModel.isMuted ? "UnMute" : "Mute", systemImage: viewModel.isMuted ? "speaker" : "speaker.slash")
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

struct MuteButton_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel: MuteButtonViewModel = .init(from: "", to: "")
    MuteButton(viewModel: viewModel)
  }
}
