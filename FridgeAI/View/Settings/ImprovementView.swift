//
//  ImprovementView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import SwiftUI

struct ImprovementView: View {
    
    @State private var titleEditor: String = ""
    @State private var improvementEditor: String = ""
    
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
                    TextEditor(text: $improvementEditor)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).stroke())
                        .padding(.bottom)
                } header: {
                    Text("Was können wir verbessern?")
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
            .navigationTitle("Verbesserungsvorschlag")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ImprovementView()
}
