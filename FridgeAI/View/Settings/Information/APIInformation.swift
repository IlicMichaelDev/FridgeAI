//
//  APIInformation.swift
//  FridgeAI
//
//  Created by Michael Ilic on 30.04.25.
//

import SwiftUI

struct APIInformation: View {

    struct APIInfo: Identifiable {
        let id = UUID()
        let name: String
        let systemIcon: String
        let description: String
        let docURL: URL?
    }
    
    private let apis: [APIInfo] = [
        .init(
            name: "Spoonacular",
            systemIcon: "fork.knife",
            description: "Wird verwendet, um Rezepte basierend auf eingegebenen Zutaten zu suchen.",
            docURL: URL(string: "https://spoonacular.com/food-api")
        ),
        .init(
            name: "Firebase Auth",
            systemIcon: "lock.shield",
            description: "Authentifizierung der Nutzer (Login, Registrierung) mit Swift Package Manager integriert.",
            docURL: URL(string: "https://firebase.google.com/docs/auth")
        ),
        .init(
            name: "DeepL API",
            systemIcon: "text.bubble",
            description: "Verwendet zur automatischen Übersetzung von Texten - z.B. für die Zutaten & Rezepte.",
            docURL: URL(string: "https://www.deepl.com/de/docs-api/")
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
//                    Text("Verwendete APIs")
//                        .font(.largeTitle)
//                        .bold()
//                        .padding(.bottom, 8)
                    
                    ForEach(apis) { api in
                        APIInfoCard(api: api)
                    }
                }
                .padding()
            }
            .navigationTitle("Verwendete API's")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct APIInfoCard: View {
    let api: APIInformation.APIInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: api.systemIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())

                Text(api.name)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Text(api.description)
                .font(.body)
                .foregroundColor(.secondary)

            if let url = api.docURL {
                Link(destination: url) {
                    Label("Zur Dokumentation", systemImage: "link")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    APIInformation()
}
