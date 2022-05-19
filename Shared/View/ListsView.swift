//
//  ListView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import Sweet
import SwiftUI

struct ListsView: View {
  let userID: String
  @Environment(\.managedObjectContext) private var viewContext
  
  @State var pinnedLists: [Sweet.ListModel] = []
  @State var ownedLists: [Sweet.ListModel] = []
  @State var followingLists: [Sweet.ListModel] = []

  @State var error: Error?
  @State var didError = false

  func fetchOwnedLists() async throws {
    let response = try await Sweet().fetchOwnedLists(userID: userID)
    self.ownedLists = response.lists
  }

  func fetchFollowingLists() async throws {
    let response = try await Sweet().fetchFollowingLists(userID: userID)
    self.followingLists = response.lists
  }

  func fetchPinnedLists() async throws {
    let response = try await Sweet().fetchPinnedLists(userID: userID)
    self.pinnedLists = response.lists
  }

  var body: some View {
    NavigationView {
      List {
        Section("PINNED LISTS") {
          if pinnedLists.count == 0 {
            Text("not found list")
          }

          ForEach(pinnedLists) { list in
            NavigationLink(
              destination: {
                let listDetailViewModel: ListDetailViewModel = .init(list: list)
                ListDetailView(viewModel: listDetailViewModel)
              },
              label: {
                ListCellView(list: list)
              })
          }
          .onDelete { offsets in
            let list = pinnedLists[offsets.first!]

            Task {
              do {
                try await Sweet().unPinList(userID: userID, listID: list.id)
              } catch let newError {
                error = newError
                didError.toggle()
              }
            }

            pinnedLists.remove(atOffsets: offsets)
          }
        }

        Section("OWNED LISTS") {
          if ownedLists.count == 0 {
            Text("not found list")
          }

          ForEach(ownedLists) { list in
            NavigationLink(
              destination: {
                let listDetailViewModel: ListDetailViewModel = .init(list: list)
                ListDetailView(viewModel: listDetailViewModel)
              },
              label: {
                ListCellView(list: list)
              })
          }
          .onDelete { offsets in
            let list = ownedLists[offsets.first!]

            Task {
              try? await Sweet().deleteList(by: list.id)
            }

            ownedLists.remove(atOffsets: offsets)
          }
        }

        Section("FOLLOWING LISTS") {
          if followingLists.count == 0 {
            Text("not found list")
          }

          ForEach(followingLists) { list in
            NavigationLink(
              destination: {
                let listDetailViewModel: ListDetailViewModel = .init(list: list)
                ListDetailView(viewModel: listDetailViewModel)
              },
              label: {
                ListCellView(list: list)
              })
          }
          .onDelete { offsets in
            let list = followingLists[offsets.first!]

            Task {
              try? await Sweet().unFollowList(userID: userID, listID: list.id)
            }

            followingLists.remove(atOffsets: offsets)
          }
        }
      }
      .listStyle(.insetGrouped)
      .toolbar {
        ToolbarItem(
          placement: .navigationBarLeading
        ) {
          Button(
            action: {},
            label: {
              Text("hello")
            })
        }
      }

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
        do {
          try await fetchPinnedLists()
        } catch let newError {
          error = newError
          didError.toggle()
        }
      }
      Task {
        do {
          try await fetchOwnedLists()
        } catch let newError {
          error = newError
          didError.toggle()
        }
      }
      Task {
        do {
          try await fetchFollowingLists()
        } catch let newError {
          error = newError
          didError.toggle()
        }
      }
    }
  }
}

struct ListsView_Previews: PreviewProvider {
  static var previews: some View {
    ListsView(userID: "")
  }
}
