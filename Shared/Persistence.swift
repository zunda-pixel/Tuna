//
//  Persistence.swift
//  Shared
//
//  Created by zunda on 2022/03/21.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  let container: NSPersistentCloudKitContainer

  init(inMemory: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "Tuna")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("\(error)")
      }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
}
