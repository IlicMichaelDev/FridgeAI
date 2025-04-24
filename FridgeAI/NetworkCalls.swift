//
//  NetworkCalls.swift
//  FridgeAI
//
//  Created by Michael Ilic on 24.04.25.
//

import Foundation
import SwiftUI

class NetworkCalls: ObservableObject {
    let APIKey = "c19d4c45bb38487fb4faebbffe4b7246"
    
    @Published var firstAPIResponses: [FirstAPIResponse] = []
    
    @Published var recipes: [Recipe] = []
    @Published var ingredients: [Ingredient] = []
    @Published var newIngredientName = ""
    @Published var newIngredientAmount: Int = 1
    @Published var isLoading = false
    
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

}

