//
//  RecipeViewModel.swift
//  FridgeAI
//
//  Created by Michael Ilic on 15.04.25.
//


/*
 https://api.spoonacular.com/recipes/findByIngredients?ingredients=Tomate&number=5&apiKey=c19d4c45bb38487fb4faebbffe4b7246&includeNutrition=true - das ist der urlString der mit Tomate als Ingredient verwendet wird.
 https://api.spoonacular.com/recipes/645555/information?&apiKey=c19d4c45bb38487fb4faebbffe4b7246&includeNutrition=false - das ist der urlString wo die Anleitung enthalten ist, mit der ID vom urlString davor.
 
 Irgendwie müssen wir aus dem ersten urlString die ID kopieren und in den zweiten einsetzen und das dann in die View einbauen
 Oder wir nehmen nur die ID und setzen diese in den zweiten Link ein und nehmen generell nur den zweiten link da dieser auch viel mehr daten enthält
 */


import Foundation
import SwiftUI

class RecipeViewModel: ObservableObject {
    
    let APIKey = "c19d4c45bb38487fb4faebbffe4b7246"
    let translateAPI = "a33084c3-f34a-4f0c-8962-8092d501e473:fx"
    
    @Published var firstAPIResponses: [FirstAPIResponse] = []
    
    @Published var recipes: [Recipe] = []
    @Published var ingredients: [Ingredient] = []
    @Published var newIngredientName = ""
    @Published var newIngredientAmount: Int = 1
    @Published var isLoading = false
    
    func addIngredient() {
        guard !newIngredientName.isEmpty else { return }
        let ingredient = Ingredient(name: newIngredientName, amount: newIngredientAmount)
        ingredients.append(ingredient)
        newIngredientName = ""
        newIngredientAmount = 1
    }
    
    func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    //Hier wird zuerst die ID vom ersten Link genommen
    func firstAPICall(completion: @escaping ([FirstAPIResponse]?) -> Void) {
        let ingredientList = ingredients.map { $0.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.name }.joined(separator: ",")
        
        guard let url = URL(string: "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientList)&number=5&apiKey=\(APIKey)&includeNutrition=true") else {
            completion(nil)
            print("Invalid First URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                print("Error getting first data")
                return
            }
            
            do {
                let response = try JSONDecoder().decode([FirstAPIResponse].self, from: data)
                
                DispatchQueue.main.async {
                    self.firstAPIResponses = response
                }
                
                completion(response)
            } catch {
                print("Error im Decoden von der ID: \(error)")
                print(url)
                completion(nil)
            }
        }
        .resume()
    }
    
    // Hier wird ein normaler API Call durchgeführt, die ID vom ersten wird beim Button eingesetzt
    func fetchRecipesInformation(id: Int) {
        isLoading = true
        
//        let urlString = "https://api.spoonacular.com/recipes/716429/information?apiKey=\(APIKey)&includeNutrition=true"
//        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientList)&number=5&apiKey=\(APIKey)&includeNutrition=true"
        let urlString = "https://api.spoonacular.com/recipes/\(id)/information?&apiKey=\(APIKey)&includeNutrition=true"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            print("Invalid second URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }
            
            if let error = error {
                print("Netzwerkfehler: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Keine Daten enthalten")
                return
            }
            
            do {
                let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                
                if let firstReponse = self.firstAPIResponses.first(where: {$0.id == id}) {
                    recipe.missedIngredients = firstReponse.missedIngredients
                    recipe.usedIngredients = firstReponse.usedIngredients
                }
                
                DispatchQueue.main.async {
                    self.recipes = [recipe]
                    print(recipe.title)
                }
                print(urlString)
            } catch {
                print("Fehler beim dekodieren. \(error)")
            }
        }
        .resume()
        
    }
    
    
    
    func updateIngredientAmount(for ingredientID: UUID, newAmount: Int) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredientID }) {
            guard newAmount >= 1 else {return}
            ingredients[index].amount = newAmount
            objectWillChange.send()
        }
    }
}
