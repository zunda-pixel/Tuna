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
  @StateObject var viewModel: ViewModel
  @State var lastDragPosition: DragGesture.Value?
  @State var dragSpeed: CGFloat?
  @State var imagePosition: CGPoint = .init(x: 0, y: 0)
  @GestureState var magnifyBy = CGFloat(1.0)

  var body: some View {
    HStack(alignment: .top) {
      let user = viewModel.tweet.referencedTweet?.type == .retweeted ? viewModel.retweet!.user : viewModel.author
      ProfileImageView(user.profileImageURL)
        .frame(width: 50, height: 50)
        .onTapGesture {
          viewModel.isPresentedUserView.toggle()
        }
        .sheet(isPresented: $viewModel.isPresentedUserView) {
          UserView(userID: viewModel.userID, user: user)
            .environment(\.managedObjectContext, viewContext)
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

        let gridItem: GridItem = .init(.flexible())

        LazyVGrid(columns: [gridItem, gridItem]) {
          ForEach(viewModel.medias) { media in
            if let mediaURL = media.url ?? media.previewImageURL {
              KFImage(mediaURL)
                .placeholder { p in
                  ProgressView(p)
                }
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .clipped()
                .onTapGesture {
                  viewModel.selectedMedia = media
                  viewModel.isPresentedImageView.toggle()
                }
            }
          }
          .fullScreenCover(isPresented: $viewModel.isPresentedImageView) {
            TabView(selection: $viewModel.selectedMedia) {
              ForEach(viewModel.medias) { media in
                let mediaURL = media.url ?? media.previewImageURL!
                ZStack {
                  Color.black
                    .ignoresSafeArea()
                  KFImage(mediaURL)
                    .resizable()
                    .scaledToFit()
                    //.position(imagePosition)
                    .gesture(MagnificationGesture()
                      .updating($magnifyBy) { currentState, gestureState, transaction in
                          gestureState = currentState
                      }
                    )
                    .gesture(DragGesture()
                      .onChanged { value in
                        imagePosition = .init(x: value.startLocation.x + value.translation.width,
                                              y: value.startLocation.y + value.translation.height)

                        if lastDragPosition == nil {
                          lastDragPosition = value
                        }

                        let timeDiff = value.time.timeIntervalSince(lastDragPosition!.time)
                        let speed: CGFloat = (value.translation.height - lastDragPosition!.translation.height) / timeDiff

                        self.dragSpeed = speed
                        self.lastDragPosition = value
                      }
                      .onEnded { value in
                        guard let dragSpeed else { return }

                        if abs(dragSpeed) > 100 {
                          viewModel.isPresentedImageView.toggle()
                        }
                      }
                    )
                }
                .tag(media)
              }
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))

          }
        }

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
  }
}
