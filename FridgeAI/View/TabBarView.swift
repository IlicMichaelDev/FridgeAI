//
//  TabView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 26.08.25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            IngredientView()
                .tabItem {
                    Label("Kühlschrank", systemImage: "refrigerator")
                }
            
            GroceryListView()
                .tabItem {
                    Label("Einkaufsliste", systemImage: "cart")
                }
        }
    }
}

#Preview {
    TabBarView()
}
