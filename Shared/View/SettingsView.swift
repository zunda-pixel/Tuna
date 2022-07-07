//
//  SettingsView.swift
//  Tuna
//
//  Created by zunda on 2022/05/22.
//

import SwiftUI
import Sweet

struct SettingsView: View {
  var body: some View {
    NavigationStack {
      List {
        Section("General") {
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "iphone")
              Text("表示")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "iphone.radiowaves.left.and.right")
              Text("Behaviors")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "speaker")
                .symbolVariant(.circle)
              Text("Sound")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "safari")
              Text("Browser")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "rectangle.grid.2x2")
              Text("App Icon")
            }
          }
        }

        Section("ABOUT") {
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "person")
              Text("Mange Subscription")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "person")
              Text("Sync Status")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "person")
              Text("Support")
            }
          }
          NavigationLink {
            Text("Hello")
          } label: {
            HStack {
              Image(systemName: "person")
              Text("zunda")
            }
          }
        }
      }
    }
  }
}

struct SettingView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
