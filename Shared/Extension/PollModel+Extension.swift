//
//  PollModel+Extension.swift
//  Tuna
//
//  Created by zunda on 2022/03/25.
//

import Foundation
import Sweet

extension Sweet.PollModel {
  public init(poll: Poll) {
    let options = try? JSONDecoder().decode([Sweet.PollItem].self, from: poll.options ?? Data())
    
    let status: Sweet.PollStatus = .init(rawValue: poll.votingStatus!)!
    
    self.init(id: poll.id!, votingStatus: status, endDateTime: poll.endDateTime!, durationMinutes: Int(poll.durationMinutes), options: options ?? [])
  }
}
