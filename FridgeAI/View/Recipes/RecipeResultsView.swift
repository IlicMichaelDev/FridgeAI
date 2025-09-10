//
//  RecipeResultsView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 21.08.25.
//

import SwiftUI

struct RecipeResultsView: View {
    
    let recipe: Recipe
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: recipe.image)) { image in
                image
                    .resizable()
                    .frame(width: 90, height: 70)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Rectangle()
                    .frame(width: 90, height: 70)
                    .foregroundStyle(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.title)
                Text(getActiveTags())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func getActiveTags() -> String {
        var tags = [String]()
        if recipe.vegetarian && recipe.vegan { tags.append("Vegan") } else {
            if recipe.vegetarian { tags.append("Vegetarisch") }
            if recipe.vegan { tags.append("Vegan") }
        }
        if recipe.veryHealthy { tags.append("Sehr gesund") }
        return tags.joined(separator: ", ")
    }
}

//#Preview {
//    RecipeResultsView()
//}
