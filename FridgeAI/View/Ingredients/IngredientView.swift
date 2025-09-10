//
//  ContentView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 14.04.25.
//

import SwiftUI
import CodeScanner
import SwiftData

struct IngredientView: View {
    
    @Environment(\.modelContext) var context
    @EnvironmentObject var authVM: AuthViewModel
    
    @Query(sort: \Ingredient.name) var ingredients: [Ingredient]
    
    @StateObject private var recipevm = RecipeViewModel()
    
    @State private var pickerState = true
    @State private var showScannerView = false
    @State private var showSettingsView = false
    @State private var showPremiumSheet = false
    @State private var isFiltering = false
    
    @State private var scannedCode: String?
    @State private var searchText = ""
    @State private var selectedCategories: Set <IngredientCategory> = []
    
    @State private var showAddIngredientView = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                VStack {
                    Picker("", selection: $pickerState) {
                        Text("Zutaten").tag(true)
                        Text("Rezepte").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .overlay(alignment: .trailing) {
                        Button {
                            if pickerState {
                                // Rezept finden Logik
                                pickerState = false
                                // Für Testzwecke damit ich sehe welche API verwendet wird
                                let ingredientList = ingredients.map { $0.name }.joined(separator: ",")
                                let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientList)&number=5&apiKey=c19d4c45bb38487fb4faebbffe4b7246&includeNutrition=true"
                                print("API URL: \(urlString)")
                                print(recipevm.recipes.count)
                                
                                recipevm.firstAPICall(ingredients: ingredients) { responses in
                                    guard let responses = responses else { return }
                                    
                                    DispatchQueue.main.async {
                                        if let firstID = responses.first?.id {
                                            self.recipevm.fetchRecipesInformation(id: firstID)
                                        }
                                    }
                                }
                            } else {
                                pickerState = true
                            }
                        } label: {
                            Image(systemName: pickerState ? "arrow.right" : "arrow.left")
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .padding(.trailing, 8)
                        }
                    }
                    
                    if pickerState {
                        SearchFilterBar(searchText: $searchText, isFiltering: $isFiltering, selectedCategories: $selectedCategories)
                            .padding(.bottom, 8)

                        if ingredients.isEmpty {
                            ContentUnavailableView("Du hast nichts im Kühlschrank, du musst einkaufen gehen.", systemImage: "figure.walk.departure")
                        } else {
                            IngredientListView(recipevm: recipevm, searchText: $searchText, selectedCategories: $selectedCategories, ingredients: ingredients)
                        }
                    } else {
                        if recipevm.recipes.isEmpty {
                            ContentUnavailableView("Du musst zuerst Zutaten hinzufügen damit ich dir ein gutes Rezept empfehlen kann.", systemImage: "oven")
                        }
                        List {
                            //Für testzwecke statt '.recipes' - '.testRecipes' eingeben
                            ForEach(recipevm.recipes, id: \.id) { recipe in
                                NavigationLink(destination: RecipeView(ingredients: ingredients, recipe: recipe)) {
                                    RecipeResultsView(recipe: recipe)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showSettingsView = true
                        } label: {
                            HStack {
                                Image(systemName: "gear")
                                Text("Einstellungen")
                            }
                            .padding(.vertical, 3)
                            .padding(.horizontal, 7)
                            .foregroundStyle(.gray)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke()
                                    .tint(.gray)
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showPremiumSheet = true
                        } label: {
                            Text("Upgrade Version")
                                .foregroundStyle(.white)
                                .padding(5)
                                .bold()
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(
                                            colors: [Color.blue.opacity(0.8),
                                            Color.purple.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                }
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            PlusButton()
        }
        .fullScreenCover(isPresented: $showSettingsView) {
            SettingsView(showSettingsView: $showSettingsView)
        }
        .fullScreenCover(isPresented: $showPremiumSheet) {
            PremiumPlanView()
        }
        .sheet(isPresented: $showAddIngredientView) {
            AddIngredientView()
                .presentationDetents([.fraction(0.7), .large])
                .presentationCornerRadius(20)
                .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    private func PlusButton() -> some View {
        Menu {
            Button {
                showAddIngredientView = true
            } label: {
                Label("Zutat hinzufügen", systemImage: "plus")
            }
            
            Button {
                recipevm.isScanning = true
            } label: {
                Label("QR-Code scannen", systemImage: "camera.viewfinder")
            }
        } label: {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
        }
        .padding()
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

struct SearchFilterBar: View {
    @Binding var searchText: String
    @Binding var isFiltering: Bool
    @Binding var selectedCategories: Set<IngredientCategory>
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Zutat suchen", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            FilterButton(isFiltering: $isFiltering, selectedCategories: $selectedCategories)
        }
        .padding(.horizontal)
    }
}

struct FilterButton: View {
    @Binding var isFiltering: Bool
    @Binding var selectedCategories: Set<IngredientCategory>
    
    var body: some View {
        Menu {
            ForEach(IngredientCategory.allCases, id: \.self) { category in
                Button {
                    if selectedCategories.contains(category) {
                        selectedCategories.remove(category)
                    } else {
                        selectedCategories.insert(category)
                    }
                    
                    isFiltering = !selectedCategories.isEmpty
                } label: {
                    HStack {
                        if selectedCategories.contains(category) {
                            Image(systemName: "checkmark.square.fill")
                        } else {
                            Image(systemName: "square")
                        }
                        
                        Text(category.rawValue)
                    }
                }
                .menuActionDismissBehavior(.disabled)
            }
            
            // Trennlinie und Reset-Button
            Divider()
            
            Button(role: .destructive) {
                selectedCategories.removeAll()
                isFiltering = false
            } label: {
                Label("Alle Filter entfernen", systemImage: "trash")
            }
            .disabled(selectedCategories.isEmpty)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .font(.system(size: 18, weight: .medium))
                
                Text("Filter")
                    .font(.system(size: 14, weight: .medium))
                
                // Badge mit Anzahl aktiver Filter
                if !selectedCategories.isEmpty {
                    Text("\(selectedCategories.count)")
                        .font(.system(size: 12, weight: .bold))
                        .padding(4)
                        .frame(minWidth: 18)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isFiltering ? Color.blue : Color(.systemBackground))
            .foregroundColor(isFiltering ? .white : .blue)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    IngredientView()
}
