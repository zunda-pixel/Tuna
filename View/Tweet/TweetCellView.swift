//
//  TweetView.swift
//  Tuna
//
//  Created by zunda on 2022/03/22.
//

import Kingfisher
import Sweet
import SwiftUI

struct TweetCellView<ViewModel: TweetCellViewProtocol>: View {
  @Environment(\.openURL) private var openURL
  @Environment(\.managedObjectContext) private var viewContext

  @Binding var path: NavigationPath

  @StateObject var viewModel: ViewModel

  var body: some View {
    let isRetweeted = viewModel.tweet.referencedTweets.contains(where: { $0.type == .retweeted})

    let user = isRetweeted ? viewModel.retweet!.user : viewModel.author

    HStack(alignment: .top) {
      ProfileImageView(user.profileImageURL)
        .frame(width: 50, height: 50)
        .onTapGesture {
          let userViewModel: UserViewModel = .init(userID: viewModel.userID, user: user)
          path.append(userViewModel)
        }

      VStack(alignment: .leading) {
        HStack {
          (Text(user.name) + Text(" @\(user.userName)").foregroundColor(.gray))
              .lineLimit(1)

          Spacer()

          let isReply = viewModel.tweet.referencedTweets.contains(where: { $0.type == .repliedTo })
          if isReply {
            Image(systemName: "bubble.left.and.bubble.right")
          }

          TimelineView(.periodic(from: .now, by: 1)) { context in
            let range = viewModel.showDate..<context.date
            Text(range, format: .twitter)
          }
        }

        Text(viewModel.tweetText)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)

        if let poll = viewModel.poll {
          PollView(poll: poll)
        }

        MediasView(medias: viewModel.medias)

        if let placeName = viewModel.place?.name {
          Text(placeName)
            .onTapGesture {
              var components: URLComponents = .init(string: "http://maps.apple.com/")!
              components.queryItems = [.init(name: "q", value: placeName)]
              openURL(components.url!)
            }
            .foregroundColor(.gray)
        }

        if let quoted = viewModel.quoted {
          QuotedTweetCellView(userID: viewModel.userID, tweet: quoted.tweet, user: quoted.user)
            .contentShape(Rectangle())
            .onTapGesture {
              let tweetDetailView: TweetDetailViewModel = .init(cellViewModel: viewModel)
              path.append(tweetDetailView)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.gray, lineWidth: 2))
        }

        if isRetweeted {
          HStack {
            Image(systemName: "repeat")
              .font(.system(size: 15, weight: .medium, design: .default))
            ProfileImageView(viewModel.author.profileImageURL)
              .frame(width: 20, height: 20)
            Text(viewModel.author.name)
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

      Text(viewModel.error.debugDescription)
    } message: {
      Button("Report") {
      }
    }
  }
}
