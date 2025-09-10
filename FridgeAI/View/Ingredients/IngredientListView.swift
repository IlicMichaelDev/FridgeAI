//
//  IngredientListView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 21.08.25.
//

import SwiftUI
import CodeScanner
import SwiftData

struct IngredientListView: View {
    
    @Environment(\.modelContext) var context
    
    @ObservedObject var recipevm: RecipeViewModel
    
    @State private var showDetailView: Bool = false
    @State private var sheetIngredient: Ingredient? = nil
    
    @Binding var searchText: String
    @Binding var selectedCategories: Set<IngredientCategory>
    
    let ingredients: [Ingredient]
    
    var filteredIngredients: [Ingredient] {
        let categoryFiltered = selectedCategories.isEmpty ? ingredients : ingredients.filter { selectedCategories.contains($0.category) }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { $0.name.localizedStandardContains(searchText)}
        }
    }
    
    var groupedIngredients: [IngredientCategory: [Ingredient]] {
        Dictionary(grouping: filteredIngredients, by: { $0.category })
    }
    
    var body: some View {
        List {
            let categoryToShow = selectedCategories.isEmpty ? IngredientCategory.allCases : Array(selectedCategories)
            
            ForEach(categoryToShow, id: \.self) { category in
                if let categoryIngredients = groupedIngredients[category] {
                    Section {
                        ForEach(categoryIngredients) { ingredient in
                            HStack(spacing: 12) {
                                if let image = ingredient.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Image(systemName: "\(ingredient.category.iconName)")
                                        .foregroundColor(ingredient.category.iconColor)
                                        .frame(width: 40, height: 40)
                                        .background(ingredient.category.backgroundColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                Text(ingredient.name)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Button {
                                        guard ingredient.amount >= 1 else { return }
                                        withAnimation(.spring()) {
                                            ingredient.amount -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(ingredient.amount > 0 ? .red : .gray)
                                    }
                                    .disabled(ingredient.amount <= 0)
                                    
                                    Text("\(ingredient.amount)")
                                        .font(.system(.body, design: .monospaced))
                                        .frame(minWidth: 30)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Capsule())
                                    
                                    Button {
                                        withAnimation(.spring()) {
                                            ingredient.amount += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.green)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                            .onTapGesture {
                                sheetIngredient = ingredient
                                showDetailView = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        context.delete(ingredient)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: category.iconName)
                                .foregroundStyle(category.iconColor)
                            Text("\(category.rawValue): \(categoryIngredients.count)")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .padding(.vertical, 4)
                    .padding(.horizontal)
            )
            
            if filteredIngredients.isEmpty {
                ContentUnavailableView("Keine \(searchText) gefunden", systemImage: "magnifyingglass", description: Text("In deinem Inventar befindet sich keine entsprechende Zutat. Bitte schaue nochmal nach ob das Produkt richtig buchstabiert wurde."))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        
        .sheet(isPresented: $recipevm.isScanning) {
            CodeScannerView(codeTypes: [.ean8, .ean13, .upce], completion: recipevm.handleScan)
        }
        
        .sheet(item: $sheetIngredient) { ingredient in
//            if let ingredient = selectedIngredient {
                IngredientDetailView(ingredient: ingredient)
                    .presentationDetents([.height(280)])
                    .presentationCornerRadius(20)
                    .presentationDragIndicator(.visible)
//            }
        }
    }
}

//#Preview {
//    IngredientListView()
//}
