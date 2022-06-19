//
//  PollView.swift
//  Tuna
//
//  Created by zunda on 2022/06/18.
//

import SwiftUI
import Charts
import Sweet

struct PollView: View {
  let poll: Sweet.PollModel

  func getPercent(value: Double, total: Double) -> Int {
    if value == 0 {
      return 0
    }

    let percent = value / total * 100.0

    return Int(percent)
  }

  var totalVote: Int {
    let totalVote = poll.totalVote

    if totalVote == 0 {
      return 1
    }

    return totalVote
  }
  var body: some View {
    VStack {
      Grid {
        ForEach(poll.options) { option in
          GridRow {
            ProgressView(value: Double(option.votes), total: Double(totalVote))
              .scaleEffect(x: 1, y: 6, anchor: .center)
              .overlay(alignment: .leading) {
                Text(option.label)
              }
            let percent = getPercent(value: Double(option.votes), total: Double(poll.totalVote))
            Text("\(percent)%")
          }
        }
      }

      HStack {
        Text("\(poll.totalVote) Votes")
        Text("Poll \(poll.votingStatus.rawValue)")
      }
    }
  }
}

struct PollView_Previews: PreviewProvider {
  static var previews: some View {
    let poll: Sweet.PollModel = .init(id: "Hello", votingStatus: .isClosed, endDateTime: Date(), durationMinutes: 12 ,options: [.init(position: 1, label: "mikan", votes: 0), .init(position: 2, label: "apple", votes: 34), .init(position: 3, label: "orange", votes: 21)])
    PollView(poll: poll)
      .frame(width: 300, height: 300)
  }
}
