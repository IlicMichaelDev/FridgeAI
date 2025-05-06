//
//  SwiftUIView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import SwiftUI

struct AboutMeView: View {
    
    //    var body: some View {
    //        ScrollView {
    //        VStack(alignment: .leading, spacing: 20) {
    //            Text("Über uns")
    //                .font(.largeTitle)
    //                .fontWeight(.bold)
    //
    //            Text("""
    //Mein Name ist Ing.  Michael Ilic, ein leidenschaftlicher Entwickler aus Österreich. Mit 25 Jahren habe ich diese App als persönliches Projekt entwickelt, um meine Fähigkeiten im Bereich Mobile Development weiter auszubauen.
    //
    //Mit dieser App kannst du die Zutaten, die du zuhause hast, eingeben und erhältst daraufhin passende Rezeptvorschläge – basierend auf Echtzeit-Daten von externen APIs.
    //
    //Die App wurde vollständig in Swift und SwiftUI entwickelt. Sie nutzt Firebase für die Authentifizierung sowie verschiedene APIs für die Rezeptvorschläge. Ich habe das Projekt eigenständig umgesetzt, basierend auf meinem Wissen aus Selbststudium und meiner Erfahrung im IT-Support.
    //
    //Mein Ziel ist es, mich ständig weiterzuentwickeln und meine Leidenschaft für Softwareentwicklung in spannende Projekte einzubringen.
    //
    //Feedback ist jederzeit willkommen! Über den Button unten kannst du Fehler melden oder Verbesserungsvorschläge einsenden.
    //""")
    //                .font(.body)
    //                .multilineTextAlignment(.leading)
    //
    //            Button(action: {
    //                // Hier kommt deine Logik für Bug-Report oder Feedback rein
    //                print("Feedback-Button geklickt")
    //            }) {
    //                Text("Feedback senden")
    //                    .font(.headline)
    //                    .foregroundColor(.white)
    //                    .padding()
    //                    .frame(maxWidth: .infinity)
    //                    .background(Color.blue)
    //                    .cornerRadius(12)
    //            }
    //            .padding(.top, 20)
    //        }
    //        .padding()
    //    }
    //    }
    
    @State private var showContent = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Über uns")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6), value: showContent)
                
                VStack(alignment: .leading, spacing: 16) {
                    AboutUsCard(
                        iconName: "person.crop.circle",
                        title: "Wer ich bin",
                        description: "Hallo, ich bin Michael Ilic, ein leidenschaftlicher Entwickler aus Österreich. Mit 25 Jahren habe ich diese App als persönliches Projekt entwickelt, um meine Fähigkeiten im Bereich Mobile Development auszubauen."
                    )
                    
                    AboutUsCard(
                        iconName: "cart.fill",
                        title: "Was die App macht",
                        description: "Mit dieser App kannst du die Zutaten, die du zuhause hast, eingeben und erhältst passende Rezeptvorschläge – basierend auf Echtzeit-Daten von externen APIs."
                    )
                    
                    AboutUsCard(
                        iconName: "hammer.fill",
                        title: "Technologien",
                        description: "Die App wurde in Swift und SwiftUI entwickelt, nutzt Firebase für Authentifizierungen und verschiedene APIs für Rezeptvorschläge. Das gesamte Projekt habe ich alleine umgesetzt."
                    )
                    
                    AboutUsCard(
                        iconName: "lightbulb.fill",
                        title: "Meine Vision",
                        description: "Ich möchte meine Leidenschaft für Softwareentwicklung weiter vertiefen und in zukünftigen Projekten kreative Lösungen entwickeln."
                    )
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(0.2), value: showContent)
                
                Button(action: {
                    // Hier kannst du deine Feedback- oder Bug-Report-Logik einfügen
                    print("Feedback senden Button gedrückt")
                }) {
                    Text("Feedback senden")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(14)
                        .shadow(radius: 4)
                }
                .padding(.top, 30)
                .opacity(showContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.6).delay(0.4), value: showContent)
            }
            .padding()
        }
        .onAppear {
            showContent = true
        }
    }
}

struct AboutUsCard: View {
    var iconName: String
    var title: String
    var description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundColor(.blue)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    AboutMeView()
}
