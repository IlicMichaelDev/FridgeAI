//
//  ProfileDetal.swift
//  FridgeAI
//
//  Created by Michael Ilic on 30.04.25.
//

import SwiftUI

//struct ProfileDetail: View {
//
//    @EnvironmentObject var authVM: AuthViewModel
//
//    var body: some View {
//
//        if let user = authVM.currentUser {
//            NavigationStack {
//                VStack(alignment: .leading) {
//                    HStack(spacing: 10) {
//                        Circle()
//                            .frame(width: 70, height: 70)
//
//                        Button {
//
//                        } label: {
//                            Text("Ändern")
//                                .bold()
//                                .padding()
//                                .background {
//                                    Capsule()
//                                        .foregroundStyle(.gray.opacity(0.2))
//                                }
//                        }
//
//                        Button {
//
//                        } label: {
//                            Text("Löschen")
//                                .bold()
//                                .foregroundStyle(.red)
//                                .padding()
//                                .background {
//                                    Capsule()
//                                        .foregroundStyle(.red.opacity(0.1))
//                                }
//                        }
//                    }
//                    .padding()
//
//                    List {
//                        Section("Name") {
////                            Text("Michael Ilic")
//                            Text(user.name)
//                        }
//
//                        Section("E-Mail") {
////                            Text("michi.ilic@gmail.com")
//                            Text(user.email)
//                        }
//
//                        Section("Passwort") {
//                            Text("********")
//                        }
//
//                        Section("Andere") {
//                            Button {
//                                authVM.deleteAccount()
//                                authVM.signOut()
//                            } label: {
//                                Text("Benutzer löschen")
//                                    .foregroundStyle(.red)
//                            }
//                        }
//                    }
//                }
//                .background {
//                    Color(UIColor.systemGroupedBackground)
//                        .ignoresSafeArea()
//                }
//
//                .navigationTitle("Profil bearbeiten")
//                .navigationBarTitleDisplayMode(.inline)
//            }
//        }
//    }
//}

struct ProfileDetail: View {
    
    @State private var showChangeSheet = false
    
    var body: some View {
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
                        Text("Michael Ilic")
                    }
                    
                    Section("E-Mail") {
                        Text("michi.ilic@gmail.com")
                    }
                    
                    Section("Passwort") {
                        Text("********")
                    }
                    
                    Section("Andere") {
                        Button {
//                            authVM.deleteAccount()
//                            authVM.signOut()
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

#Preview {
    ProfileDetail()
}
