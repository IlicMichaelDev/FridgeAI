//
//  ContentView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 14.04.25.
//

import SwiftUI
import CodeScanner

struct IngredientView: View {
    
    @StateObject private var recipevm = RecipeViewModel()
    //    @StateObject var networkManager = NetworkCalls()
    
    @State private var pickerState = true
    @State private var showScannerView = false
    @State private var isScanning = false
    @State private var showDetailView = false
    @State private var showSettingsView = false
    
    @State private var scannedCode: String?
    @State private var productName: String?
    
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
                    
                    
                    if recipevm.ingredients.isEmpty {
                        ContentUnavailableView("Du hast nichts im Kühlschrank, du musst einkaufen gehen.", systemImage: "figure.walk.departure")
                    } else {
                        List {
                            ForEach(recipevm.ingredients) { ingredient in
                                HStack {
                                    Text("•")
                                        .font(.title)
                                    Text(ingredient.name)
                                    
                                    Spacer()
                                    
                                    Text("-")
                                        .font(.system(size: 26))
                                        .foregroundStyle(.red)
                                        .onTapGesture {
                                            recipevm.updateIngredientAmount(for: ingredient.id, newAmount: ingredient.amount - 1)
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
                                            recipevm.updateIngredientAmount(for: ingredient.id, newAmount: ingredient.amount + 1)
                                        }
                                }
                                .onTapGesture {
                                    //                                showDetailView = true
                                }
                            }
                            .onDelete(perform: recipevm.deleteIngredient)
                        }
                        .listStyle(.plain)
                        
                        
                        .onChange(of: productName) {
                            if let name = productName {
                                recipevm.ingredients.append(Ingredient(name: name, amount: 1))
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
                    
                    //                    HStack {
                    //                        Button {
                    //                            recipevm.addIngredient()
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
                    //
                    //                        Button {
                    //                            isScanning = true
                    //                        } label: {
                    //                            Text("QR-Code scannen")
                    //                                .foregroundStyle(.white)
                    //                                .padding()
                    //                                .frame(maxWidth: .infinity)
                    //                                .background {
                    //                                    RoundedRectangle(cornerRadius: 10)
                    //                                        .foregroundStyle(.orange)
                    //                                }
                    //                        }
                    //                    }
                    //                    .padding(.horizontal)
                    
                    HStack {
                        Button {
                            recipevm.addIngredient()
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
                            recipevm.firstAPICall { responses in
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Gradient(colors: [Color.orange, Color.red]))
                        Text("2")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSettingsView) {
            SettingsView(showSettingsView: $showSettingsView)
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isScanning = false
        switch result {
        case .success(let scanResult):
            scannedCode = scanResult.string
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

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var toggleDarkmode = false
    @State private var toggleNotifications = false
    @State private var toggleFaceID = false
    @State private var togglePINCode = false
    
    @Binding var showSettingsView: Bool
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Circle()
                    .frame(width: 100, height: 100)
                Text("Michael Ilic")
                    .font(.title2)
                    .bold()
                Text("michi.ilic.hotmail.com")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                
                List {
                    Section("Account") {
                        buttonWithAction("Profil", systemName: "person") {
                            
                        }
                        buttonWithAction("Favoriten", systemName: "star") {
                            
                        }
                    }
                    
                    Section("Generell") {
                        toggleButton(systemImage: "moon.stars", title: "Darkmode", toggle: $toggleDarkmode)
                    }
                    
                    Section("Sicherheit & Benachrichtigung") {
                        toggleButton(systemImage: "bell.badge", title: "Benachrichtung", toggle: $toggleNotifications)
                        toggleButton(systemImage: "faceid", title: "Face ID", toggle: $toggleFaceID)
                        toggleButton(systemImage: "circle.grid.3x3", title: "PIN Code", toggle: $togglePINCode)
                    }
                    
                    Section("Feedback") {
                        buttonWithAction("Verbesserungsvorschläge", systemName: "envelope") {
                            
                        }
                        buttonWithAction("Bug melden", systemName: "exclamationmark") {
                            
                        }
                        buttonWithAction("App bewerten", systemName: "star") {
                            //AppStore bewertung
                        }
                    }
                    
                    Section("Informationen") {
                        buttonWithAction("About us", systemName: "info") {
                            
                        }
                        buttonWithAction("API's", systemName: "globe") {
                            
                        }
                    }
                    Button {
                        
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .frame(width: 20, height: 20)
                                .padding(6)
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.red.opacity(0.1))
                                }
                            Text("Ausloggen")
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .padding(.top)
            .background {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettingsView = false
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
    
    @ViewBuilder
    private func toggleButton(systemImage: String, title: String, toggle: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundStyle(.gray)
                .padding(6)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.gray.opacity(0.2))
                }
            Text(title)
            Spacer()
            Toggle("", isOn: toggle)
        }
    }
    
    // @escaping wird hier gebraucht, weil beim closure oben wird direkt eine aktion verlangt, bei der funktion aber wird diese erst aufgerufen wenn der button gedrückt wird.
    @ViewBuilder
    private func buttonWithAction(_ title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: systemName)
                    .foregroundStyle(.gray)
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.gray.opacity(0.2))
                    }
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    IngredientView()
}
