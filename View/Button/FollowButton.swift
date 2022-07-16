//
//  FollowButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

struct FollowButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var error: Error?
  @Binding var didError: Bool

  func follow() async {
    do {
      _ = try await Sweet(userID: fromUserID).follow(from: fromUserID, to: toUserID)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    Button {
      Task {
        await follow()
      }
    } label: {
      Label("Follow", systemImage: "person.fill.checkmark")
    }
  }
}

struct UnFollowButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var error: Error?
  @Binding var didError: Bool

  func unFollow() async {
    do {
      _ = try await Sweet(userID: fromUserID).unFollow(from: fromUserID, to: toUserID)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }


  var body: some View {
    Button {
      Task {
        await unFollow()
      }
    } label: {
      Label("UnFollow", systemImage: "person.fill.xmark")
    }
  }
}
