//
//  BlockButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

@MainActor final class BlockButtonViewModel: ObservableObject {
  let fromUserID: String
  let toUserID: String

  var error: Error?

  @Published var loading = false
  @Published var didError = false
  @Published var isBlocked = false

  init(from fromUserID: String, to toUserID: String) {
    self.fromUserID = fromUserID
    self.toUserID = toUserID
  }

  func blockOrUnBlockUser() async {
    do {
      if isBlocked {
        try await Sweet().unBlockUser(from: fromUserID, to: toUserID)
      } else {
        try await Sweet().blockUser(from: fromUserID, to: toUserID)
      }

      isBlocked.toggle()
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }
}


struct BlockButton: View {
  @StateObject var viewModel: BlockButtonViewModel

  var body: some View {
    Button {
      Task {
        await viewModel.blockOrUnBlockUser()
      }
    } label: {
      Label(viewModel.isBlocked ? "UnBlock" : "Block", systemImage: viewModel.isBlocked ? "person.fill" : "person.fill.xmark")
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

struct BlockButton_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel: BlockButtonViewModel = .init(from: "", to: "")
    BlockButton(viewModel: viewModel)
  }
}
