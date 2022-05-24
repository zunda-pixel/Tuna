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
  @Environment(\.managedObjectContext) private var viewContext
  @StateObject var viewModel: ViewModel

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(viewModel.iconUser.profileImageURL)
        .frame(width: 50, height: 50)
        .onTapGesture {
          viewModel.isPresentedUserView.toggle()
        }

      NavigationLink(isActive: $viewModel.isPresentedUserView) {
        UserView(user: viewModel.iconUser)
          .navigationBarTitle("@\(viewModel.iconUser.userName)")
          .environment(\.managedObjectContext, viewContext)
      } label: {
        EmptyView()
      }
      .frame(width: 0, height: 0)
      .hidden()

      VStack(alignment: .leading) {
        HStack {
          if let userName = viewModel.iconUser.userName {
            (Text(viewModel.iconUser.name) + Text(" @\(userName)").foregroundColor(.gray))
              .lineLimit(1)
          }

          Spacer()

          if let type = viewModel.tweet.referencedTweet?.type, type == .repliedTo {
            Image(systemName: "bubble.left.and.bubble.right")
          }

          Text(viewModel.duration)
        }

        Text(viewModel.tweetText)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)

        if let poll = viewModel.poll {
          VStack {
            ForEach(poll.options) { option in
              GeometryReader { geometry in
                HStack {
                  ZStack {
                    Text(option.label)
                      .frame(width: geometry.size.width * 0.7, alignment: .leading)
                      .padding(.leading)
                      .overlay(RoundedRectangle(cornerRadius: 20).stroke(.gray, lineWidth: 1))
                    Rectangle()
                      .foregroundColor(.black.opacity(0))
                      .frame(width: geometry.size.width * 0.5, alignment: .leading)
                      .padding(.leading)
                      .overlay(RoundedRectangle(cornerRadius: 20).stroke(.orange, lineWidth: 1))
                  }
                  Spacer()
                  Text("\(viewModel.getVotePercent(poll, votes: option.votes))%")
                }
              }
              .padding(.vertical)
            }
            HStack {
              Text("\(poll.totalVote) Votes")
              Text("Poll \(poll.votingStatus.rawValue)")
            }
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .overlay(RoundedRectangle(cornerRadius: 20).stroke(.gray, lineWidth: 2))
        }

        let gridItem: GridItem = .init(.flexible())

        LazyVGrid(columns: [gridItem, gridItem]) {
          ForEach(viewModel.medias) { media in
            if let mediaURL = media.url ?? media.previewImageURL {
              KFImage(mediaURL)
                .placeholder { p in
                  ProgressView(p)
                }
                .resizable()
                .frame(height: 100)
                .aspectRatio(contentMode: .fill)
                .clipped()
                .onTapGesture {
                  viewModel.selectedMediaURL = mediaURL
                  viewModel.isPresentedImageView.toggle()
                }

            }
          }
          .fullScreenCover(isPresented: $viewModel.isPresentedImageView) {
            ZStack {
              Color.black
                .ignoresSafeArea()
              KFImage(viewModel.selectedMediaURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                  viewModel.isPresentedImageView.toggle()
                }
            }
          }
        }

        if let placeName = viewModel.place?.name {
          Text(placeName)
            .foregroundColor(.gray)
        }

        if viewModel.tweet.referencedTweet?.type == .quoted {
          QuotedTweetCellView(tweet: viewModel.retweetTweet!, user: viewModel.retweetUser!)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.gray, lineWidth: 2))
        }

        if viewModel.tweet.referencedTweet?.type == .retweeted {
          HStack {
            Image(systemName: "repeat")
              .font(.system(size: 15, weight: .medium, design: .default))
            ProfileImageView(viewModel.authorUser.profileImageURL)
              .frame(width: 20, height: 20)
            Text(viewModel.authorUser.name)
          }
        }
      }
    }
    .onReceive(viewModel.timer) { _ in
      viewModel.nowDate = Date()
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
