//
//  Extensions.swift
//  FridgeAI
//
//  Created by Michael Ilic on 23.04.25.
//

import Foundation
import SwiftUI
import FirebaseAuth

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

extension Recipe {
    func filteredNutritions() -> [Nutrient] {
        return nutrition.nutrients.filter { nutrient in
            let relevantNutrients = ["Calories", "Protein", "Fat", "Carbohydrates"]
            return relevantNutrients.contains(nutrient.name)
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count >= 6
    }
}


//extension AuthErrorCode {
//    var errorMessage: String {
//        switch self {
//        case .wrongPassword: return "Das Passwort ist falsch"
//        case .userDisabled: return "Der Benutzer ist deaktiviert"
//        case .invalidEmail: return "Ungültige E-Mail Adresse"
//        default: return "Unbekannter Fehler - Bitte versuche es später erneut"
//        }
//    }
//}
