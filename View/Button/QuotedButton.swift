//
//  QuotedButton.swift
//  Tuna
//
//  Created by zunda on 2022/06/19.
//

import SwiftUI

struct QuotedButton: View {
  @Binding var isPresentedNewTweetView: Bool

  let userID: String
  
  var body: some View {
    Button("Quoted Tweet") {
      isPresentedNewTweetView.toggle()
    }
  }
}
