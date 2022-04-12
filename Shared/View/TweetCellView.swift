//
//  TweetView.swift
//  Tuna
//
//  Created by zunda on 2022/03/22.
//

import Kingfisher
import Sweet
import SwiftUI

struct TweetCellView: View {
  @StateObject var viewModel: TweetCellViewModel

  var body: some View {
    HStack(alignment: .top) {
      if !viewModel.isRetweet {
        ProfileImageView(viewModel.iconUser.profileImageURL, size: 50)
      }

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
            ForEach(poll.options, id: \.position) { option in
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

        let gridItem: GridItem = .init(.fixed(100))

        LazyVGrid(columns: [gridItem, gridItem]) {
          ForEach(viewModel.medias, id: \.key) { media in
            if let mediaURL = media.url ?? media.previewImageURL {
              KFImage(mediaURL)
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
          TweetCellView(
            viewModel: .init(
              isRetweet: true, tweet: viewModel.retweetTweet!, author: viewModel.retweetUser!)
          )
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .overlay(RoundedRectangle(cornerRadius: 20).stroke(.gray, lineWidth: 2))
        }

        if viewModel.tweet.referencedTweet?.type == .retweeted {
          HStack {
            Image(systemName: "arrow.2.squarepath")
              .font(.system(size: 15, weight: .medium, design: .default))
            ProfileImageView(viewModel.authorUser.profileImageURL, size: 20)
            Text(viewModel.authorUser.name)
          }
        }
      }
    }
    .onReceive(viewModel.timer) { _ in
      viewModel.nowDate = Date()
    }

    .alert("Error", isPresented: $viewModel.isPresentedErrorAlert) {
      Text(viewModel.error.debugDescription)
    } message: {
      Button("Report") {
      }
    }
  }
}

/*struct TweetView_Previews: PreviewProvider {
 static var previews: some View {
 TweetView(tweet: .init())
 }
 }*/
