import SwiftUI
import Sweet

struct SearchSpacesView: View {
  enum SortType: String, CaseIterable, Identifiable {
    case viewers = "Viewers"
    case date = "Date"

    var id: String { rawValue }
  }

  let userID: String

  @State var selectedSortType: SortType = .viewers
  @State var path = NavigationPath()
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
    spaces.filter { $0.state == .live }.lazy.sorted { compareSpace(space1: $0, space2: $1, status: .live) }
  }

  var scheduledSpaces: [Sweet.SpaceModel] {
    spaces.filter { $0.state == .scheduled }.lazy.sorted { compareSpace(space1: $0, space2: $1, status: .scheduled) }
  }

  func compareSpace(space1: Sweet.SpaceModel, space2: Sweet.SpaceModel, status: Sweet.SpaceState) -> Bool {
    switch selectedSortType {
      case .viewers:
        return space1.speakerIDs.count > space2.speakerIDs.count
      case .date:
        switch status {
          case .scheduled:
            return space1.scheduledStart! < space2.scheduledStart!
          case .live:
            return space1.startedAt! > space2.startedAt!
          default:
            fatalError()
        }
    }
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
    NavigationStack(path: $path) {
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
        .padding(.bottom)

        TabView(selection: $selectedTab) {
          ScrollView {
            LazyVStack {
              ForEach(liveSpaces) { space in
                let creator = users.first { $0.id == space.creatorID }
                let speakers = users.filter { space.speakerIDs.contains($0.id) }
                SpaceCell(userID: userID, space: space, creator: creator!, speakers: speakers, path: $path)
              }
            }
          }
          .tag(SpaceTab.live)

          ScrollView(showsIndicators: false) {
            LazyVStack {
              ForEach(scheduledSpaces) { space in
                let creator = users.first { $0.id == space.creatorID }
                let speakers = users.filter { space.speakerIDs.contains($0.id) }
                SpaceCell(userID: userID, space: space, creator: creator!, speakers: speakers, path: $path)
              }
            }
          }
          .tag(SpaceTab.upcoming)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
      .padding(.horizontal)
      .alert("Error", isPresented: $didError) {
        Button("Close") {
          print(error!)
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Picker("Sort By", selection: $selectedSortType) {
            ForEach(SortType.allCases) { sortType in
              Label {
                Text("Sort by \(sortType.rawValue)")
              } icon: {
                Image(systemName: "arrow.up.and.down.text.horizontal")
              }
              .tag(sortType)
            }
          }
        }
      }
      .navigationTitle("Search Space")
      .navigationBarTitleDisplayMode(.large)

      .navigationDestination(for: SpaceDetailViewModel.self) { viewModel in
        SpaceDetail(viewModel: viewModel, path: $path)
      }
      .navigationDestination(for: UserViewModel.self) { viewModel in
        UserView(viewModel: viewModel, path: $path)
          .navigationTitle("@\(viewModel.user.userName)")
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: TweetDetailViewModel.self) { viewModel in
        TweetDetailView(viewModel: viewModel, path: $path)
          .navigationTitle("Detail")
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}
