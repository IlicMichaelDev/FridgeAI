//
//  SwiftUIView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 26.04.25.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("isDarkmode") private var isDarkmode = true
    @AppStorage("isNotificationOn") private var isNotificationOn = false
    @AppStorage("isFaceIDOn") private var isFaceIDOn = false
    @AppStorage("isPINCodeOn") private var isPINCodeOn = false
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    // Sheet Toggles
    @State private var showProfileDetail = false
    @State private var showImprovementView = false
    @State private var showBugView = false
    @State private var showAboutMeView = false
    @State private var showAPIInformation = false
    
    @State private var biometricAuthentification = BiometricAuthentification()
    @State private var showAuthFailed = false
    
    @Binding var showSettingsView: Bool
    
    var body: some View {
        if let user = authVM.currentUser {
            NavigationStack {
                VStack {
                    Circle()
                        .frame(width: 100, height: 100)
                    Text(user.name)
                        .font(.title2)
                        .bold()
                    Text(user.email)
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                    
                    List {
                        Section("Account") {
                            buttonWithAction("Profil", systemName: "person") {
                                if isFaceIDOn {
                                    biometricAuthentification.biometricLogin()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: biometricAuthentification.isAuthorized ? .now() : .now() + 0.5) {
                                        if biometricAuthentification.isAuthorized {
                                            showProfileDetail = true
                                        } else {
                                            showAuthFailed = true
                                        }
                                    }
                                } else {
                                    showProfileDetail = true
                                }
                            }
                            buttonWithAction("Passwort ändern", systemName: "lock") {
                                
                            }
//                            buttonWithAction("Favoriten", systemName: "star") {
//                                
//                            }
                        }
                        
                        Section("Generell") {
                            toggleButton(systemImage: "moon.stars", title: "Darkmode", toggle: $isDarkmode)
                                .onChange(of: isDarkmode) { _, newValue in
                                    setAppTheme(darkMode: newValue)
                                }
                        }
                        
                        Section("Sicherheit & Benachrichtigung") {
                            toggleButton(systemImage: "bell.badge", title: "Benachrichtigung", toggle: $isNotificationOn)
                            toggleButton(systemImage: "faceid", title: "Face ID", toggle: $isFaceIDOn)
                            toggleButton(systemImage: "circle.grid.3x3", title: "PIN Code", toggle: $isPINCodeOn)
                        }
                        
                        Section("Feedback") {
                            buttonWithAction("Verbesserungsvorschläge", systemName: "envelope") {
                                showImprovementView = true
                            }
                            buttonWithAction("Bug melden", systemName: "exclamationmark") {
                                showBugView = true
                            }
                            buttonWithAction("App bewerten", systemName: "star") {
                                //AppStore bewertung
                            }
                        }
                        
                        Section("Informationen") {
                            buttonWithAction("About me", systemName: "info") {
                                showAboutMeView = true
                            }
                            buttonWithAction("API's", systemName: "globe") {
                                showAPIInformation = true
                            }
                        }
                        Button {
                            authVM.signOut()
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
            .onAppear{
                print("User: \(user)")
            }
            .sheet(isPresented: $showProfileDetail) {
                ProfileDetail()
                    .presentationDetents([.fraction(0.8)])
            }
            .sheet(isPresented: $showImprovementView) {
                ImprovementView()
                    .presentationDetents([.fraction(0.7)])
            }
            .sheet(isPresented: $showBugView) {
                ReportBugView()
                    .presentationDetents([.fraction(0.8)])
            }
            .sheet(isPresented: $showAboutMeView) {
                AboutMeView()
                    .presentationDetents([.fraction(0.9)])
            }
            .sheet(isPresented: $showAPIInformation) {
                APIInformation()
                    .presentationDetents([.fraction(0.85)])
            }
            
            .alert("Authentifizierung fehlgeschlagen", isPresented: $showAuthFailed) {
                Button("OK", role: .cancel) { }
            }
        } else {
            Button("Zurück") {
                dismiss()
            }
            .onAppear {
                print("Kein user angemeldet")
            }
        }
    }
    
    private func setAppTheme(darkMode: Bool) {
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark: .light
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
    
    @ViewBuilder
    private func faceIDToggle(systemImage: String, title: String) -> some View {
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
            Toggle("", isOn: Binding(
                get: { isFaceIDOn },
                set: { newValue in
                    if newValue {
                        biometricAuthentification.biometricLogin()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if biometricAuthentification.isAuthorized {
                                isFaceIDOn = true
                            } else {
                                isFaceIDOn = false
                                showAuthFailed = true
                            }
                        }
                    } else {
                        isFaceIDOn = false
                    }
                }
            ))
            .labelsHidden()
        }
    }
}

#Preview {
    let mockAuthVM: AuthViewModel = {
        let vm = AuthViewModel()
        vm.currentUser = User(
            id: "preview-123",
            name: "Michael Ilic",
            email: "michi.ilic@hotmail.com"
        )
        return vm
    }()
     
    SettingsView(showSettingsView: .constant(true))
        .environmentObject(mockAuthVM)
}
