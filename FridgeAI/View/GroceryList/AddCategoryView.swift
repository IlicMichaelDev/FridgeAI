//
//  AddCategoryView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 26.08.25.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    
    @State private var predefinedCategories: [GroceryCategory] = [
        GroceryCategory(name: "Getränke", items: [], systemName: "drop.fill"),
        GroceryCategory(name: "Essen", items: [], systemName: "fork.knife"),
        GroceryCategory(name: "Obst", items: [], systemName: "leaf.fill"),
        GroceryCategory(name: "Gemüse", items: [], systemName: "carrot.fill"),
        GroceryCategory(name: "Fleisch", items: [], systemName: "dumbbell.fill"),
        GroceryCategory(name: "Milchprodukte", items: [], systemName: "drop.fill"),
        GroceryCategory(name: "Haushalt", items: [], systemName: "house.fill"),
        GroceryCategory(name: "Süßigkeiten", items: [], systemName: "birthday.cake.fill"),
        GroceryCategory(name: "Party", items: [], systemName: "party.popper.fill"),
        GroceryCategory(name: "Spielzeug", items: [], systemName: "gamecontroller.fill"),
        GroceryCategory(name: "Medikamente", items: [], systemName: "pills.fill"),
        GroceryCategory(name: "Haustier", items: [], systemName: "pawprint.fill"),
        GroceryCategory(name: "Kleidung", items: [], systemName: "tshirt.fill"),
        GroceryCategory(name: "Technik", items: [], systemName: "desktopcomputer")
    ]
    
    @State private var customCategoryName = ""
    @State private var isAddingCustom = false
    @FocusState private var isTextFieldFocused: Bool
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]
    var selectedSupermarket: Supermarket?
    
    let supermarkets: [Supermarket]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Vorgeschlagene Kategorien")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(predefinedCategories, id: \.self) { category in
                            CategoryCard(
                                name: category.name,
                                icon: category.systemName ?? "questionmark",
                                isSelected: false
                            )
                            .onTapGesture {
                                addCategory(name: category.name, systemName: category.systemName)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Eigene Kategorie erstellen")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            TextField("Kategoriename", text: $customCategoryName)
                                .focused($isTextFieldFocused)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isTextFieldFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            
                            if !customCategoryName.isEmpty {
                                Button(action: addCustomCategory) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .contentTransition(.symbolEffect(.replace))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Neue Kategorie")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addCustomCategory() {
        guard !customCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        addCategory(name: customCategoryName, systemName: "tag.fill")
        customCategoryName = ""
        isTextFieldFocused = false
    }
    
    private func addCategory(name: String, systemName: String? = nil) {
        let supermarket = selectedSupermarket ?? (supermarkets.first ?? Supermarket(name: "keine Wahl", color: .gray))
        
        let newCategory = GroceryCategory(
            name: name,
            items: [GroceryItem(name: "", supermarket: supermarket, anzahl: 1)],
            systemName: systemName
        )
        context.insert(newCategory)
        dismiss()
    }
}

struct CategoryCard: View {
    let name: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    AddCategoryView(supermarkets: [Supermarket(name: "Billa", color: .yellow)])
}
