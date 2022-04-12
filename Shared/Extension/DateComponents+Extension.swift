//
//  DateComponents+Extension.swift
//  Tuna (iOS)
//
//  Created by zunda on 2022/03/22.
//

import Foundation

extension DateComponents {
	func getTime(with component: Calendar.Component) -> Int? {
    switch component {
      case .second: return second
      case .era: return era
      case .year: return year
      case .month: return month
      case .day: return day
      case .hour: return hour
      case .minute: return minute
      case .weekday: return weekday
      case .weekdayOrdinal: return weekdayOrdinal
      case .quarter: return quarter
      case .weekOfMonth: return weekOfMonth
      case .weekOfYear: return weekOfYear
      case .yearForWeekOfYear: return yearForWeekOfYear
      case .nanosecond: return nanosecond
      default:
        fatalError()
    }
  }
}
