//
//  ContentView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                IngredientView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
