//
//  MuteButton.swift
//  Tuna
//
//  Created by zunda on 2022/05/23.
//

import SwiftUI
import Sweet

struct MuteButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var error: Error?
  @Binding var didError: Bool

  func mute() async {
    do {
      try await Sweet(userID: fromUserID).muteUser(from: fromUserID, to: toUserID)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    Button {
      Task {
        await mute()
      }
    } label: {
      Label("Mute", systemImage: "speaker.slash")
    }
  }
}

struct UnMuteButton: View {
  let fromUserID: String
  let toUserID: String

  @Binding var error: Error?
  @Binding var didError: Bool

  func unMute() async {
    do {
      try await Sweet(userID: fromUserID).unMuteUser(from: fromUserID, to: toUserID)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    Button {
      Task {
        await unMute()
      }
    } label: {
      Label("UnMute", systemImage: "speaker")
    }
  }
}
