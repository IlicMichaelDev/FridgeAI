//
//  Nutrition.swift
//  FridgeAI
//
//  Created by Michael Ilic on 23.04.25.
//

import Foundation
import SwiftUI

struct Nutrition: Codable {
    let nutrients: [Nutrient]
    let caloricBreakdown: CaloricBreakdown
}

struct Nutrient: Codable, Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let unit: String
    let percentOfDailyNeeds: Double
}

struct CaloricBreakdown: Codable {
    let percentProtein: Double
    let percentFat: Double
    let percentCarbs: Double
}

enum GaugeColor: String {
    case protein = "Protein"
    case fat = "Fat"
    
    var color: Color {
        switch self {
        case .protein: return .red
        case .fat: return .green
        }
    }
}
