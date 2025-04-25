//
//  Recipe.swift
//  FridgeAI
//
//  Created by Michael Ilic on 15.04.25.
//

import Foundation

struct FirstAPIResponse: Codable {
    let id: Int
    var missedIngredients: [MissedIngredients]
    var usedIngredients: [UsedIngredients]
}

class Recipe: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String
    var missedIngredients: [MissedIngredients]?
    var usedIngredients: [UsedIngredients]?
    let sourceUrl: String
    let vegetarian: Bool
    let vegan: Bool
    let veryHealthy: Bool
    let nutrition: Nutrition
    let instructions: String
    
    init(id: Int, title: String, image: String, missedIngredients: [MissedIngredients]?, usedIngredients: [UsedIngredients]?, sourceUrl: String, vegetarian: Bool, vegan: Bool, veryHealthy: Bool, nutrition: Nutrition, instructions: String) {
        self.id = id
        self.title = title
        self.image = image
        self.missedIngredients = missedIngredients
        self.usedIngredients = usedIngredients
        self.sourceUrl = sourceUrl
        self.vegetarian = vegetarian
        self.vegan = vegan
        self.veryHealthy = veryHealthy
        self.nutrition = nutrition
        self.instructions = instructions
    }
}


