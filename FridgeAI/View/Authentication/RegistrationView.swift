//
//  RegistrationView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack {
            // Image von der App
            Image(systemName: "figure.walk")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 150)
            
            VStack(spacing: 24) {
                InputView(text: $email, title: "Email Adresse", placeholder: "name@gmail.com")
                    .autocapitalization(.none)
                InputView(text: $fullname, title: "Name", placeholder: "Vor- & Nachname")
                InputView(text: $password, title: "Passwort", placeholder: "Gib dein Passwort ein", isSecureField: true)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword, title: "Passwort bestätigen", placeholder: "Bestätige dein Passwort", isSecureField: true)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .bold()
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .bold()
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            Button {
                Task {
                    try await authVM.createUser(withEmail: email, password: password, fullname: fullname)
                }
            } label: {
                HStack {
                    Text("REGISTRIEREN")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
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
            
            Button {
                dismiss()
            } label: {
                HStack() {
                    Text("Du hast bereits einen Account?")
                    Text("Anmelden")
                        .fontWeight(.semibold)
                }
                .font(.system(size: 14))
            }
        }
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count >= 6 && !fullname.isEmpty && confirmPassword == password
    }
}

#Preview {
    RegistrationView()
}
