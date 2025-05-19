//
//  AuthViewModel.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// @MainActor ist Concurrency und sorgt dafür das alles auf dem MainThread läuft
// Concurrency sorgt dafür das viele Aufgaben gleichzeitig ablaufen können
@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    @Published var isLoading: Bool = false
    @Published var errorLogin = false
    @Published var errorMessage: String = ""
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    // async - Funktion kann lange brauchen bis eine Antwort kommt
    // throws - hier wichtig, weil auch die funktion fetchUser fehlschlagen kann. wenn throws wegfällt dann kann man einen fehler im catch ausgeben, man weiß aber nicht wo genau der fehler auftritt
    // await - warte bis die Funktion beendet ist, blockiere aber nicht die gesamte app
    func signIn(with email: String, password: String) async throws {
        isLoading = true
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            isLoading = false
        } catch {
            print("DEBUG: Failed to login: \(error.localizedDescription)")
//            handleError(error)
            isLoading = false
            errorLogin = true
        }
    }
    
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            // Benutzer in Firebase Auth erstellen
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Verifizierungsmail senden
            try await result.user.sendEmailVerification()
            print("Verifizierungsmail wurde an \(email) gesendet")
            
            // Benutzerdaten in Firestore speichern
            let user = User(id: result.user.uid, name: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodedUser)
            
            // Benutzerdaten lokal aktualisieren
            await fetchUser()
        } catch {
            print("Error creating User: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sig out: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        user.delete()
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    
//    private func handleError(_ error: Error) {
//        if let authError = error as? AuthErrorCode {
//            errorMessage = authError.code.errorMessage
//        } else {
//            errorMessage = "Unbekannter Fehler: \(error.localizedDescription)"
//        }
//    }
}
