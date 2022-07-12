import SwiftUI
import Sweet

struct SpaceCell: View {
  let space: Sweet.SpaceModel
  let creator: Sweet.UserModel
  let speakers: [Sweet.UserModel]

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
          }

          if let scheduledAt = space.scheduledStart {
            Text(scheduledAt, format: .dateTime)
          }
        }

        HStack {
          Text("\(creator.name) @\(creator.userName)")
            .font(.title3)

          Spacer()

          ForEach(speakers.indices, id: \.self) { index in
            if index < 5 {
              ProfileImageView(speakers[index].profileImageURL)
                .frame(width: 30, height: 30)
                .offset(x: CGFloat(speakers.count - index) * 15)
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
    .background(Color.random)
    .cornerRadius(24)
    .padding()
  }
}
