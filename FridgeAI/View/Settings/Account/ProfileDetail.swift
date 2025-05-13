//
//  ProfileDetal.swift
//  FridgeAI
//
//  Created by Michael Ilic on 30.04.25.
//

import SwiftUI

struct ProfileDetail: View {

    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showChangeSheet = false

    var body: some View {

        if let user = authVM.currentUser {
            NavigationStack {
                VStack(alignment: .center, spacing: 10) {
                    Circle()
                        .frame(width: 90, height: 90)
                    
                    Button {
                        showChangeSheet = true
                    } label: {
                        Text("Bearbeiten")
                            .font(.subheadline)
                    }

                    List {
                        Section("Name") {
                            Text(user.name)
                        }

                        Section("E-Mail") {
                            Text(user.email)
                        }

                        Section("Passwort") {
                            Text("********")
                        }

                        Section("Andere") {
                            Button {
                                authVM.deleteAccount()
                                authVM.signOut()
                            } label: {
                                Text("Benutzer löschen")
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
            .sheet(isPresented: $showChangeSheet) {
                ChangeProfileDetail()
                    .presentationDetents([.fraction(0.4)])
            }
        }
    }
}

struct ChangeProfileDetail: View {
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        Button {
 
                        } label: {
                            HStack {
                                Text("Foto aufnehmen")
                                Spacer()
                                Image(systemName: "camera")
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Bild auswählen")
                                Spacer()
                                Image(systemName: "star")
                            }
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            
                        } label: {
                            HStack {
                                Text("Bild löschen")
                                Spacer()
                                Image(systemName: "trash")
                            }
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

//#Preview {
//    @Previewable @StateObject var authVM: AuthViewModel = AuthViewModel()
//    
//    ProfileDetail()
//        .environmentObject(authVM)
//}
