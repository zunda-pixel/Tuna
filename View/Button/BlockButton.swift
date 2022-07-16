//
//  BlockButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

struct BlockButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var error: Error?
  @Binding var didError: Bool

  func block() async {
    do {
      try await Sweet(userID: fromUserID).blockUser(from: fromUserID, to: toUserID)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    Button {
      Task {
        await block()
      }
    } label: {
      Label("Block", systemImage: "xmark.shield")
    }
  }
}

struct UnBlockButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var error: Error?
  @Binding var didError: Bool

  func unBlock() async {
    do {
      try await Sweet(userID: fromUserID).unBlockUser(from: fromUserID, to: toUserID)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    Button {
      Task {
        await unBlock()
      }
    } label: {
      Label("UnBlock", systemImage: "checkmark.shield")
    }
  }
}
