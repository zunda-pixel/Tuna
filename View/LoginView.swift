//
//  LoginView.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import SwiftUI
import Sweet
import CoreData

struct LoginView<Label: View>: View {
  @Environment(\.openURL) var openURL
  @Environment(\.managedObjectContext) var context
  @Binding var userID: String?
  @State var error: Error?
  @State var didError = false

  let label: Label

  init(userID: Binding<String?>,  @ViewBuilder label: () -> Label) {
    self._userID = userID
    self.label = label()
  }

  func getRandomString() -> String {
    let challenge = SecurityRandom.secureRandomBytes(count: 10)
    return challenge.reduce(into: "") { $0 = $0 + "\($1)" }
  }

  func getAuthorizeURL() -> URL {
    let challenge = getRandomString()
    Secret.challenge = challenge

    let state = getRandomString()
    Secret.state = state

    let url = TwitterOAuth2().getAuthorizeURL(
      scopes: TwitterScope.allCases,
      callBackURL: Secret.callBackURL,
      challenge: challenge,
      state: state
    )

    return url
  }

  func doSomething(url: URL) async {
    let deepLink = DeepLink(delegate: self, context: context)

    do {
      try await deepLink.doSomething(url)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    Button {
      let url = getAuthorizeURL()
      openURL(url)
    } label: {
      label
    }
    .alert("Error", isPresented: $didError) {
      Button {
        print(error!)
      } label: {
        Text("Close")
      }
    }
    .onOpenURL { url in
      Task {
        await doSomething(url: url)
      }
    }
  }
}

extension LoginView: DeepLinkDelegate {
  func setUserID(userID: String) {
    self.userID = userID
  }

  func addUser(user: Sweet.UserModel) throws {
    let fetchRequest = NSFetchRequest<User>()
    fetchRequest.entity = User.entity()
    fetchRequest.sortDescriptors = []

    let users = try context.fetch(fetchRequest)

    if let foundUser = users.first(where: { $0.id == user.id }) {
      try foundUser.setUserModel(user)
    } else {
      let newUser = User(context: context)
      try newUser.setUserModel(user)
    }

    try context.save()
  }
}
