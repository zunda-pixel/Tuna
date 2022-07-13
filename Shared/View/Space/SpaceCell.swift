import SwiftUI
import Sweet

struct SpaceCell: View {
  let userID: String
  let space: Sweet.SpaceModel
  let creator: Sweet.UserModel
  let speakers: [Sweet.UserModel]

  @Binding var path: NavigationPath

  var body: some View {
    HStack {
      ProfileImageView(creator.profileImageURL)
        .frame(width: 50, height: 50)

      VStack {
        HStack {
          if let title = space.title {
            Text(title)
              .lineLimit(1)
              .font(.title)
          }

          Spacer()

          if let startedAt = space.startedAt {
            TimelineView(.periodic(from: .now, by: 1)) { context in
              let range = startedAt..<context.date
              Text(range, format: .twitter)
            }
          } else if let scheduledAt = space.scheduledStart {
            Text(scheduledAt, style: .relative)
          }
        }

        HStack {
          Text("\(creator.name) @\(creator.userName)")
            .font(.title3)

          Spacer()

          ForEach(speakers.indices, id: \.self) { index in
            if index < 4 {
              ProfileImageView(speakers[index].profileImageURL)
                .frame(width: 30, height: 30)
            }
          }

          if !speakers.isEmpty {
            Text("\(speakers.count) Listening")
              .padding(.horizontal)
          }
        }
      }
    }
    .padding()
    .background(Color.random.opacity(0.5))
    .cornerRadius(24)
    .padding()
    .onTapGesture {
      let spaceDetailViewModel: SpaceDetailViewModel = .init(userID: userID, space: space, creator: creator, speakers: speakers)
      path.append(spaceDetailViewModel)
    }
  }
}
