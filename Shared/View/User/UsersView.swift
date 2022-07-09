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
      let userViewModel: UserViewModel = .init(userID: viewModel.userID, user: user)
      UserCellView(ownerID: viewModel.userID, user: user)
        .onTapGesture {
          path.append(userViewModel)
        }
        .onAppear {
          if viewModel.users.last?.id == user.id {
            Task {
              await viewModel.fetchUsers(reset: false)
            }
          }
        }
    }
    .listStyle(.plain)
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
