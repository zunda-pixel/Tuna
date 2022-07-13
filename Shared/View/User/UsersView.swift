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
  @Binding var path: NavigationPath

  var body: some View {
    List(viewModel.users) { user in
      UserCellView(ownerID: viewModel.userID, user: user, path: $path)
        .onAppear {
          if viewModel.users.last?.id == user.id {
            Task {
              await viewModel.fetchUsers(reset: false)
            }
          }
        }
    }
    .alert("Error", isPresented: $viewModel.didError) {
      Button {
        print(viewModel.error!)
      } label: {
        Text("Close")
      }
    }
    .refreshable {
      await viewModel.fetchUsers(reset: true)
    }
    .onAppear {
      Task {
        await viewModel.fetchUsers(reset: false)
      }
    }
  }
}
