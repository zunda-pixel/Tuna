//
//  QuotedButton.swift
//  Tuna
//
//  Created by zunda on 2022/06/19.
//

import SwiftUI

struct QuotedButton: View {
  @State var isPresented = false

  let userID: String
  
  var body: some View {
    Button("Quoted Tweet") {
      isPresented.toggle()
    }
    .sheet(isPresented: $isPresented) {
      let viewModel: NewTweetViewModel = .init(userID: userID)
      NewTweetView(viewModel: viewModel)
    }
  }
}

struct QuotedButton_Previews: PreviewProvider {
    static var previews: some View {
        QuotedButton(userID: "")
    }
}
