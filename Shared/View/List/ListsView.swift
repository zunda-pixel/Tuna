//
//  ListView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import Sweet
import SwiftUI

struct CustomListModel: Identifiable, Hashable {
  let id: String
  let list: Sweet.ListModel
  var isPinned: Bool

  init(list: Sweet.ListModel, isPinned: Bool) {
    self.list = list
    self.isPinned = isPinned
    self.id = list.id
  }
}

struct ListsView: View {
  @State var path = NavigationPath()

  let userID: String
  @Environment(\.managedObjectContext) private var viewContext

  @State var allLists: [CustomListModel] = []

  var pinnedLists: [CustomListModel] { allLists.filter { $0.isPinned } }

  @State var ownedListIDs: [String] = []
  var ownedLists: [CustomListModel] { allLists.filter { ownedListIDs.contains($0.id) } }

  @State var followingListIDs: [String] = []
  var followingLists: [CustomListModel] { allLists.filter { followingListIDs.contains($0.id) } }

  @State var error: Error?
  @State var didError = false

  @State var isPresentedAddList = false

  @State var owners: [Sweet.UserModel] = []

  func fetchAllLists() async {
    guard allLists.isEmpty else { return }

    do {
      let ownedLists = try await fetchOwnedLists()
      let followingLists =  try await fetchFollowingLists()

      allLists = ownedLists
      allLists.append(contentsOf: followingLists)


      let ownerIDs: [String] = Array(Set(allLists.compactMap(\.list.ownerID)))
      let response = try await Sweet(userID: userID).lookUpUsers(userIDs: ownerIDs)
      owners = response.users

      try await fetchPinnedLists()

      self.ownedListIDs = ownedLists.map(\.id)
      self.followingListIDs = followingLists.map(\.id)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  func fetchOwnedLists() async throws -> [CustomListModel] {
    let response = try await Sweet(userID: userID).fetchOwnedLists(userID: userID)
    let lists: [CustomListModel] = response.lists.map { .init(list: $0, isPinned: false) }

    return lists
  }

  func fetchFollowingLists() async throws -> [CustomListModel] {
    let response = try await Sweet(userID: userID).fetchListsFollowed(by: userID)
    let lists: [CustomListModel] = response.lists.map { .init(list: $0, isPinned: false) }

    return lists
  }

  func fetchPinnedLists() async throws {
    let response = try await Sweet(userID: userID).fetchListsPinned(by: userID)

    response.lists.forEach { list in
      if let index = allLists.firstIndex(where: { $0.id == list.id}) {
        allLists[index].isPinned = true
      }
    }
  }

  func deleteOwnedList(offsets: IndexSet) async {
    let list = ownedLists[offsets.first!]

    do {
      try await Sweet(userID: userID).deleteList(listID: list.id)

      ownedListIDs.remove(atOffsets: offsets)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  func unFollowList(offsets: IndexSet) async {
    let list = followingLists[offsets.first!]

    do {
      try await Sweet(userID: userID).unFollowList(userID: userID, listID: list.id)

      followingListIDs.remove(atOffsets: offsets)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  func unPinList(offsets: IndexSet) async {
    let list = followingLists[offsets.first!]

    do {
      try await Sweet(userID: userID).unPinList(userID: userID, listID: list.id)

      togglePin(listID: list.id)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    NavigationStack(path: $path) {
      List {
        Section("PINNED LISTS") {
          if pinnedLists.count == 0 {
            Text("No lists found")
              .opacity(0.25)
          }

          ForEach(pinnedLists) { list in
            let owner = owners.first { $0.id == list.list.ownerID }!
            ListCellView(delegate: self, list: list, owner: owner, userID: userID, path: $path)
          }
          .onDelete { offsets in
            Task {
              await unPinList(offsets: offsets)
            }
          }
        }

        Section("OWNED LISTS") {
          if ownedLists.count == 0 {
            Text("No lists found")
              .opacity(0.25)
          }

          ForEach(ownedLists) { list in
            let owner = owners.first { $0.id == list.list.ownerID }!
            ListCellView(delegate: self, list: list, owner: owner, userID: userID, path: $path)
          }
          .onDelete { offsets in
            Task {
              await deleteOwnedList(offsets: offsets)
            }
          }
        }

        Section("FOLLOWING LISTS") {
          if followingLists.count == 0 {
            Text("No lists found")
              .opacity(0.25)
          }

          ForEach(followingLists) { list in
            let owner = owners.first { $0.id == list.list.ownerID }!
            ListCellView(delegate: self, list: list, owner: owner, userID: userID, path: $path)
          }
          .onDelete { offsets in
            Task {
              await unFollowList(offsets: offsets)
            }
          }
        }
      }
      .navigationTitle("List")
      .navigationBarTitleDisplayMode(.large)
      .navigationDestination(for: UserViewModel.self) { viewModel in
        UserView(viewModel: viewModel, path: $path)
          .navigationTitle("@\(viewModel.user.userName)")
          .navigationBarTitleDisplayMode(.inline)
          .environment(\.managedObjectContext, viewContext)
      }
      .navigationDestination(for: FollowingUserViewModel.self) { viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle("Following")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: FollowerUserViewModel.self) { viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle("Follower")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: ListDetailViewModel.self) { viewModel in
        ListDetailView(path: $path, viewModel: viewModel)
          .navigationTitle("List (\(viewModel.list.name))")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: ListMembersViewModel.self) {viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle("List Member")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: ListFollowersViewModel.self) { viewModel in
        UsersView(viewModel: viewModel, path: $path)
          .navigationTitle("List Follower")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: TweetCellViewModel.self) { viewModel in
        TweetDetailView(tweetCellViewModel: viewModel, path: $path)
          .navigationTitle("Detail")
          .navigationBarTitleDisplayMode(.inline)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            isPresentedAddList.toggle()
          } label: {
            Image(systemName: "plus.app")
          }
        }
      }
      .sheet(isPresented: $isPresentedAddList) {
        NewListView(userID: userID, delegate: self)
      }
      .listStyle(.insetGrouped)
    }
    .alert("Error", isPresented: $didError) {
      Button {
        print(error!)
      } label: {
        Text("Close")
      }
    }
    .onAppear {
      Task {
        await fetchAllLists()
      }
    }
  }
}

extension ListsView: NewListDelegate {
  func didCreateList(list: Sweet.ListModel) {
    allLists.append(.init(list: list, isPinned: false))
    ownedListIDs.append(list.id)
  }
}

extension ListsView: ListCellDelegate {
  func togglePin(listID: String) {
    if let index = allLists.firstIndex(where: { $0.list.id == listID }) {
      allLists[index].isPinned.toggle()
    }
  }
}
