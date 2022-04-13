//
//  CreateTweetView.swift
//  Tuna
//
//  Created by zunda on 2022/03/25.
//

import Accelerate
import CoreLocation
import Sweet
import SwiftUI

struct NewTweetView<ViewModel: NewTweetViewModelProtocol>: View {
  @Binding var isPresentedDismiss: Bool
  @StateObject var viewModel: ViewModel
  @FocusState private var showKeyboard: Bool

  var body: some View {
    ScrollView {
      HStack {
        Button(
          action: {
            isPresentedDismiss = false
          },
          label: {
            Text("Close")
          })
        Spacer()
        Text("New Tweet")
        Spacer()
        Button(
          action: {
            Task {
              await viewModel.tweet()
              isPresentedDismiss = false
            }
          },
          label: {
            Text("Tweet")
          }
        )
        .disabled(viewModel.disableTweetButton)
        .buttonStyle(.bordered)
      }
      HStack(alignment: .top) {
        Image(systemName: "person")
        VStack {
          HStack(alignment: .top) {
            ZStack {
              TextEditor(text: $viewModel.text)
                .focused($showKeyboard, equals: true)
                .onAppear {
                  showKeyboard = true
                }
              Text(viewModel.text).opacity(0)
            }

            Text("\(viewModel.leftTweetCount)")
          }

          if let poll = viewModel.poll, poll.options.count > 1 {
            NewPollView(
              options: .init(
                get: { viewModel.poll!.options },
                set: { viewModel.poll?.options = $0 }
              ),
              duration: .init(
                get: { TimeInterval(poll.durationMinutes * 60) },
                set: { viewModel.poll?.durationMinutes = Int($0 / 60) })
            )
            .padding()
            .overlay(
              RoundedRectangle(cornerRadius: 20)
                .stroke(.black.opacity(0.2), lineWidth: 2)
            )
            .padding(.horizontal, 2)
          }
        }
      }

      LazyVGrid(columns: [.init(), .init()]) {
        ForEach(0..<viewModel.results.count, id: \.self) { i in
          PhotoView(
            provider: viewModel.results[i].provider,
            item: .init(get: { viewModel.results[i].item }, set: { viewModel.results[i].item = $0 })
          )
          .frame(width: 100, height: 100, alignment: .center)
          .scaledToFit()

        }
      }

      if let location = viewModel.locationString {
        HStack {
          Text(location)
            .foregroundColor(.gray)

          Button(
            action: {
              self.viewModel.locationString = nil
            },
            label: {
              Image(systemName: "multiply.circle")
            })
        }
      }

      Picker("ReplySetting", selection: $viewModel.selectedReplySetting) {
        ForEach(Sweet.ReplySetting.allCases, id: \.rawValue) { replySetting in
          Text(replySetting.description)
        }
      }

      HStack {
        Button(
          action: {
            viewModel.isPresentedPhotoPicker.toggle()
          },
          label: {
            Image(systemName: "photo")
          }
        )
        .disabled(!viewModel.didPickPhoto)
        .sheet(isPresented: $viewModel.isPresentedPhotoPicker) {
          PhotoPicker(results: $viewModel.results, didPickPhoto: $viewModel.didPickPhoto)
        }

        Button(
          action: {
            Task {
              await viewModel.setLocation()
            }
          },
          label: {
            Image(systemName: "location")
          })

        Button(
          action: {
            if viewModel.poll?.options == nil || viewModel.poll!.options.count < 2 {
              viewModel.poll = .init(options: ["", ""], durationMinutes: 10)
            } else {
              viewModel.poll = nil
            }
          },
          label: {
            Image(systemName: "chart.bar.xaxis")
          }
        )
        .disabled(viewModel.medias.count != 0)
      }
      .alert("", isPresented: $viewModel.didFail) {
        Button("OK") {
        }
      } message: {
        Text(viewModel.error.debugDescription)
      }
    }
    .padding()
  }
}

struct NewTweetView_Previews: PreviewProvider {
  @State static var isPresentedDismiss = false
  static var previews: some View {

    let viewModel: NewTweetViewModel = {
      let viewModel = NewTweetViewModel()
      viewModel.poll = .init(options: ["", ""], durationMinutes: 10)
      viewModel.locationString = "sample geo"
      return viewModel
    }()

    NewTweetView(isPresentedDismiss: $isPresentedDismiss, viewModel: viewModel)
  }
}
