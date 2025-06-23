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
    
    init(name: String, amount: Int) {
        self.name = name
        self.amount = amount
    }

    // Durch @Model Makro wird meine Klasse nicht mehr Codable weil dieses Makro weiteren Code hinzufügt welche dem Protokoll nicht passen. Hier unten schreiben wir unseren eigenen Decodable & Encodable Code.
    enum CodingKeys: CodingKey {
        case id, name, amount
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        amount = try container.decode(Int.self, forKey: .amount)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
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
