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
  @StateObject var viewModel: ViewModel

  var body: some View {
    VStack {
      Text(viewModel.list.name)
      Text(viewModel.list.description!)

      HStack {
        NavigationLink(destination: {
          let listMembersViewModel = ListMembersViewModel(userID: viewModel.userID, listID: viewModel.list.id)
          UsersView(viewModel: listMembersViewModel)
        }) {
          Text("\(viewModel.list.memberCount!) members")
        }
        NavigationLink(destination: {
          let listFollowersViewModel = ListFollowersViewModel(userID: viewModel.userID, listID: viewModel.list.id)
          UsersView(viewModel: listFollowersViewModel)
        }) {
          Text("\(viewModel.list.followerCount!) followers")
        }
      }
    }

    let listTweetsViewModel: ListTweetsViewModel =  .init(userID: viewModel.userID, listID: viewModel.list.id)
    TweetsView(viewModel: listTweetsViewModel)
  }
}
