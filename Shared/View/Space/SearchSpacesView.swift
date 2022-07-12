import SwiftUI
import Sweet

struct SearchSpacesView: View {
  let userID: String

  @State var searchText: String = ""
  @State var spaces: [Sweet.SpaceModel] = []
  @State var users: [Sweet.UserModel] = []
  @State var selectedTab: SpaceTab = .live
  @State var didError = false
  @State var error: Error?

  enum SpaceTab: String, CaseIterable, Identifiable {
    case live = "Live"
    case upcoming = "Upcoming"

    var id: String { rawValue }
  }

  var liveSpaces: [Sweet.SpaceModel] {
    spaces.filter { $0.state == .live }
  }

  var scheduledSpaces: [Sweet.SpaceModel] {
    spaces.filter { $0.state == .scheduled }
  }

  func fetchSpaces() async {
    guard !searchText.isEmpty else { return }

    do {
      let spaceResponse = try await Sweet(userID: userID).searchSpaces(by: searchText)

      users = spaceResponse.users
      spaces = spaceResponse.spaces
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    NavigationStack {
      VStack {
        TextField("Search Space", text: $searchText)
          .padding()
          .onSubmit(of: .text) {
            Task {
              await fetchSpaces()
            }
          }

        Picker("Space Tab", selection: $selectedTab) {
          ForEach(SpaceTab.allCases) { tab in
            Text(tab.rawValue)
              .tag(tab)
          }
        }
        .pickerStyle(.segmented)

        TabView(selection: $selectedTab) {
          ScrollView {
            VStack {
              ForEach(liveSpaces) { space in
                let creator = users.first { $0.id == space.creatorID }
                let speakers = users.filter { space.speakerIDs.contains($0.id) }
                SpaceCell(space: space, creator: creator!, speakers: speakers)
              }
            }
          }
          .tag(SpaceTab.live)

          ScrollView(showsIndicators: false) {
            VStack {
              ForEach(scheduledSpaces) { space in
                let creator = users.first { $0.id == space.creatorID }
                let speakers = users.filter { space.speakerIDs.contains($0.id) }
                SpaceCell(space: space, creator: creator!, speakers: speakers)
              }
            }
          }
          .tag(SpaceTab.upcoming)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
      .alert("Error", isPresented: $didError) {
        Button("Close") {
          print(error!)
        }
      }
    }
  }
}
