//
//  benchmarksApp.swift
//  benchmarks
//
//  Created by Tom Ebergen on 8/3/23.
//

import SwiftUI

@main
struct benchmarksApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
