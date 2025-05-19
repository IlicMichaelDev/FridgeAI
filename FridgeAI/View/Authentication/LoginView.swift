//
//  Login.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    @State var email = ""
    @State var password = ""
    
    @State private var showForgotPassword = false
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // Image von der App
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 150)
                
                VStack(spacing: 24) {
                    InputView(text: $email, title: "Email Adresse", placeholder: "name@gmail.com")
                        .autocapitalization(.none)
                    
                    InputView(text: $password, title: "Passwort", placeholder: "Gib dein Passwort ein", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                HStack {
                    Spacer()
                    Button {
                        showForgotPassword = true
                    } label: {
                        Text("Passwort vergessen?")
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                
                Button {
                    Task {
                        try await authVM.signIn(with: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("ANMELDEN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                        if authVM.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack() {
                        Text("Noch keinen Account?")
                        Text("Jetzt registrieren")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(showForgotPassword: $showForgotPassword)
                .presentationDetents([.fraction(0.3)])
        }
        .alert("Fehler beim LogIn", isPresented: $authVM.errorLogin) { } message: {
            Text("Bitte überprüfe deine Eingaben.")
        }

    }
}

struct InputView: View {
    
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
            Divider()
        }
    }
}

struct ForgotPasswordView: View {
    
    @State private var email = ""
    @State private var mailSend = false
    @Binding var showForgotPassword: Bool
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                InputView(text: $email, title: "Email Adresse", placeholder: "name@gmail.com")
                    .autocapitalization(.none)
                
                Button {
                    mailSend = true
                    Auth.auth().sendPasswordReset(withEmail: email)
                } label: {
                    HStack {
                        Text("MAIL SENDEN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(email.isEmpty)
                .opacity(email.isEmpty ? 0.5 : 1.0)
                .cornerRadius(10)
                .padding(.top, 24)
            }
            .padding()
            .navigationTitle("Passwort vergessen")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Test", isPresented: $mailSend) {
            Button("Ok") {
                showForgotPassword = false
            }
        } message: {
            Text("Wir haben dir soeben eine Mail mit einem Link zum zurücksetzen deines Passwortes gesendet.")
        }
    }
}

#Preview {
    LoginView()
}
