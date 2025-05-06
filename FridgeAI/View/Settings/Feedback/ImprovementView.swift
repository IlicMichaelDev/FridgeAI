//
//  ImprovementView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import SwiftUI
import MessageUI

struct ImprovementView: View {
    
    @State private var titleEditor: String = ""
    @State private var improvementEditor: String = ""
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                InputImprovementField(title: "Titel", text: $titleEditor)
                InputImprovementField(title: "Was können wir verbessern?", height: 300, text: $improvementEditor)
                
                Button {
                    sendEmail(subject: titleEditor, body: improvementEditor)
                    
                    titleEditor = ""
                    improvementEditor = ""
                } label: {
                    Text("Vorschlag senden")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((titleEditor.isEmpty || improvementEditor.isEmpty) ? Color.gray : Color.blue)
                        .cornerRadius(14)
                        .shadow(color: (titleEditor.isEmpty || improvementEditor.isEmpty) ? .gray.opacity(0.3) : .blue.opacity(0.3), radius: 6, x: 0, y: 2)
                }
                .disabled(titleEditor.isEmpty || improvementEditor.isEmpty)
            }
            .padding()
            .navigationTitle("Verbesserungsvorschlag")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendEmail(subject: String, body: String) {
        
        // Mehrzeiliger String damit die Formatierung der Mail passt
        let formattedBody = """
        Was können wir verbessern?
        \(body)
        """
        
        // URLs dürfen keine Sonderzeichen, Abstände usw... haben, daher muss es durchs encoding ersetzt werden
        // Z.B. Es gibt für jedes Sonderzeichen eine bestimmte % codierung (Leerzeichen = %20,...) diese Prozent werden dann durch das richtige Zeichen ersetzt
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = formattedBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:michi.ilic@hotmail.com?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        
        guard let url = URL(string: urlString) else { return }
        
        // Je nachdem ob es auf dem iPhone oder Mac verwendet wird, wird die Mail App geöffnet. Da ich es nur auf iOS verwende, könnte ich auch alles weglöschen bis auf den UIApplication Befehl - für Lernzwecke lasse ich es aber bestehen.
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}

struct InputImprovementField: View {
    let title: String
    var height: CGFloat = 50
    
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .padding(8)
                    .frame(height: height)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
        }
    }
}

#Preview {
    ImprovementView()
}
