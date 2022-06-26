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

  func fetchOwnedLists() async throws {
    let response = try await Sweet(userID: userID).fetchOwnedLists(userID: userID)
    let lists: [CustomListModel] = response.lists.map { .init(list: $0, isPinned: false) }

    lists.forEach { list in
      if !allLists.contains(where: { $0.list.id == list.id}) {
        allLists.append(list)
      }
    }

    ownedListIDs = response.lists.map(\.id)
  }

  func fetchFollowingLists() async throws {
    let response = try await Sweet(userID: userID).fetchFollowingLists(userID: userID)
    let lists: [CustomListModel] = response.lists.map { .init(list: $0, isPinned: false) }

    lists.forEach { list in
      if !allLists.contains(where: { $0.id == list.id}) {
        allLists.append(list)
      }
    }

    followingListIDs = response.lists.map(\.id)
  }

  func fetchPinnedLists() async throws {
    let response = try await Sweet(userID: userID).fetchPinnedLists(userID: userID)
    let lists: [CustomListModel] = response.lists.map { .init(list: $0, isPinned: true) }

    lists.forEach { list in
      if let index = allLists.firstIndex(where: { $0.id == list.id}) {
        allLists[index].isPinned = true
      } else {
        allLists.append(list)
      }
    }

    pinnedListIDs = response.lists.map(\.id)
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
              ListCellView(delegate: self, list: list, userID: userID)
            }
          }
          .onDelete { offsets in
            let list = pinnedLists[offsets.first!]

            Task {
              await unPinList(listID: list.id)
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
              ListCellView(delegate: self, list: list, userID: userID)
            }
          }
          .onDelete { offsets in
            let list = ownedLists[offsets.first!]

            Task {
              try? await Sweet(userID: userID).deleteList(by: list.id)
            }

            ownedListIDs.remove(atOffsets: offsets)
          }
        }

        Section("FOLLOWING LISTS") {
          if followingLists.count == 0 {
            Text("No lists found")
              .opacity(0.25)
          }

          ForEach(followingLists) { list in
            NavigationLink(value: list.list) {
              ListCellView(delegate: self, list: list, userID: userID)
            }
          }
          .onDelete { offsets in
            let list = followingLists[offsets.first!]

            Task {
              try? await Sweet(userID: userID).unFollowList(userID: userID, listID: list.id)
            }

            followingListIDs.remove(atOffsets: offsets)
          }
        }
      }
      .navigationDestination(for: Sweet.ListModel.self, destination: { list in
        let listTweetsViewModel: ListTweetsViewModel = .init(userID: userID, listID: list.id, viewContext: viewContext)
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
      if !allLists.isEmpty {
        return
      }

      Task {
        do {
          try await fetchOwnedLists()
          try await fetchFollowingLists()
          try await fetchPinnedLists()
        } catch let newError {
          error = newError
          didError.toggle()
        }
      }
    }
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
