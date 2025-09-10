//
//  AddIngredientView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 19.08.25.
//

import SwiftUI
import SwiftData

struct AddIngredientView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @State private var name: String = "Apfel"
    @State private var amount: Int = 1
    @State private var selectedCategory: IngredientCategory = .beverages
    @State private var expiryDate = Date()
    @State private var isOrganic = false
    @State private var origin: String = "Deutschland"
    @State private var notes: String = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Grundinformationen")) {
                    HStack {
                        if let image = inputImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                        } else {
                            Image(systemName: selectedCategory.iconName)
                                .font(.system(size: 25))
                                .foregroundStyle(selectedCategory.iconColor)
                                .frame(width: 60, height: 60)
                                .background(selectedCategory.backgroundColor)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                        }
                        
                        TextField("Zutatname", text: $name)
                            .font(.headline)
                    }
                    
                    Picker("Kategorie", selection: $selectedCategory) {
                        ForEach(IngredientCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Stepper(value: $amount, in: 1...100) {
                        HStack {
                            Text("Menge")
                            Spacer()
                            Text("\(amount)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Details")) {
                    DatePicker("Haltbar bis", selection: $expiryDate, displayedComponents: .date)
                    
                    Toggle("Bio", isOn: $isOrganic)
                    
                    TextField("Herkunft", text: $origin)
                    
                    TextField("Notizen", text: $notes)
                }
            }
            .navigationTitle("Zutat hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        addIngredient()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
//                ImagePicker(image: $inputImage)
            }
        }
    }
    
    private func addIngredient() {
        let newIngredient = Ingredient(
            name: name,
            amount: amount,
            category: selectedCategory,
            imageData: nil
        )
        context.insert(newIngredient)
    }
}

#Preview {
    AddIngredientView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
