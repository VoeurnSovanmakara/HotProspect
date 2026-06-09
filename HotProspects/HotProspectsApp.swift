//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by sovanmakara on 8/6/26.
//

import SwiftUI
import SwiftData

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prospect.self)
    }
}
