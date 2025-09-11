//
//  GroceryList.swift
//  FridgeAI
//
//  Created by Michael Ilic on 26.08.25.
//

import Foundation
import SwiftUI
import SwiftData

struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    init(color: Color) {
         let uiColor = UIColor(color)
         var red: CGFloat = 0
         var green: CGFloat = 0
         var blue: CGFloat = 0
         var alpha: CGFloat = 0
         
        // & bedeutet "Adresse von" - Es gibt nicht den Wert der Variable weiter, sondern die Speicheradresse wo die Variable gespeichert ist.
        // Beispiel: Die Funktion ist wie wenn du jemandem vier leere Eimer gibst und sagst: "Füll die bitte mit den Farbwerten!" Die Methode füllt dann direkt deine Eimer (Variablen) statt dir neue Eimer zu geben. Das & ist wie das Aufschreiben der Adresse auf die Eimer, damit man weiß wo man die Farbe hinschütten soll
         uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
         
         self.red = Double(red)
         self.green = Double(green)
         self.blue = Double(blue)
         self.alpha = Double(alpha)
     }
}

@Model
class Supermarket: Codable {
    var id: UUID
    var name: String
    var codableColor: CodableColor
    var createdAt: Date
    
    var color: Color {
        codableColor.color
    }
    
    init(name: String, color: Color) {
        self.id = UUID()
        self.name = name
        self.codableColor = CodableColor(color: color)
        self.createdAt = Date()
    }
    
    static var standardSupermarkets = [
        Supermarket(name: "Billa", color: .yellow),
        Supermarket(name: "Spar", color: .green),
        Supermarket(name: "Hofer", color: .orange),
        Supermarket(name: "Lidl", color: .red),
        Supermarket(name: "Bipa", color: .purple)
    ]
    
    static func addStandardSupermaerkte(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Supermarket>()
        do {
            let existingSupermarkets = try context.fetch(fetchDescriptor)
            
            if existingSupermarkets.isEmpty {
                for supermarket in standardSupermarkets {
                    context.insert(supermarket)
                }
                try context.save()
                print("Standard-Supermärkte wurden hinzugefügt")
            }
        } catch {
            print("Fehler beim Hinzufügen von Standarddaten: \(error)")
        }
    }
    
    // CodingKeys fürs De- & Encoden
    enum CodingKeys: CodingKey {
        case id, name, codableColor, createdAt
    }
    
    //Decoden
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        codableColor = try container.decode(CodableColor.self, forKey: .codableColor)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    // Encoden
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(codableColor, forKey: .codableColor)
    }
}

enum Einheit: CaseIterable, Codable {
    case portion
    case gramm
    case milliliter
    case liter
    
    var asString: String {
        return "\(self)".capitalized
    }
    
    var kurz: String {
        switch self {
        case .portion: return "x"
        case .gramm: return "g"
        case .milliliter: return "ml"
        case .liter: return "l"
        }
    }
}

@Model
class GroceryCategory: Identifiable, ObservableObject {
    var id = UUID()
    var name: String
    var items: [GroceryItem]
    var systemName: String?
    var createdAt: Date
    
    init(name: String, items: [GroceryItem], systemName: String? = nil) {
        self.name = name
        self.items = items
        self.systemName = systemName
        self.createdAt = Date()
    }
}

@Model
class GroceryItem: Identifiable, ObservableObject {
    var id = UUID()
    var name: String
    var supermarket: Supermarket
    var einheit: Einheit
    var anzahl: Int
    var isDone: Bool
    
    init(name: String, supermarket: Supermarket, einheit: Einheit = .portion, anzahl: Int, isDone: Bool = false) {
        self.name = name
        self.supermarket = supermarket
        self.einheit = einheit
        self.anzahl = anzahl
        self.isDone = isDone
    }
}
