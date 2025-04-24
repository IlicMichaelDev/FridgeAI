//
//  Ingredient.swift
//  FridgeAI
//
//  Created by Michael Ilic on 15.04.25.
//

import Foundation
import SwiftUI

struct Ingredient: Identifiable, Codable {
    let id = UUID()
    var name: String
    var amount: Int
}

struct MissedIngredients: Codable, Identifiable {
    let id: Int
    let name: String
}

struct UsedIngredients: Codable, Identifiable {
    let id: Int
    let name: String
}
