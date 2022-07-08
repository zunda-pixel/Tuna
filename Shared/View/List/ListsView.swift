//
//  ListView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import Sweet
import SwiftUI

struct CustomListModel: Identifiable {
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
  let userID: String
  @Environment(\.managedObjectContext) private var viewContext

  @State var allLists: [CustomListModel] = []

  @State var pinnedListIDs: [String] = []
  var pinnedLists: [CustomListModel] { allLists.filter { pinnedListIDs.contains($0.id) } }

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
      let ownedListIDs = try await fetchOwnedLists()
      let followingListIDs =  try await fetchFollowingLists()
      let pinnedListIDs = try await fetchPinnedLists()

      let ownerIDs: [String] = Array(Set(allLists.compactMap(\.list.ownerID)))
      let response = try await Sweet(userID: userID).lookUpUsers(userIDs: ownerIDs)
      owners = response.users

      self.ownedListIDs = ownedListIDs
      self.followingListIDs = followingListIDs
      self.pinnedListIDs = pinnedListIDs
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  func fetchOwnedLists() async throws -> [String] {
    let response = try await Sweet(userID: userID).fetchOwnedLists(userID: userID)
    let lists: [CustomListModel] = response.lists.map { .init(list: $0, isPinned: false) }

    lists.forEach { list in
      if !allLists.contains(where: { $0.list.id == list.id}) {
        allLists.append(list)
      }
    }

    return response.lists.map(\.id)
  }

  func fetchFollowingLists() async throws -> [String] {
    let response = try await Sweet(userID: userID).fetchListsFollowed(by: userID)
    let lists: [CustomListModel] = response.lists.map { .init(list: $0, isPinned: false) }

    lists.forEach { list in
      if !allLists.contains(where: { $0.id == list.id}) {
        allLists.append(list)
      }
    }

    return response.lists.map(\.id)
  }

  func fetchPinnedLists() async throws -> [String] {
    let response = try await Sweet(userID: userID).fetchListsPinned(by: userID)
    let lists: [CustomListModel] = response.lists.map { .init(list: $0, isPinned: true) }

    lists.forEach { list in
      if let index = allLists.firstIndex(where: { $0.id == list.id}) {
        allLists[index].isPinned = true
      } else {
        allLists.append(list)
      }
    }

    return response.lists.map(\.id)
  }

  func deleteOwnedList(offsets: IndexSet) async {
    let list = ownedLists[offsets.first!]

    do {
      try await Sweet(userID: userID).deleteList(listID: list.id)

      ownedListIDs.remove(atOffsets: offsets)
      pinnedListIDs.removeAll { $0 == list.id }
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
      pinnedListIDs.removeAll { $0 == list.id }
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  func unPinList(offsets: IndexSet) async {
    let list = followingLists[offsets.first!]

    do {
      try await Sweet(userID: userID).unPinList(userID: userID, listID: list.id)
      
      pinnedListIDs.remove(atOffsets: offsets)
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    NavigationStack {
      List {
        Section("PINNED LISTS") {
          if pinnedLists.count == 0 {
            Text("No lists found")
              .opacity(0.25)
          }

          ForEach(pinnedLists) { list in
            NavigationLink(value: list.list) {
              let owner = owners.first { $0.id == list.list.ownerID }
              ListCellView(delegate: self, list: list, owner: owner!, userID: userID)
            }
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
            NavigationLink(value: list.list) {
              let owner = owners.first { $0.id == list.list.ownerID }
              ListCellView(delegate: self, list: list, owner: owner!, userID: userID)
            }
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
            NavigationLink(value: list.list) {
              let owner = owners.first { $0.id == list.list.ownerID }
              ListCellView(delegate: self, list: list, owner: owner!, userID: userID)
            }
          }
          .onDelete { offsets in
            Task {
              await unFollowList(offsets: offsets)
            }
          }
        }
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

      .navigationDestination(for: Sweet.ListModel.self, destination: { list in
        let listTweetsViewModel: ListTweetsViewModel = .init(userID: userID, listID: list.id)
        let listDetailViewModel: ListDetailViewModel = .init(userID: userID, list: list, tweetsViewModel: listTweetsViewModel)
        ListDetailView(viewModel: listDetailViewModel)
          .environment(\.managedObjectContext, viewContext)
      })
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
  func unPinList(listID: String) async {
    do {
      try await Sweet(userID: userID).unPinList(userID: userID, listID: listID)
      pinnedListIDs.removeAll { $0 == listID }

      if let index = allLists.firstIndex(where: { $0.list.id == listID }) {
        allLists[index].isPinned = false
      }

    } catch let newError {
      didError.toggle()
      error = newError
    }
  }

  func pinList(listID: String) async {
    do {
      try await Sweet(userID: userID).pinList(userID: userID, listID: listID)
      if let foundList = ownedLists.first(where: { $0.id == listID }) {
        pinnedListIDs.append(foundList.id)
      }

      if let foundList = followingLists.first(where: { $0.id == listID }) {
        pinnedListIDs.append(foundList.id)
      }

      if let index = allLists.firstIndex(where: { $0.list.id == listID }) {
        allLists[index].isPinned = true
      }
    } catch let newError {
      didError.toggle()
      error = newError
    }
  }
}

struct ListsView_Previews: PreviewProvider {
  static var previews: some View {
    ListsView(userID: "")
  }
}

