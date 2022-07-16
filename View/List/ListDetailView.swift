//
//  ListDetailView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import Sweet
import SwiftUI

struct ListDetailView<ViewModel:  ListDetailViewProtocol>: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Binding var path: NavigationPath
  @StateObject var viewModel: ViewModel

  var body: some View {
    VStack {
      Text(viewModel.list.name)
      Text(viewModel.list.description!)

      HStack {
        let listMembersViewModel = ListMembersViewModel(userID: viewModel.userID, listID: viewModel.list.id)

        NavigationLink(value: listMembersViewModel) {
          Text("\(viewModel.list.memberCount!) members")
        }

        let listFollowersViewModel = ListFollowersViewModel(userID: viewModel.userID, listID: viewModel.list.id)

        NavigationLink(value: listFollowersViewModel) {
          Text("\(viewModel.list.followerCount!) followers")
        }
      }
      Spacer()
      let listTweetsViewModel: ListTweetsViewModel =  .init(userID: viewModel.userID, listID: viewModel.list.id)
      TweetsView(viewModel: listTweetsViewModel, path: $path)
    }
  }
}
