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
            ChangeSupermarketForItem(selectedSupermarkt: $item.supermarket, supermarkets: supermarkets)
        }
    }
}

struct SupermarketButton: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var groceryVM: GroceryViewModel
    
    let supermarkt: Supermarket
    let isSelected: Bool
    let isMarkedForDeletion: Bool
    
    @Binding var selectedSupermarkt: Supermarket
    
    var body: some View {
        VStack(spacing: 8) {
            if groceryVM.isEditing {
                Image(systemName: groceryVM.supermarketsToDelete.contains(supermarkt.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(groceryVM.supermarketsToDelete.contains(supermarkt.id) ? .red : .gray)
                    .font(.system(size: 20))
            }
            
            Circle()
                .fill(supermarkt.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(selectedSupermarkt.id == supermarkt.id ? Color.white : Color.clear, lineWidth: 3)
                )
                .overlay(
                    groceryVM.supermarketsToDelete.contains(supermarkt.id) ?
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold)) :
                    nil
                )
            
            Text(supermarkt.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(selectedSupermarkt.id == supermarkt.id ? supermarkt.color.opacity(0.2) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedSupermarkt.id == supermarkt.id ? supermarkt.color : Color.clear, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
        .opacity(groceryVM.supermarketsToDelete.contains(supermarkt.id) ? 0.6 : 1.0)
        .onTapGesture {
            if groceryVM.isEditing {
                if groceryVM.supermarketsToDelete.contains(supermarkt.id) {
                    groceryVM.supermarketsToDelete.remove(supermarkt.id)
                } else {
                    groceryVM.supermarketsToDelete.insert(supermarkt.id)
                }
            } else {
                selectedSupermarkt = supermarkt
                dismiss()
            }
        }
        .onLongPressGesture {
            groceryVM.isAddingNew = false
            groceryVM.isEditing = true
            groceryVM.supermarketsToDelete.insert(supermarkt.id)
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

#Preview {
    GroceryItemRowView(item: GroceryItem(name: "Apfel", supermarket: Supermarket(name: "Billa", color: .yellow), einheit: .portion, anzahl: 1), supermarkets: [Supermarket(name: "Billa", color: .green)])
}
