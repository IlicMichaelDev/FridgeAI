//
//  Extensions.swift
//  FridgeAI
//
//  Created by Michael Ilic on 23.04.25.
//

import Foundation
import SwiftUI

extension Recipe {
    func filteredNutritions() -> [Nutrient] {
        return nutrition.nutrients.filter { nutrient in
            let relevantNutrients = ["Calories", "Protein", "Fat", "Carbohydrates"]
            return relevantNutrients.contains(nutrient.name)
        }
    }
}

