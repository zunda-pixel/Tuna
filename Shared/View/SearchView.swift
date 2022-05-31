//
//  SearchView.swift
//  Tuna
//
//  Created by zunda on 2022/04/18.
//

import SwiftUI
import Sweet

struct SearchView<ViewModel: SearchViewProtocol>: View {
  @StateObject var viewModel: ViewModel

  enum Pages: String, CaseIterable, Identifiable {
    case user = "User"
    case tweet = "Tweet"

    var id: String { self.rawValue }
  }

  @State var selection: Pages = .tweet

  var body: some View {
    NavigationView {
      VStack {
        Picker("Menu", selection: $selection) {
          ForEach(Pages.allCases) { page in
            Text(page.rawValue)
              .tag(page)
          }
        }
        .pickerStyle(.segmented)

        TabView(selection: $selection) {
          TweetsView(viewModel: viewModel.tweetsViewModel)
            .tag(Pages.tweet)
          Text("User")
          //UsersView(viewModel: .)
            .tag(Pages.user)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }

    }
    .navigationViewStyle(.stack)
    .searchable(text: $viewModel.tweetsViewModel.searchText, prompt: Text("Search Keyword"))
    .refreshable {
      await viewModel.tweetsViewModel.fetchTweets(first: nil, last: nil)
    }
    .onSubmit(of: .search) {
      Task {
        let firstTweetID = viewModel.tweetsViewModel.showTweets.first?.id
        await viewModel.tweetsViewModel.fetchTweets(first: firstTweetID, last: nil)
      }

      Task {
        //await searchUser()
      }
    }
  }
}
