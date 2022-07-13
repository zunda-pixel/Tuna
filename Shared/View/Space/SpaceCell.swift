import SwiftUI
import Sweet

struct SpaceCell: View {
  let userID: String
  let space: Sweet.SpaceModel
  let creator: Sweet.UserModel
  let speakers: [Sweet.UserModel]

  @Binding var path: NavigationPath

  var body: some View {
    HStack(alignment: .top) {
      ProfileImageView(creator.profileImageURL)
        .frame(width: 50, height: 50)
        .padding(.trailing)

      VStack {
        HStack {
          (Text(creator.name) + Text(" @\(creator.userName)").foregroundColor(.gray))
              .lineLimit(1)

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
          Text(space.title!)
            .lineLimit(nil)
          Spacer()
        }

        HStack {
          Spacer()
          ForEach(speakers.indices, id: \.self) { index in
            if index < 4 {
              ProfileImageView(speakers[index].profileImageURL)
                .frame(width: 15, height: 15)
            }
          }

          if !speakers.isEmpty {
            Text("\(speakers.count) Listening")
          }
        }
      }
    }
    .padding()
    .background(Color.random.opacity(0.5))
    .cornerRadius(24)
    .onTapGesture {
      let spaceDetailViewModel: SpaceDetailViewModel = .init(userID: userID, space: space, creator: creator, speakers: speakers)
      path.append(spaceDetailViewModel)
    }
  }
}
