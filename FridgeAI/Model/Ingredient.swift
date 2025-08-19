//
//  Ingredient.swift
//  FridgeAI
//
//  Created by Michael Ilic on 15.04.25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Ingredient: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Int
    var category: IngredientCategory
    var imageData: Data?
    
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    func setImage(_ image: UIImage) {
        self.imageData = image.jpegData(compressionQuality: 0.8)
    }
    
    init(name: String, amount: Int, category: IngredientCategory, imageData: Data?) {
        self.name = name
        self.amount = amount
        self.imageData = imageData
        self.category = category
    }

    // Durch @Model Makro wird meine Klasse nicht mehr Codable weil dieses Makro weiteren Code hinzufügt welche dem Protokoll nicht passen. Hier unten schreiben wir unseren eigenen Decodable & Encodable Code.
    enum CodingKeys: CodingKey {
        case id, name, amount, category, imageData
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        amount = try container.decode(Int.self, forKey: .amount)
        category = try container.decode(IngredientCategory.self, forKey: .category)
        imageData = try container.decode(Data.self, forKey: .imageData)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
        try container.encode(category, forKey: .category)
        try container.encode(imageData, forKey: .imageData)
    }
}

struct MissedIngredients: Codable, Identifiable {
    let id: Int
    let name: String
}

struct UsedIngredients: Codable, Identifiable {
    let id: Int
    let name: String
}

enum IngredientCategory: String, CaseIterable, Codable {
    case fruit = "Obst"
    case vegetables = "Gemüse"
    case dairy = "Milchprodukte"
    case meat = "Fleisch"
    case grains = "Getreide"
    case spices = "Gewürze"
    case beverages = "Getränke"
    case other = "Sonstiges"
    
    var iconName: String {
        switch self {
        case .fruit: return "apple.logo"
        case .vegetables: return "carrot.fill"
        case .dairy: return "waterbottle.fill"
        case .meat: return "fork.knife"
        case .grains: return "leaf.fill"
        case .spices: return "sparkles"
        case .beverages: return "mug.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .fruit: return Color.orange.opacity(0.2)
        case .vegetables: return Color.green.opacity(0.2)
        case .dairy: return Color.blue.opacity(0.2)
        case .meat: return Color.red.opacity(0.2)
        case .grains: return Color.yellow.opacity(0.2)
        case .spices: return Color.purple.opacity(0.2)
        case .beverages: return Color.cyan.opacity(0.2)
        case .other: return Color.gray.opacity(0.2)
        }
    }
    
    var iconColor: Color {
        switch self {
        case .fruit: return .orange
        case .vegetables: return .green
        case .dairy: return .blue
        case .meat: return .red
        case .grains: return .yellow
        case .spices: return .purple
        case .beverages: return .cyan
        case .other: return .gray
        }
    }
}
