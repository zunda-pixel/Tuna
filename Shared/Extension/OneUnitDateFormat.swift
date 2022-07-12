import Foundation

extension FormatStyle where Self == OneUnitDurationFormat {
  static var twitter: OneUnitDurationFormat {
    let formatter = OneUnitDurationFormat(candidates: [.day, .hour, .minute, .second], style: .brief)
    return formatter
  }
}

struct OneUnitDurationFormat: FormatStyle {
  var candidates: [Date.ComponentsFormatStyle.Field]
  var style: DateComponentsFormatter.UnitsStyle
  var calendar: Calendar = .current

  func format(_ value: Range<Date>) -> String {
    calendar.duration(from: value, candidates: candidates, style: style)!
  }

  func locale(_ locale: Locale) -> Self {
    var newValue = self
    newValue.calendar.locale = locale
    return newValue
  }

  typealias FormatInput = Range<Date>

  typealias FormatOutput = String
}


extension  DateComponentsFormatter.UnitsStyle: Codable {
}
