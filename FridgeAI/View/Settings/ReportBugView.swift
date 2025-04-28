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
            VStack(alignment: .leading) {
                Section {
                    TextEditor(text: $titleEditor)
                        .frame(height: 40)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).stroke())
                        .padding(.bottom)
                } header: {
                    Text("Titel")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    TextEditor(text: $descriptionEditor)
                        .frame(height: 80)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).stroke())
                        .padding(.bottom)
                } header: {
                    Text("Was funktioniert nicht?")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    TextEditor(text: $reproduceErrorEditor)
                        .frame(height: 120)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).stroke())
                } header: {
                    Text("Wie kann der Bug reproduziert werden?")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Button {
                    
                } label: {
                    Text("Senden")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                        }
                        .padding(.vertical)
                }
            }
            .padding()
            .navigationTitle("Bug melden")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ReportBugView()
}
