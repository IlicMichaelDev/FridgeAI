//
//  RecipeView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 15.04.25.
//

import SwiftUI

struct RecipeView: View {
    
//    @StateObject var networkManager = NetworkCalls()
    
    @State private var translatedText = "Übersetzung"
    @State private var recipeDoneAlert = false
    
    let translateAPI = "a33084c3-f34a-4f0c-8962-8092d501e473:fx"
    
    let recipe: Recipe
    
    let calories = "Calories"
    let fat = "Fat"
    let carbohydrates = "Carbohydrates"
    let protein = "Protein"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(recipe.title)
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } placeholder: {
                    Circle()
                        .foregroundStyle(.secondary)
                }
                .ignoresSafeArea()
                
                Group {
                    Text("Nährwerte:")
                        .font(.title2)
                        .bold()
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        ForEach(recipe.filteredNutritions()) { nutrient in
                            NutritionInfo(nutrient: nutrient)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        if let usedIngredients = recipe.usedIngredients, let missedIngredients = recipe.missedIngredients {
                            AvailableIngredients(title: "Vorhanden", systemName: "plus.circle", backgroundColor: Color.green, usedIngredients: usedIngredients)
                            UnavailableIngredients(title: "Fehlt", systemName: "minus.circle", backgroundColor: .red, missedIngredients: missedIngredients)
                        }
                    }
                    
                    Text("Kurzanleitung:")
                    VStack(alignment: .leading) {
//                        Text(translatedText)
                        Text(recipe.instructions)
                        Link("Hier klicken für die gesamte Anleitung", destination: URL(string: recipe.sourceUrl)!)
                    }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                        }
                }
                .padding(.horizontal)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    recipeDoneAlert = true
                } label: {
                    Image(systemName: "checkmark")
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.green)
                        .padding(5)
                        .background {
                            Circle()
                                .fill(.gray.opacity(0.2))
                        }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 25, height: 25)
                        .padding(5)
                        .background {
                            Circle()
                                .fill(.gray.opacity(0.2))
                        }
                }
            }
        }
        
//         Es funktioniert, damit ich aber nicht meine täglichen zeichen verschwende - Es muss auch noch der translatedText eingesetzt werden
        .onAppear{
            translateWithDeepL(text: recipe.instructions, apiKey: translateAPI) { germanText in
                translatedText = germanText
            }
        }
        .alert("Rezept gemacht?", isPresented: $recipeDoneAlert) {
            Button("Nein", role: .destructive) { }
            Button("Ja") {
                
            }
        } message: {
            Text("Wenn du das Rezept gemacht hast, entferne ich die verwendeten Rezepte aus der Liste. Bist du dir sicher?")
        }

    }
    
    func translateWithDeepL(
        text: String,
        apiKey: String,
        completion: @escaping (String) -> Void
    ) {
        let url = URL(string: "https://api-free.deepl.com/v2/translate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Parameter: Text + Zielsprache (DE)
        let body = "text=\(text)&target_lang=DE&auth_key=\(apiKey)"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let translations = json["translations"] as? [[String: String]],
                  let translatedText = translations.first?["text"] else {
                completion(text) // Fallback
                return
            }
            completion(translatedText)
        }.resume()
    }
}

struct NutritionInfo: View {
    
    let nutrient: Nutrient
    var gaugePercent: Double {
        nutrient.percentOfDailyNeeds / 100
    }
    var nutrientPerDay: Double {
        nutrient.amount / nutrient.percentOfDailyNeeds * 100
    }
    var gaugeColor: Color {
        if nutrient.name == "Calories" {
            return Color.blue
        } else if nutrient.name == "Protein" {
            return Color.red
        } else if nutrient.name == "Fat" {
            return Color.yellow
        }
        return .green
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .stroke()
            .frame(height: 50)
            .overlay {
                HStack(alignment: .center) {
                    Gauge(value: gaugePercent) { }
                    .scaleEffect(0.6)
                    .frame(width: 35)
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(gaugeColor)
                    
                    VStack(alignment: .leading) {
                        Text(nutrient.name)
                            .foregroundStyle(.secondary)
                            .italic()
                            .bold()
                        HStack {
                            Text("\(nutrient.amount, specifier: "%.0f")\(nutrient.unit)")
                                .font(.system(size: 14))
                            Text("/ \(nutrientPerDay, specifier: "%.0f")\(nutrient.unit)")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .italic()
                                .fontWeight(.light)
                        }
                    }
                    Spacer()
                }
                .padding(8)
            }
    }
}

struct AvailableIngredients: View {
    
    let title: String
    let systemName: String
    let backgroundColor: Color
    let usedIngredients: [UsedIngredients]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(systemName: systemName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .scaledToFill()
                    .foregroundStyle(backgroundColor)
                Text(title)
                    .font(.title2)
                    .bold()
            }
            
            ForEach(usedIngredients, id: \.id) { used in
                Divider()
                Text(used.name.capitalized)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(backgroundColor.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
    }
}

struct UnavailableIngredients: View {
    
    let title: String
    let systemName: String
    let backgroundColor: Color
    let missedIngredients: [MissedIngredients]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(systemName: systemName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .scaledToFill()
                    .foregroundStyle(backgroundColor)
                Text(title)
                    .font(.title2)
                    .bold()
            }
            
            ForEach(missedIngredients, id: \.id) { missed in
                Divider()
                Text(missed.name.capitalized)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(backgroundColor.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    RecipeView(recipe: Recipe(id: 645555, title: "Test", image: "https://img.spoonacular.com/recipes/645555-312x231.jpg",
        missedIngredients: [MissedIngredients(id: 10211111, name: "sumac powder"), MissedIngredients(id: 5, name: "sage and mint leaves")],
        usedIngredients: [UsedIngredients(id: 11527, name: "tomato")],
                              sourceUrl: "https://www.foodista.com/recipe/KWMJ8SPX/green-tomato-salad", vegetarian: true, vegan: true, veryHealthy: true,
            nutrition: Nutrition(nutrients: [Nutrient(name: "Calories", amount: 180.37, unit: "kcal", percentOfDailyNeeds: 9.02),
            Nutrient(name: "Protein", amount: 2.61, unit: "g", percentOfDailyNeeds: 5.22),
            Nutrient(name: "Fat", amount: 14.88, unit: "g", percentOfDailyNeeds: 22.89),
            Nutrient(name: "Carbohydrates", amount: 11.1, unit: "g", percentOfDailyNeeds: 3.67)],
                                 caloricBreakdown: CaloricBreakdown(percentProtein: 4.4, percentFat: 5.5, percentCarbs: 6.6)), instructions: "Slice the tomato into thin round discs. Roll the mint and sage leaves into a tight ball and then chop it up finely. Add to the olive oil and sumac to make a dressing. Drizzle over the tomato slices."))
}
