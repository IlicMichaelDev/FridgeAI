//
//  BiometricAuthentification.swift
//  FridgeAI
//
//  Created by Michael Ilic on 30.04.25.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case face
    case touch
    
    var getText: String {
        switch self {
        case .face: return "FaceID"
        case .touch: return "TouchID"
        }
    }
}

@Observable
class BiometricAuthentification {
    
    var isAuthorized = false
    var failed = false
    
    private let authenticationContext = LAContext()
    
    // Macht den Login
    func biometricLogin() {
        // Zuerst prüfen ob wir eine Biometrische Authentifizierung zur Verfügung haben
        guard let biometricType = getBiometricType() else {
            failed = true
            return
        }
        let reason = "\(biometricType.getText) Authentification"
        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { isAuthorized, error in
            self.isAuthorized = isAuthorized
            // Wenn error ungleich nil ist -> Fehler -> somit ist failed = true
            self.failed = error != nil
        }
    }
    
    
    // Prüft welche Authentifizierung wir überhaupt zur Verfügung haben
    func getBiometricType() -> BiometricType? {
        // Zuerst wird überprüft ob wir überhaupt Zugriff auf die Authentifizierung haben
        guard canEvaluatePolicy() else { return nil }
        
        switch authenticationContext.biometryType {
        case .faceID: return .face
        case .touchID: return .touch
        default: return nil
        }
    }
    
    
    // Hier wird geprüft ob das Gerät überhaupt über eine Möglichkeit zur Authentifizierung verfügt
    private func canEvaluatePolicy() -> Bool {
        // NSError ist auf Objective-C - Es gibt Fehlercodes, zB. -6 "Biometrie nicht verfügbar"
        var error: NSError?
        let canEvaluate = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            print(error)
        }
        return canEvaluate
    }
    
}
