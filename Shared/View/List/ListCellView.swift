//
//  ListView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import Sweet
import SwiftUI

protocol ListCellDelegate {
  func pinList(listID: String) async
  func unPinList(listID: String) async
}

final class ListCellViewModel: ObservableObject, Hashable {
  static func == (lhs: ListCellViewModel, rhs: ListCellViewModel) -> Bool {
    lhs.list.id == rhs.list.id && lhs.owner == rhs.owner && lhs.userID == rhs.userID
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(list)
    hasher.combine(owner)
    hasher.combine(userID)
  }

  let delegate: ListCellDelegate
  let list: CustomListModel
  let owner: Sweet.UserModel
  let userID: String

  @Published var didError = false
  @Published var error: Error?

  init(delegate: ListCellDelegate, list: CustomListModel, owner: Sweet.UserModel, userID: String) {
    self.delegate = delegate
    self.list = list
    self.owner = owner
    self.userID = userID
  }
}

struct ListCellView: View {
  @StateObject var viewModel: ListCellViewModel
  @Binding var path: NavigationPath

  var body: some View {
    HStack {
      ProfileImageView(viewModel.owner.profileImageURL)
        .frame(width: 50, height: 50)
        .onTapGesture {
          let userViewModel: UserViewModel = .init(userID: viewModel.userID, user: viewModel.owner)
          path.append(userViewModel)
        }

      VStack(alignment: .leading) {
        HStack {
          Text(viewModel.list.list.name)
            .font(.title2)
          if viewModel.list.list.isPrivate == true {
            Image(systemName: "key")
          }
          if let description = viewModel.list.list.description {
            Text(description)
              .foregroundColor(.gray)
          }
        }
        .lineLimit(1)

        Text("\(viewModel.owner.name) @\(viewModel.owner.userName)")
          .lineLimit(1)
      }

      Spacer()

      Image(systemName: "pin")
        .if(viewModel.list.isPinned) {
          $0.symbolVariant(.fill)
        }
        .onTapGesture {
          Task {
            if viewModel.list.isPinned {
              await viewModel.delegate.unPinList(listID: viewModel.list.id)
            } else {
              await viewModel.delegate.pinList(listID: viewModel.list.id)
            }
          }
        }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      let listTweetsViewModel: ListTweetsViewModel = .init(userID: viewModel.userID, listID: viewModel.list.list.id)
      let listDetailViewModel: ListDetailViewModel = .init(userID: viewModel.userID, list: viewModel.list.list, tweetsViewModel: listTweetsViewModel)
      path.append(listDetailViewModel)
    }
  }
}
