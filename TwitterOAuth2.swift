//
//  TwitterOAuth2.swift
//  Tuna
//
//  Created by zunda on 2022/03/23.
//

import Foundation
import HTTPClient
import Sweet

struct TwitterOAuth2 {
  private let clientID: String
  private let clientSecretKey: String

  init(clientID: String, clientSecretKey: String) {
    self.clientID = clientID
    self.clientSecretKey = clientSecretKey
  }

  func getAuthorizeURL(scopes: [TwitterScope], callBackURL: URL, challenge: String, state: String) -> URL {
    // https://developer.twitter.com/en/docs/authentication/oauth-2-0/user-access-token

    let joinedScope = scopes.map(\.rawValue).joined(separator: " ")

    let queries = [
      "response_type": "code",
      "client_id": clientID,
      "redirect_uri": callBackURL.absoluteString,
      "scope": joinedScope,
      "state": state,
      "code_challenge": challenge,
      "code_challenge_method": "plain",
    ]

    let authorizationURL: URL = .init(string: "https://twitter.com/i/oauth2/authorize")!
    var urlComponents: URLComponents = .init(url: authorizationURL, resolvingAgainstBaseURL: true)!
    urlComponents.queryItems = queries.map { .init(name: $0, value: $1) }

    return urlComponents.url!
  }

  func getUserBearerToken(code: String, callBackURL: URL, challenge: String) async throws -> OAuth2ModelResponse {
    // https://developer.twitter.com/en/docs/authentication/oauth-2-0/user-access-token

    let basicAuthorization = getBasicAuthorization(user: clientID, password: clientSecretKey)

    let headers = [
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Basic \(basicAuthorization)",
    ]

    let queries = [
      "code": code,
      "grant_type": "authorization_code",
      "client_id": clientID,
      "redirect_uri": callBackURL.absoluteString,
      "code_verifier": challenge,
    ]

    let url: URL = .init(string: "https://api.twitter.com/2/oauth2/token")!

    let (data, urlResponse) = try await URLSession.shared.post(
      url: url, headers: headers, queries: queries)

    if let response = try? JSONDecoder().decode(OAuth2ModelResponse.self, from: data) {
      return response
    }

    if let response = try? JSONDecoder().decode(Sweet.ResponseErrorModel.self, from: data) {
      throw Sweet.TwitterError.invalidRequest(error: response)
    }

    throw Sweet.TwitterError.unknown(data: data, response: urlResponse)
  }

  func getRefreshUserBearerToken(refreshToken: String) async throws -> OAuth2ModelResponse {
    // https://developer.twitter.com/en/docs/authentication/oauth-2-0/authorization-code

    let url: URL = .init(string: "https://api.twitter.com/2/oauth2/token")!

    let queries = [
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "client_id": clientID,
    ]

    let (data, urlResponse) = try await URLSession.shared.post(url: url, queries: queries)

    if let response = try? JSONDecoder().decode(OAuth2ModelResponse.self, from: data) {
      return response
    }

    if let response = try? JSONDecoder().decode(Sweet.ResponseErrorModel.self, from: data) {
      throw Sweet.TwitterError.invalidRequest(error: response)
    }

    throw Sweet.TwitterError.unknown(data: data, response: urlResponse)
  }

  func getBasicAuthorization(user: String, password: String) -> String {
    let value = "\(user):\(password)"
    let encodedValue = value.data(using: .utf8)!
    let encoded64Value = encodedValue.base64EncodedString()
    return encoded64Value
  }
}

struct OAuth2ModelResponse: Decodable {
  let bearerToken: String
  let refreshToken: String
  let expiredSeconds: Int

  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiredSeconds = "expires_in"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.bearerToken = try values.decode(String.self, forKey: .accessToken)
    self.refreshToken = try values.decode(String.self, forKey: .refreshToken)
    self.expiredSeconds = try values.decode(Int.self, forKey: .expiredSeconds)
  }
}

enum TwitterScope: String, CaseIterable {
  case tweetRead = "tweet.read"
  case tweetWrite = "tweet.write"
  case tweetModerateWrite = "tweet.moderate.write"

  case usersRead = "users.read"

  case followsRead = "follows.read"
  case followWrite = "follows.write"

  case offlineAccess = "offline.access"

  case spaceRead = "space.read"

  case muteRead = "mute.read"
  case muteWrite = "mute.write"

  case likeRead = "like.read"
  case likeWrite = "like.write"

  case listRead = "list.read"
  case listWrite = "list.write"

  case blockRead = "block.read"
  case blockWrite = "block.write"

  case bookmarkRead = "bookmark.read"
  case bookmarkWrite = "bookmark.write"
}
