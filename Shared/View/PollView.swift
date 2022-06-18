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
  
  var body: some View {
    VStack {
      ZStack {
        Chart {
          ForEach(poll.options, id: \.id) { option in
            BarMark(x: .value("X", 1), y: .value("Y", option.label))
              .foregroundStyle(.gray.opacity(0.1))
              .annotation(position: .overlay) {
                HStack {
                  Text(option.label)
                  Spacer()
                }
              }
              .annotation(position: .trailing) {
                if poll.totalVote == 0 {
                  Text("0%")
                } else {
                  let percent = Double(option.votes) / Double(poll.totalVote) * 100.0
                  let showPercent = Int(round(percent))
                  Text("\(showPercent)%")
                }
              }
              .cornerRadius(10)
          }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        Chart {
          ForEach(poll.options, id: \.id) { option in
            BarMark(x: .value("X", option.votes), y: .value("Y", option.label))
              .foregroundStyle(.gray.opacity(0.5))
              .annotation(position: .overlay) {
                HStack {
                  Text(option.label)
                  Spacer()
                }
              }
              .cornerRadius(10)
          }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
      }
      .frame(height: 35 * CGFloat(poll.options.count))

      Text("\(poll.totalVote) Votes")
      Text("Poll \(poll.votingStatus.rawValue)")
    }
  }
}

struct PollView_Previews: PreviewProvider {
  static var previews: some View {
    let poll: Sweet.PollModel = .init(id: "Hello", votingStatus: .isClosed, endDateTime: Date(), durationMinutes: 12 ,options: [.init(position: 1, label: "mikan", votes: 0), .init(position: 2, label: "apple", votes: 34)])
    PollView(poll: poll)
      .frame(width: 300, height: 300)
  }
}
