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
    
    @StateObject private var recipevm = RecipeViewModel()
    //    @StateObject var networkManager = NetworkCalls()
    
    @State private var pickerState = true
    @State private var showScannerView = false
    @State private var showDetailView = false
    @State private var showSettingsView = false
    @State private var showPremiumSheet = false
    
    @State private var scannedCode: String?
    @State private var selectedIngredient: Ingredient?
    
    @State private var showAddIngredientView = false
    
    @Query(sort: \Ingredient.name) var ingredients: [Ingredient]
    
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
                    
                    // Wenn der QR-Code gescannt wurde dann soll sich eine kleine View öffnen wo di eDaten automatisch eingetragen werden
                    if pickerState {
                        HStack {
                            TextField("Zutat", text: $recipevm.newIngredientName)
                            Button {
                                recipevm.isScanning = true
                            } label: {
                                Image(systemName: "camera.viewfinder")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(style: StrokeStyle(dash: [5]))
                        }
                        .padding()
                        
                        if ingredients.isEmpty {
                            ContentUnavailableView("Du hast nichts im Kühlschrank, du musst einkaufen gehen.", systemImage: "figure.walk.departure")
                        } else {
                            List {
                                ForEach(ingredients) { ingredient in
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
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                context.delete(ingredient)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                                    .onTapGesture {
                                        selectedIngredient = ingredient
                                        showDetailView = true
                                    }
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .padding(.vertical, 4)
                                        .padding(.horizontal)
                                )
                            }
                            .listStyle(.plain)
                            
                            .sheet(isPresented: $recipevm.isScanning) {
                                CodeScannerView(codeTypes: [.ean8, .ean13, .upce], completion: recipevm.handleScan)
                            }
                            
                        }
                        
                        //                    HStack {
                        //                        Button {
                        //                            recipevm.addIngredient(context: context)
                        //                        } label: {
                        //                            Text("+ Zutat")
                        //                                .foregroundStyle(.white)
                        //                                .padding()
                        //                                .frame(maxWidth: .infinity)
                        //                                .background {
                        //                                    RoundedRectangle(cornerRadius: 10)
                        //                                        .foregroundStyle(.green)
                        //                                }
                        //                        }
                        //                        Button {
                        //                            pickerState = false
                        //                            // Für Testzwecke damit ich sehe welche API verwendet wird
                        //                            let ingredientList = ingredients.map { $0.name }.joined(separator: ",")
                        //                            let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientList)&number=5&apiKey=c19d4c45bb38487fb4faebbffe4b7246&includeNutrition=true"
                        //                            print("API URL: \(urlString)")
                        //                            print(recipevm.recipes.count)
                        //
                        //                            recipevm.firstAPICall(ingredients: ingredients) { responses in
                        //                                guard let responses = responses else { return }
                        //
                        //                                DispatchQueue.main.async {
                        //                                    if let firstID = responses.first?.id {
                        //                                        self.recipevm.fetchRecipesInformation(id: firstID)
                        //                                    }
                        //                                }
                        //                            }
                        //                        } label: {
                        //                            Text("Rezept finden")
                        //                                .foregroundStyle(.white)
                        //                                .frame(maxWidth: .infinity)
                        //                                .padding()
                        //                                .background {
                        //                                    RoundedRectangle(cornerRadius: 10)
                        //                                        .foregroundStyle(.blue)
                        //                                }
                        //                        }
                        //                        if recipevm.isLoading {
                        //                            ProgressView()
                        //                        }
                        //                    }
                        //                    .padding(.horizontal)
                        
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
                                        .fill(LinearGradient(colors: [Color.red, Color.orange, Color.blue], startPoint: .leading, endPoint: .trailing))
                                }
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            
            Menu {
                Button {
//                    recipevm.addIngredient(context: context)
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
        .sheet(isPresented: $showDetailView) {
            if let ingredient = selectedIngredient {
                IngredientDetailView(ingredient: ingredient)
                    .presentationDetents([.height(280)])
                    .presentationCornerRadius(20)
                    .presentationDragIndicator(.visible)
            }
        }
    }
    

}

struct RecipeResultsView: View {
    
    let recipe: Recipe
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: recipe.image)) { image in
                image
                    .resizable()
                    .frame(width: 90, height: 70)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Rectangle()
                    .frame(width: 90, height: 70)
                    .foregroundStyle(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.title)
                Text(getActiveTags())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func getActiveTags() -> String {
        var tags = [String]()
        if recipe.vegetarian && recipe.vegan { tags.append("Vegan") } else {
            if recipe.vegetarian { tags.append("Vegetarisch") }
            if recipe.vegan { tags.append("Vegan") }
        }
        if recipe.veryHealthy { tags.append("Sehr gesund") }
        return tags.joined(separator: ", ")
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

#Preview {
    IngredientView()
}
