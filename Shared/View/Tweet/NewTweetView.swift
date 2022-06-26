//
//  CreateTweetView.swift
//  Tuna
//
//  Created by zunda on 2022/03/25.
//

import CoreLocation
import Sweet
import SwiftUI
import CoreLocationUI
import PhotosUI

struct NewTweetView<ViewModel: NewTweetViewProtocol>: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var viewModel: ViewModel
  @FocusState private var showKeyboard: Bool

  var body: some View {
    ScrollView {
      HStack {
        Button("Close") {
          dismiss()
        }
        Spacer()
        Text("New Tweet")
        Spacer()
        Button("Tweet") {
          Task {
            await viewModel.tweet()
            dismiss()
          }
        }
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
        ForEach(viewModel.photos) { photo in
          PhotoView(photo: photo)
            .frame(width: 100, height: 100, alignment: .center)
            .scaledToFit()
        }
      }

      if let location = viewModel.locationString {
        HStack {
          Text(location)
            .foregroundColor(.gray)

          Button {
            self.viewModel.locationString = nil
          } label: {
            Image(systemName: "multiply.circle")
          }
        }
      }

      Picker("ReplySetting", selection: $viewModel.selectedReplySetting) {
        ForEach(Sweet.ReplySetting.allCases, id: \.rawValue) { replySetting in
          Text(replySetting.description)
        }
      }

      HStack {
        PhotosPicker(selection: $viewModel.photosPickerItems,
                     maxSelectionCount: 0,
                     selectionBehavior: .ordered,
                     preferredItemEncoding: .current,
                     photoLibrary: .shared()) {
          Image(systemName: "photo")
        }
        
        LocationButton(.currentLocation) {
          Task {
            await viewModel.setLocation()
          }
        }
        .foregroundColor(.blue)
        .tint(.white)
        .labelStyle(.iconOnly)
        .disabled(viewModel.loadingLocation)
        
        Button {
          viewModel.pollButtonAction()
        } label: {
          Image(systemName: "chart.bar.xaxis")
            .rotationEffect(.degrees(90))
        }
        .disabled(viewModel.photos.count != 0)
      }
      .onChange(of: viewModel.photosPickerItems, perform: { newResults in
        Task {
          await viewModel.loadPhotos(with: newResults)
        }
      })
      .alert("Error", isPresented: $viewModel.didError) {
        Button(role: .destructive) {
          print(viewModel.error!)
        } label: {
          Text("Close")
        }
      } message: {
        Text("\(viewModel.error?.localizedDescription ?? "Error Detail")")
      }
    }
    .padding()
  }
}

struct NewTweetView_Previews: PreviewProvider {
  @State static var isPresentedDismiss = false
  static var previews: some View {
    let viewModel: NewTweetViewModel = {
      let viewModel = NewTweetViewModel(userID: "")
      viewModel.poll = .init(options: ["", ""], durationMinutes: 10)
      viewModel.locationString = "sample geo"
      return viewModel
    }()

    NewTweetView(viewModel: viewModel)
  }
}
