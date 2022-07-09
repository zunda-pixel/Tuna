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
    let user = viewModel.tweet.referencedTweet?.type == .retweeted ? viewModel.retweet!.user : viewModel.author

    HStack(alignment: .top) {
      ProfileImageView(user.profileImageURL)
        .frame(width: 50, height: 50)
        .onTapGesture {
          viewModel.isPresentedUserView.toggle()
        }

      VStack(alignment: .leading) {
        HStack {
          if let userName = user.userName {
            (Text(user.name) + Text(" @\(userName)").foregroundColor(.gray))
              .lineLimit(1)
          }

          Spacer()

          if let type = viewModel.tweet.referencedTweet?.type, type == .repliedTo {
            Image(systemName: "bubble.left.and.bubble.right")
          }

          TimelineView(.periodic(from: .now, by: 1)) { context in
            let duration = viewModel.duration(nowDate: context.date)
            Text(duration)
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
          QuotedTweetCellView(tweet: quoted.tweet, user: quoted.user)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.gray, lineWidth: 2))
        }

        if viewModel.tweet.referencedTweet?.type == .retweeted {
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
    .navigationDestination(isPresented: $viewModel.isPresentedUserView) {
      UserView(userID: viewModel.userID, user: user, path: $path)
        .environment(\.managedObjectContext, viewContext)
        .navigationTitle("@\(user.userName)")
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}
