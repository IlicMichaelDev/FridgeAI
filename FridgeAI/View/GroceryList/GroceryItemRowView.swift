//
//  GroceryItemRowView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 26.08.25.
//

// HIER FUNKTIONIERT NOCH NICHT DAS SPEICHERN NEUER SUPERMÄRKTE MITTELS SWIFTDATA

import SwiftUI
import SwiftData
 
struct GroceryItemRowView: View {
    
    @State private var showSheet: Bool = false
    @State private var showCategorySheet: Bool = false
    
    @ObservedObject var item: GroceryItem
    
    @Environment(\.modelContext) private var context
    
    let supermarkets: [Supermarket]
    
    var body: some View {
        VStack {
            HStack {
                Text("") //Ohne dem verschwindet der durchgehende Strich unter jedem Item
                
                Circle()
                    .fill(item.supermarket.color)
                    .frame(width: 15)
                    .onTapGesture {
                        showCategorySheet = true
                    }
                
                TextField("Neues Produkt hinzufügen", text: $item.name)
                    .strikethrough(item.isDone ? true : false)
                    .foregroundStyle(item.isDone ? .gray : .primary)
                
                Spacer()
                
                Button(action: { showSheet = true } ) {
                    Text("\(item.anzahl)\(item.einheit.kurz)")
                }
                
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundStyle(item.isDone ? .green : .primary)
                    .onTapGesture {
                        item.isDone.toggle()
                    }
            }
        }
        .sheet(isPresented: $showSheet) {
            ItemAnzahl(item: item)
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
            }
        .sheet(isPresented: $showCategorySheet) {
            ChangeSupermarktForItem(selectedSupermarkt: $item.supermarket, supermarkets: supermarkets)
        }
    }
}

struct ChangeSupermarktForItem: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Binding var selectedSupermarkt: Supermarket
    
    // Zustand für das Hinzufügen eines neuen Supermarkts
    @State private var newSupermarketName = ""
    @State private var newSupermarketColor = Color.blue
    @State private var isAddingNew = false
    @State private var isEditing = false
//    @State private var deleteSupermarketButton: Bool = false
    
    @State private var supermarketsToDelete: Set<UUID> = []
    
    let supermarkets: [Supermarket]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Supermarkt wählen")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, isAddingNew ? 0 : 10)
                
                HStack {
                    Spacer()
                    Button(isEditing ? "Fertig" : "Bearbeiten") {
                        withAnimation {
                            isEditing.toggle()
                            if !isEditing {
                                supermarketsToDelete.removeAll()
                            }
                        }
                    }
                    .padding(.trailing)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(supermarkets, id: \.id) { supermarkt in
                        
                        // Hier funktioniert die .onLongPressGesture funktion, da sie nicht vom Button "consumed" wird. Das bedeutet er wird sozusagen aufgefressen vom Button - noch schauen warum das so ist - im Notfall neue SubView erstellen
//                        ForEach(supermarkets, id: \.id) { supermarkt in
//                            VStack(spacing: 8) {
//                                if isEditing {
//                                    Image(systemName: supermarketsToDelete.contains(supermarkt.id) ? "checkmark.circle.fill" : "circle")
//                                        .foregroundColor(supermarketsToDelete.contains(supermarkt.id) ? .red : .gray)
//                                        .font(.system(size: 20))
//                                }
//                                
//                                Circle()
//                                    .fill(supermarkt.color)
//                                    .frame(width: 40, height: 40)
//                                    .overlay(
//                                        Circle()
//                                            .stroke(selectedSupermarkt.id == supermarkt.id ? Color.white : Color.clear, lineWidth: 3)
//                                    )
//                                    .overlay(
//                                        supermarketsToDelete.contains(supermarkt.id) ?
//                                        Image(systemName: "xmark")
//                                            .foregroundColor(.white)
//                                            .font(.system(size: 20, weight: .bold)) :
//                                        nil
//                                    )
//                                
//                                Text(supermarkt.name)
//                                    .font(.system(size: 12, weight: .medium))
//                                    .foregroundColor(.primary)
//                                    .multilineTextAlignment(.center)
//                                    .lineLimit(2)
//                            }
//                            .padding(10)
//                            .background(
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(selectedSupermarkt.id == supermarkt.id ? supermarkt.color.opacity(0.2) : Color(.systemBackground))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 16)
//                                            .stroke(selectedSupermarkt.id == supermarkt.id ? supermarkt.color : Color.clear, lineWidth: 2)
//                                    )
//                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
//                            )
//                            .opacity(supermarketsToDelete.contains(supermarkt.id) ? 0.6 : 1.0)
//                            .onTapGesture {
//                                if isEditing {
//                                    if supermarketsToDelete.contains(supermarkt.id) {
//                                        supermarketsToDelete.remove(supermarkt.id)
//                                    } else {
//                                        supermarketsToDelete.insert(supermarkt.id)
//                                    }
//                                } else {
//                                    selectedSupermarkt = supermarkt
//                                    dismiss()
//                                }
//                            }
//                            .onLongPressGesture {
//                                withAnimation {
//                                    isEditing = true
//                                    supermarketsToDelete.insert(supermarkt.id)
//                                }
//                            }
//                        }
                        
                        SupermarktButton(
                            supermarkt: supermarkt,
                            isSelected: selectedSupermarkt.id == supermarkt.id,
                            isEditing: isEditing,
                            isMarkedForDeletion: supermarketsToDelete.contains(supermarkt.id)
                        ) {
                            if isEditing {
                                if supermarketsToDelete.contains(supermarkt.id) {
                                    supermarketsToDelete.remove(supermarkt.id)
                                } else {
                                    supermarketsToDelete.insert(supermarkt.id)
                                }
                            } else {
                                selectedSupermarkt = supermarkt
                                dismiss()
                            }
                        }
                        .onLongPressGesture(minimumDuration: 1.0) {
                            withAnimation {
                                isEditing = true
                                supermarketsToDelete.insert(supermarkt.id)
                            }
                        }
                    }
                    
                    Button {
                        withAnimation {
                            isAddingNew.toggle()
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            
                            Text("Hinzufügen")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isEditing)
                }
                .padding(.horizontal)
                
                //Löschen-Button (nur im Bearbeitungsmodus sichtbar)
                if isEditing && !supermarketsToDelete.isEmpty {
                    Button("Markierte löschen", role: .destructive) {
                        deleteMarkedSupermarkets()
                    }
                    .buttonStyle(ModernButtonStyle())
                    .padding()
                }
                
                // Eingabebereich für neuen Supermarkt
                if isAddingNew {
                    VStack(spacing: 16) {
                        TextField("Supermarkt Name", text: $newSupermarketName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        ColorPicker("Farbe auswählen", selection: $newSupermarketColor)
                            .padding(.horizontal)
                        
                        HStack {
                            Button("Abbrechen") {
                                isAddingNew = false
                                newSupermarketName = ""
                            }
                            .foregroundColor(.red)
                            
                            Spacer()
                            
                            Button("Hinzufügen") {
                                addNewSupermarket()
                            }
                            .disabled(newSupermarketName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .foregroundColor(newSupermarketName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
//                HStack {
//                    Spacer()
//                    
//                    Button("Bearbeiten") {
//                        deleteSupermarketButton.toggle()
//                    }
//                    .buttonStyle(ModernButtonStyle())
//                    .padding(.bottom, 20)
//                    
//                    Spacer()
                    
                if isEditing {
                    HStack {
                        Button("Abbrechen") {
                            withAnimation {
                                isEditing = false
                                supermarketsToDelete.removeAll()
                            }
                        }
                        
                        Spacer()
                        
                        if !supermarketsToDelete.isEmpty {
                            Button("Löschen", role: .destructive) {
                                deleteMarkedSupermarkets()
                            }
                        }
                        
                        Spacer()
                        
                        Button("Fertig") {
                            withAnimation {
                                isEditing = false
                                supermarketsToDelete.removeAll()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .buttonStyle(ModernButtonStyle())
                } else {
                    Button("Fertig") {
                        dismiss()
                    }
                    .buttonStyle(ModernButtonStyle())
                    .padding(.bottom, 20)
                }
//
//                    Spacer()
//                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea()
        }
        .presentationDetents([supermarkets.count > 5 ? .fraction(isAddingNew ? 0.8 : 0.55) : .fraction(isAddingNew ? 0.7 : 0.4)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
    
    private func addNewSupermarket() {
        let newSupermarket = Supermarket(name: newSupermarketName, color: newSupermarketColor)
        Supermarket.standardSupermarkets.append(newSupermarket)
        context.insert(newSupermarket)
        newSupermarketName = ""
        isAddingNew = false
    }
    
    private func deleteMarkedSupermarkets() {
        for supermarketId in supermarketsToDelete {
            if let supermarket = supermarkets.first(where: { $0.id == supermarketId }) {
                // Prüfen, ob der zu löschende Supermarkt der aktuell ausgewählte ist
                if supermarket.id == selectedSupermarkt.id {
                    // Fallback auf den ersten verfügbaren Supermarkt
                    selectedSupermarkt = supermarkets.first(where: { $0.id != supermarketId }) ?? Supermarket(name: "Allgemein", color: .gray)
                }
                context.delete(supermarket)
            }
        }
        supermarketsToDelete.removeAll()
        isEditing = false
    }
}

// ModernButtonStyle bleibt gleich wie zuvor
struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SupermarktButton: View {
    let supermarkt: Supermarket
    let isSelected: Bool
    let isEditing: Bool
    let isMarkedForDeletion: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: action) {
                VStack(spacing: 8) {
                    if isEditing {
                        Image(systemName: isMarkedForDeletion ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isMarkedForDeletion ? .red : .gray)
                            .font(.system(size: 20))
                    }
                    
                    Circle()
                        .fill(supermarkt.color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? supermarkt.color : Color.clear, lineWidth: 3)
                        )
                        .overlay(
                            isMarkedForDeletion ? Image(systemName: "xmark")
                                .foregroundStyle(.white)
                                .font(.system(size: 20, weight: .bold))
                            : nil
                        )
//                        .overlay(
//                            Circle()
//                                .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
//                        )
//                        .shadow(color: supermarkt.color.opacity(0.3), radius: isSelected ? 5 : 2, x: 0, y: isSelected ? 3 : 1)
                    
                    Text("\(supermarkt.name)".capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                )
                .opacity(isMarkedForDeletion ? 0.6 : 1.0)
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct ItemAnzahl: View {
    
    @ObservedObject var item: GroceryItem
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Text("\(item.anzahl)")
                    Divider()
                        .frame(height: 20)
                    Text(item.einheit.asString)
                    Spacer()
                    Spacer()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.secondary.opacity(0.3))
                        .frame(maxHeight: 30)
                }
                HStack {
                    Picker("", selection: $item.anzahl) {
                        ForEach(0..<1001) { zahl in
                            Text("\(zahl)")
                                .foregroundStyle(.primary)
                        }
                    }
                    .pickerStyle(.inline)
                    
                    Picker("", selection: $item.einheit) {
                        ForEach(Einheit.allCases, id: \.self) { einh in
                            Text("\(einh)".capitalized)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GroceryItemRowView(item: GroceryItem(name: "Apfel", supermarket: Supermarket(name: "Billa", color: .yellow), einheit: .portion, anzahl: 1), supermarkets: [Supermarket(name: "Billa", color: .green)])
}
