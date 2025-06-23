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
    @State private var isScanning = false
    @State private var showDetailView = false
    @State private var showSettingsView = false
    @State private var showPremiumSheet = false
    
    @State private var scannedCode: String?
    @State private var productName: String?
    
    @Query var ingredients: [Ingredient]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $pickerState) {
                    Text("Zutaten").tag(true)
                    Text("Rezepte").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .navigationTitle("Mein Kühlschrank")
                
                if pickerState {
                    HStack {
                        TextField("Zutat", text: $recipevm.newIngredientName)
                        Button {
                            isScanning = true
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
                    
//                    if recipevm.ingredients.isEmpty {
                    if ingredients.isEmpty {
                        ContentUnavailableView("Du hast nichts im Kühlschrank, du musst einkaufen gehen.", systemImage: "figure.walk.departure")
                    } else {
                        List {
//                            ForEach(recipevm.ingredients) { ingredient in
                            ForEach(ingredients) { ingredient in
                                HStack {
                                    Text("•")
                                        .font(.title)
                                    Text(ingredient.name)
                                    
                                    Spacer()
                                    
                                    Text("-")
                                        .font(.system(size: 26))
                                        .foregroundStyle(.red)
                                        .onTapGesture {
//                                            recipevm.updateIngredientAmount(for: ingredient.id, newAmount: ingredient.amount - 1)
                                            guard ingredient.amount >= 1 else { return }
                                            ingredient.amount -= 1
                                        }
                                    Text("\(ingredient.amount)")
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .background {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                    Text("+")
                                        .font(.system(size: 26))
                                        .foregroundStyle(.green)
                                        .onTapGesture {
//                                            recipevm.updateIngredientAmount(for: ingredient.id, newAmount: ingredient.amount + 1)
                                            ingredient.amount += 1
                                        }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        context.delete(ingredient)
                                    }
                                }
                            }
//                            .onDelete(perform: recipevm.deleteIngredient)
                        }
                        .listStyle(.plain)
                        
                        
                        .onChange(of: productName) {
                            if let name = productName {
//                                recipevm.ingredients.append(Ingredient(name: name, amount: 1))
//                                let newIngredient = Ingredient(name: name, amount: 1)
//                                context.insert(newIngredient)
                                let newIngredient = Ingredient(name: name, amount: 1)
                                context.insert(newIngredient)
                            } else {
                                print("No available")
                            }
                        }
                        .sheet(isPresented: $isScanning) {
                            CodeScannerView(codeTypes: [.ean8, .ean13, .upce], completion: handleScan)
                        }
                        
                        .sheet(isPresented: $showDetailView) {
                            
                        }
                    }
                    
                    HStack {
                        Button {
                            recipevm.addIngredient(context: context)
                        } label: {
                            Text("+ Zutat")
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(.green)
                                }
                        }
                        Button {
                            pickerState = false
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
                            
                        } label: {
                            Text("Rezept finden")
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(.blue)
                                }
                        }                        
                        if recipevm.isLoading {
                            ProgressView()
                        }
                    }
                    .padding(.horizontal)
                } else {
                    if recipevm.recipes.isEmpty {
                        ContentUnavailableView("Du musst zuerst Zutaten hinzufügen damit ich dir ein gutes Rezept empfehlen kann.", systemImage: "oven")
                    }
                    List {
                        //Für testzwecke statt '.recipes' - '.testRecipes' eingeben
                        ForEach(recipevm.recipes, id: \.id) { recipe in
                            NavigationLink(destination: RecipeView(recipe: recipe)) {
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
                
//                ToolbarItem(placement: .topBarTrailing) {
//                    HStack(alignment: .center, spacing: 4) {
//                        Image(systemName: "flame.fill")
//                            .foregroundStyle(Gradient(colors: [Color.orange, Color.red]))
//                        Text("2")
//                    }
//                }
                
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
        }
        .fullScreenCover(isPresented: $showSettingsView) {
            SettingsView(showSettingsView: $showSettingsView)
        }
        .fullScreenCover(isPresented: $showPremiumSheet) {
            PremiumPlanView()
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isScanning = false
        switch result {
        case .success(let scanResult):
//            scannedCode = scanResult.string
            fetchProductInfo(from: scanResult.string)
        case .failure(let error):
            print("Scan-Fehler: \(error.localizedDescription)")
        }
    }
    
    func fetchProductInfo(from barcode: String) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let product = try? JSONDecoder().decode(ProductResponse.self, from: data) {
                    DispatchQueue.main.async {
                        productName = product.product.product_name ?? "Unbekanntes Produkt"
                    }
                }
            }
        }.resume()
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

struct PremiumPlanView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Premium Pläne")
                    .font(.system(size: 24, weight: .bold, design: .default))
                
                ScrollView(.horizontal) {
                    HStack {
                        PremiumCard(image: "crown.fill", version: "Pro", gradientColors: [Color.blue, Color.cyan], preis: "3")
                        PremiumCard(image: "diamond.fill", version: "Premium", gradientColors: [Color.pink, Color.purple], preis: "5")
                    }
                }
                .padding(.horizontal)
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.gray)
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background {
                                Circle()
                                    .fill(.gray.opacity(0.2))
                            }
                    }
                }
            }
        }
    }
}

struct PremiumCard: View {
    
    let image: String
    let version: String
    let gradientColors: [Color]
    let preis: String
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 250, height: 500)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: image)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(Color.gray.opacity(0.8))
                        }
                    
                    Text(version)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                }
                .padding(.top)
                
                VorteilRow(vorteil: "3 Rezepte pro Tag")
                    .padding(.top)
                VorteilRow(vorteil: "QR-Code Scanner")
                VorteilRow(vorteil: "Test")
                
            }
            
            Button {
                
            } label: {
                Text("\(preis)€ pro Monat")
                    .foregroundStyle(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                    .padding()
                    .font(.system(size: 18))
                    .bold()
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                    }
            }
            .padding(.top, 420)
        }
    }
    
    @ViewBuilder
    private func VorteilRow(vorteil: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            
            Text(vorteil)
                .font(.system(size: 18))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    IngredientView()
}
