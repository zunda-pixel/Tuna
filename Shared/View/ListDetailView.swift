//
//  ListDetailView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import SwiftUI
import Sweet

struct ListDetailView: View {
  public let list: Sweet.ListModel
  
  private var paginationToken: String? = nil
  @State private var tweets: [Sweet.TweetModel] = []
  
  public init(list: Sweet.ListModel) {
    self.list = list
  }
  
  func asd() async throws {
    let response = try await Sweet().fetchListTweets(listID: list.id, maxResults: 100, paginationToken: paginationToken)
    self.tweets = response.tweets
  }
  
  var body: some View {
    VStack {
      Text(list.name)
      Text(list.description!)
      
      HStack {
        Text("\(list.memberCount!) members")
        Text("\(list.followerCount!) followers")
      }
    }
    
    ForEach(tweets, id: \.id) { tweet in
      //TweetView(viewModel: .)
      Text(tweet.text)
    }
  }
}

struct ListDetailView_Previews: PreviewProvider {
  static var previews: some View {
    ListDetailView(list: .init(id: "", name: ""))
  }
}
