//
//  DurationPicker.swift
//  Tuna
//
//  Created by zunda on 2022/05/26.
//

import SwiftUI

struct DurationPicker: UIViewRepresentable {
  @Binding var duration: TimeInterval

  func makeUIView(context: Context) -> UIDatePicker {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .countDownTimer
    datePicker.addTarget(
      context.coordinator, action: #selector(Coordinator.updateDuration), for: .valueChanged)
    return datePicker
  }

  func updateUIView(_ datePicker: UIDatePicker, context: Context) {
    datePicker.countDownDuration = duration
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject {
    let parent: DurationPicker

    init(_ parent: DurationPicker) {
      self.parent = parent
    }

    @objc func updateDuration(datePicker: UIDatePicker) {
      parent.duration = datePicker.countDownDuration
    }
  }
}

struct DurationPicker_Previews: PreviewProvider {
  @State static var timeInterval: TimeInterval = 0

  static var previews: some View {
    DurationPicker(duration: $timeInterval)
  }
}
