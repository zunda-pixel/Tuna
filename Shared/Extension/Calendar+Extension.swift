//
//  Calendar+Extension.swift
//
//  Created by zunda on 2022/03/22.
//

import Foundation

extension Calendar.Component {
  var unit: NSCalendar.Unit {
    switch self {
    case .second: return .second
    case .era: return .era
    case .year: return .year
    case .month: return .month
    case .day: return .day
    case .hour: return .hour
    case .minute: return .minute
    case .weekday: return .weekday
    case .weekdayOrdinal: return .weekdayOrdinal
    case .quarter: return .quarter
    case .weekOfMonth: return .weekOfMonth
    case .weekOfYear: return .weekOfYear
    case .yearForWeekOfYear: return .yearForWeekOfYear
    case .nanosecond: return .nanosecond
    case .calendar: return .calendar
    case .timeZone: return .timeZone
    @unknown default:
      fatalError()
    }
  }
}

extension Calendar {
  func durationString(
    candidate components: [Calendar.Component],
    from start: Date, to end: Date
  ) -> String? {
    for component in components {
      let dateComponents = self.dateComponents([component], from: start, to: end)
      if let time = dateComponents.getTime(with: component) {
        if time > 0 {
          let formatter = DateComponentsFormatter()
          formatter.allowedUnits = component.unit
          formatter.unitsStyle = .abbreviated
          formatter.calendar = self
          return formatter.string(from: dateComponents)
        }
      }
    }

    return nil
  }
}
