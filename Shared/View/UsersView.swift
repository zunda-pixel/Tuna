//
//  UsersView.swift
//  Tuna
//
//  Created by zunda on 2022/04/25.
//

import SwiftUI
import Sweet

struct UsersView<ViewModel: UsersViewProtocol>: View {
  @StateObject var viewModel: ViewModel

  var body: some View {
    let ownerID = Secret.currentUserID!
    List(viewModel.users) { user in
      UserCellView(ownerID: ownerID, user: user)
    }
    .listStyle(.plain)
    .alert("Error", isPresented: $viewModel.didError) {
      Button {
        print(viewModel.error!)
      } label: {
        Text("Close")
      }
    }
    .onAppear {
      Task {
        await viewModel.fetchUsers()
      }
    }
  }
}
