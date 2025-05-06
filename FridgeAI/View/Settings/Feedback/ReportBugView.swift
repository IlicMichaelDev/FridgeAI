//
//  Feedback.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import SwiftUI

struct ReportBugView: View {
    @State private var titleEditor: String = ""
    @State private var descriptionEditor: String = ""
    @State private var reproduceErrorEditor: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    InputField(
                        title: "Titel",
                        text: $titleEditor
                    )

                    InputField(
                        title: "Was funktioniert nicht?",
                        height: 100,
                        text: $descriptionEditor
                    )

                    InputField(
                        title: "Wie kann man den Fehler nachstellen?",
                        height: 120,
                        text: $reproduceErrorEditor
                    )

                    Button {
                        sendEmail(subject: titleEditor, body: descriptionEditor, steps: reproduceErrorEditor)
                        
                        titleEditor = ""
                        descriptionEditor = ""
                        reproduceErrorEditor = ""
                    } label: {
                        Text("Bug senden")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((titleEditor.isEmpty || descriptionEditor.isEmpty || reproduceErrorEditor.isEmpty) ? Color.gray : Color.blue)
                            .cornerRadius(14)
                            .shadow(color: (titleEditor.isEmpty || descriptionEditor.isEmpty || reproduceErrorEditor.isEmpty) ? .gray.opacity(0.3) : .blue.opacity(0.3), radius: 6, x: 0, y: 2)
                    }
                    .disabled(titleEditor.isEmpty || descriptionEditor.isEmpty || reproduceErrorEditor.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Bug melden")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendEmail(subject: String, body: String, steps: String) {
        
        // Mehrzeiliger String damit die Formatierung der Mail passt
        let formattedBody = """
        Was funktioniert nicht?
        \(body)
        
        Wie kann man den Fehler nachstellen?
        \(steps)
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

struct InputField: View {
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
    ReportBugView()
}
