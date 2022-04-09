//
//  ListView.swift
//  Tuna
//
//  Created by zunda on 2022/03/29.
//

import SwiftUI
import Sweet

struct ListCellView: View {
  public let list: Sweet.ListModel
  
  var body: some View {
    HStack {
      Image(systemName: "person")
        .padding()
        .background(.red)
        .cornerRadius(12)

      VStack(alignment: .leading) {
        HStack {
          Text(list.name)
          if let description = list.description {
            Text(description)
              .foregroundColor(.gray)
          }
        }
        .lineLimit(1)
        
        Text(list.ownerID ?? "nothing")
      }
      Spacer()
      if list.isPrivate ?? false {
        Image(systemName: "key")
      }
    }
  }
}

struct ListView_Previews: PreviewProvider {
  static var previews: some View {
    ListCellView(list: .init(id: "", name: ""))
  }
}
