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

struct ListCellView: View {
  let delegate: ListCellDelegate
  let list: CustomListModel
  let owner: Sweet.UserModel
  let userID: String

  @State var didError = false
  @State var error: Error?

  @Binding var path: NavigationPath

  var body: some View {
    HStack {
      ProfileImageView(owner.profileImageURL)
        .frame(width: 50, height: 50)
        .onTapGesture {
          let userViewModel: UserViewModel = .init(userID: userID, user: owner)
          path.append(userViewModel)
        }

      VStack(alignment: .leading) {
        HStack {
          Text(list.list.name)
            .font(.title2)
          if list.list.isPrivate == true {
            Image(systemName: "key")
          }
          if let description = list.list.description {
            Text(description)
              .foregroundColor(.gray)
          }
        }
        .lineLimit(1)

        Text("\(owner.name) @\(owner.userName)")
          .lineLimit(1)
      }

      Spacer()

      Image(systemName: "pin")
        .if(list.isPinned) {
          $0.symbolVariant(.fill)
        }
        .onTapGesture {
          Task {
            if list.isPinned {
              await delegate.unPinList(listID: list.id)
            } else {
              await delegate.pinList(listID: list.id)
            }
          }
        }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      let listTweetsViewModel: ListTweetsViewModel = .init(userID: userID, listID: list.list.id)
      let listDetailViewModel: ListDetailViewModel = .init(userID: userID, list: list.list, tweetsViewModel: listTweetsViewModel)
      path.append(listDetailViewModel)
    }
  }
}
