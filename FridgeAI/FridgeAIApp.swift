//
//  FridgeAIApp.swift
//  FridgeAI
//
//  Created by Michael Ilic on 14.04.25.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct FridgeAIApp: App {
    @StateObject var authVM = AuthViewModel()
    
    let container: ModelContainer = {
        let schema = Schema([Ingredient.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .modelContainer(container)
        }
    }
}
