import SwiftUI
import Sweet

protocol NewListDelegate {
  func didCreateList(list: Sweet.ListModel)
}

struct NewListView: View {
  @Environment(\.dismiss) var dismiss
  @State var name = ""
  @State var description = ""
  @State var isPrivate = false

  let userID: String
  let delegate: NewListDelegate

  @State var error: Error?
  @State var didError = false

  var disableCreateList: Bool {
    name.isEmpty
  }

  func createList() async {
    do {
      let newList = try await Sweet(userID: userID).createList(name: name, description: description, isPrivate: isPrivate)
      let response = try await Sweet(userID: userID).fetchList(listID: newList.id)
      delegate.didCreateList(list: response.list)

      dismiss()
    } catch let newError {
      error = newError
      didError.toggle()
    }
  }

  var body: some View {
    NavigationStack {
      List {
        TextField("Name", text: $name)
        TextField("Description", text: $description)
        Toggle("Private", isOn: $isPrivate)
      }
      .alert("Error", isPresented: $didError) {
        Button("Close") {
          print(error!)
        }
      }
      .navigationTitle("New List")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Save") {
            Task {
              await createList()
            }
          }
          .disabled(disableCreateList)

        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }

  }
}
