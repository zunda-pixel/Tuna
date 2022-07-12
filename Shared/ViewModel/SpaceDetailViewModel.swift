import Foundation
import Sweet

final class SpaceDetailViewModel: ObservableObject, Hashable {
  static func == (lhs: SpaceDetailViewModel, rhs: SpaceDetailViewModel) -> Bool {
    lhs.space == rhs.space && lhs.creator == rhs.creator && lhs.speakers == rhs.speakers
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(space)
  }

  let userID: String
  let space: Sweet.SpaceModel
  let creator: Sweet.UserModel
  let speakers: [Sweet.UserModel]

  init(userID: String, space: Sweet.SpaceModel, creator: Sweet.UserModel, speakers: [Sweet.UserModel]) {
    self.userID = userID
    self.space = space
    self.creator = creator
    self.speakers = speakers
  }
}
