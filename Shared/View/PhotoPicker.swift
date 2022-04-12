//
//  ImagePickerView.swift
//  Tuna
//
//  Created by zunda on 2022/03/30.
//

import PhotosUI
import SwiftUI

struct PhotoPicker: UIViewControllerRepresentable {
  @Binding var results: [PhotoResult]
  @Binding var didPickPhoto: Bool

  init(results: Binding<[PhotoResult]>, didPickPhoto: Binding<Bool>) {
    self._results = results
    self._didPickPhoto = didPickPhoto
  }

  func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration(photoLibrary: .shared())
    configuration.preselectedAssetIdentifiers = results.map { $0.id }
    configuration.selectionLimit = 0
    configuration.preferredAssetRepresentationMode = .current
    configuration.selection = .ordered

    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    var parent: PhotoPicker

    init(_ parent: PhotoPicker) {
      self.parent = parent
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      picker.dismiss(animated: true)

      let existingSelection = parent.results

      var newResults: [PhotoResult] = []

      for result in results {
        let id = result.assetIdentifier!
        let firstItem = existingSelection.first(where: { $0.id == id })
        let provider = firstItem?.provider ?? result.itemProvider
        let result: PhotoResult = .init(id: id, provider: provider, item: firstItem?.item)
        newResults.append(result)
      }

      parent.results = newResults
      parent.didPickPhoto = true
    }
  }
}

struct PhotoResult {
  let id: String
  let provider: NSItemProvider
  var item: NSItemProviderReading?
}

struct PhotoPicker_Previews: PreviewProvider {
  @State static var didPickPhoto = false
  @State static var results: [PhotoResult] = []
  static var previews: some View {
    PhotoPicker(results: $results, didPickPhoto: $didPickPhoto)
  }
}
