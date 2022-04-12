//
//  NewPollView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import Sweet
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

struct NewPollView: View {
  @Binding var options: [String]
  @Binding var duration: TimeInterval
  @State var isPresentedDatePikcer = false

  var displayDate: String {
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.unitsStyle = .abbreviated
    dateFormatter.allowedUnits = [.hour, .minute]
    let dateString = dateFormatter.string(from: duration)!
    return dateString
  }

  var body: some View {
    VStack {
      ForEach($options.indices, id: \.self) { index in
        HStack {
          TextField("Anser \(index + 1) \(index < 2 ? "" : "(Optional)")", text: $options[index])
            .textFieldStyle(.roundedBorder)

          let isLast = index == options.count - 1

          Button(
            action: {
              if isLast {
                options.append("")
              } else {
                options.remove(at: index)
              }
            },
            label: {
              Image(systemName: isLast ? "plus.app" : "minus.square")
            })
        }
      }

      Button(
        action: {
          isPresentedDatePikcer.toggle()
        },
        label: {
          HStack {
            Text("Vote Duration")
            Spacer()
            Text(displayDate)
            Image(systemName: isPresentedDatePikcer ? "chevron.up" : "chevron.down")
          }
        })
      if isPresentedDatePikcer {
        DurationPicker(duration: $duration)
      }
    }
  }
}

struct NewPollView_Previews: PreviewProvider {
  @State static var options: [String] = ["", ""]
  @State static var duration: TimeInterval = 10 * 60

  static var previews: some View {
    NewPollView(options: $options, duration: $duration)
  }
}
