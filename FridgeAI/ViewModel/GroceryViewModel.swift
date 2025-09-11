//
//  GroceryViewModel.swift
//  FridgeAI
//
//  Created by Michael Ilic on 11.09.25.
//

import Foundation
import SwiftUI
import SwiftData

class GroceryViewModel: ObservableObject {
    
    @Published var isEditing: Bool = false
    @Published var isAddingNew: Bool = false
    @Published var newSupermarketName: String = ""
    @Published var newSupermarketColor: Color = .blue
    @Published var supermarketsToDelete: Set<UUID> = []
    
    func calculateDetent(supermarkets: [Supermarket]) -> PresentationDetent {
        if isEditing {
            return supermarkets.count > 5 ? .fraction(0.7) : .fraction(0.55)
        } else {
            if supermarkets.count > 5 {
                return isAddingNew ? .fraction(0.7) : .fraction(0.45)
            } else {
                return isAddingNew ? .fraction(0.6) : .fraction(0.35)
            }
        }
    }
    
    func addNewSupermarket(context: ModelContext) {
        let newSupermarket = Supermarket(name: newSupermarketName, color: newSupermarketColor)
        Supermarket.standardSupermarkets.append(newSupermarket)
        context.insert(newSupermarket)
        newSupermarketName = ""
        isAddingNew = false
    }
    
    // Durch inout kann ich den Parameter in der Funktion ändern und das Ergebnis außerhalb der func weitergeben - so wie hier selectedSupermarkt
    func deleteSupermarkets(supermarkets: [Supermarket], selectedSupermarket: inout Supermarket, context: ModelContext) {
        for supermarketId in supermarketsToDelete {
            if let supermarket = supermarkets.first(where: { $0.id == supermarketId }) {
                // Prüfen, ob der zu löschende Supermarkt der aktuell ausgewählte ist
                if supermarket.id == selectedSupermarket.id {
                    // Fallback auf den ersten verfügbaren Supermarkt
                    selectedSupermarket = supermarkets.first(where: { $0.id != supermarketId }) ?? Supermarket(name: "Allgemein", color: .gray)
                }
                context.delete(supermarket)
            }
        }
        supermarketsToDelete.removeAll()
        isEditing = false
    }
}
