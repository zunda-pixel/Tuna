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
          let viewModel = ListMembersViewModel(listID: viewModel.list.id)
          UsersView(viewModel: viewModel)
        }) {
          Text("\(viewModel.list.memberCount!) members")
        }
        NavigationLink(destination: {
          Text("未実施")
        }) {
          Text("\(viewModel.list.followerCount!) followers")
        }
      }
    }

    List(viewModel.timelines, id: \.self) { tweetID in

      let cellViewModel = viewModel.getTweetCellViewModel(tweetID)
      TweetCellView(viewModel: cellViewModel)
        .environment(\.managedObjectContext, viewContext)
        .onAppear {
          guard let lastTweetID = viewModel.timelines.last else{
            return
          }

          if tweetID == lastTweetID {
            Task {
              await viewModel.fetchTweets()
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
    .onAppear {
      Task {
        await viewModel.fetchTweets()
      }
    }
    .refreshable {
      await viewModel.fetchTweets()
    }
  }
}

struct ListDetailView_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel: ListDetailViewModel = .init(list: .init(id: "", name: ""))
    ListDetailView(viewModel: viewModel)
  }
}
