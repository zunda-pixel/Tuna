//
//  TunaApp.swift
//  Shared
//
//  Created by zunda on 2022/03/21.
//

import SwiftUI

@main
struct TunaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
