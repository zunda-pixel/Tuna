//
//  UserView.swift
//  Tuna
//
//  Created by zunda on 2022/05/21.
//

import SwiftUI
import Sweet
import UniformTypeIdentifiers

enum TweetTab: String, CaseIterable, Identifiable {
  var id: String {
    return rawValue
  }

  case tweet = "Tweet"
  case media = "Media"
  case like = "Like"
}

struct UserView: View {
  let user: Sweet.UserModel
  @State var selection: TweetTab = .tweet

  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading) {
        Rectangle()
          .foregroundColor(.random.opacity(0.5))
          .frame(width: geometry.size.width, height: 150)
          .ignoresSafeArea(edges: .top)

        HStack(alignment: .bottom) {
          ProfileImageView(user.profileImageURL)
            .frame(width: 80, height: 80)

          Spacer()

          Image(systemName: "tray")
            .font(.title)

          Button {
            
          } label: {
            Text("Follow")
              .font(.title)
          }
        }
        .offset(y: -140)
        .padding(.bottom, -80)

        Text(user.name)
          .font(.title)

        Text("@\(user.userName)")
          .foregroundColor(.gray)

        if let description = user.description {
          Text(description)
        }

        if let url = user.url {
          HStack {
            Image(systemName: "link")
            Link(url.description, destination: url)
          }
          .padding(.vertical, 3)
        }

        if let createAt = user.createdAt {
          HStack {
            Image(systemName: "calendar")

            let formatter: DateFormatter = {
              let formatter: DateFormatter = .init()
              formatter.dateFormat = "yyyy年M月"
              return formatter
            }()

            Text(formatter.string(from: createAt) + "からTwitterを利用しています")
          }
          .padding(.vertical, 3)

        }

        if let location = user.location {
          HStack {
            Image(systemName: "location")
            Text(location)
          }
          .padding(.vertical, 3)
        }

        Picker("User Tab", selection: $selection) {
          ForEach(TweetTab.allCases) { tab in
            Text(tab.rawValue)
              .tag(tab)
          }
        }
        .pickerStyle(.segmented)

        TabView(selection: $selection) {
          Text("Tweet")
            .tabItem {
              Text("Tweet")
            }
            .tag(TweetTab.tweet)
          Text("Media")
            .tabItem {
              Text("Media")
            }
            .tag(TweetTab.media)
          Text("Like")
            .tabItem {
              Text("Like")
            }
            .tag(TweetTab.like)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
    }
  }
}

struct UserView_Previews: PreviewProvider {
  static var previews: some View {
    UserView(user: .init(id: "", name: "zunda" ,userName: "zunda_pixel", profileImageURL:  .init(string: "https://pbs.twimg.com/profile_images/974322170309390336/tY8HZIhk_400x400.jpg"),  description: "hello from america", url: .init(string: "https://twitter.com"),createdAt: Date(), location: "ここはどこ"))
  }
}
