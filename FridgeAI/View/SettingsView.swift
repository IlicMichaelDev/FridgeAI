//
//  SwiftUIView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 26.04.25.
//

import SwiftUI


struct SettingsView: View {
    
    @AppStorage("isDarkmode") private var isDarkmode = false
    @AppStorage("isNotificationOn") private var isNotificationOn = false
    @AppStorage("isFaceIDOn") private var isFaceIDOn = false
    @AppStorage("isPINCodeOn") private var isPINCodeOn = false
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showProfileDetail = false
    
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
                            showProfileDetail = true
                        }
                        buttonWithAction("Favoriten", systemName: "star") {
                            
                        }
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
        .sheet(isPresented: $showProfileDetail) {
            ProfileDetail()
                .presentationDetents([.fraction(0.8)])
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
}

struct ProfileDetail: View {
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Circle()
                        .frame(width: 70, height: 70)
                    
                    Button {
                        
                    } label: {
                        Text("Ändern")
                            .bold()
                            .padding()
                            .background {
                                Capsule()
                                    .foregroundStyle(.gray.opacity(0.2))
                            }
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Löschen")
                            .bold()
                            .foregroundStyle(.red)
                            .padding()
                            .background {
                                Capsule()
                                    .foregroundStyle(.red.opacity(0.1))
                            }
                    }
                }
                .padding()
                
                List {
                    Section("Name") {
                        Text("Michael Ilic")
                    }
                    
                    Section("E-Mail") {
                        Text("michi.ilic@hotmail.com")
                    }
                    
                    Section("Passwort") {
                        Text("********")
                    }
                    
                    Section("Andere") {
                        Button {
                            
                        } label: {
                            Text("Account löschen")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .background {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
            }
            
            .navigationTitle("Profil bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView(showSettingsView: .constant(true))
}
