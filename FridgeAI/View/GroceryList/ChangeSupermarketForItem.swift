//
//  ChangeSupermarketForItem.swift
//  FridgeAI
//
//  Created by Michael Ilic on 11.09.25.
//

import SwiftUI
import SwiftData

struct ChangeSupermarketForItem: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @StateObject var groceryVM = GroceryViewModel()
    @State private var selectedDetent: PresentationDetent = .fraction(0.35)
    
    @Binding var selectedSupermarkt: Supermarket
    let supermarkets: [Supermarket]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Supermarkt wählen")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                allSupermarkets()
                
                newSupermarketField()
                    
                editSupermarketsView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea()
        }
        .presentationDetents(
            [.fraction(0.35), .fraction(0.45), .fraction(0.55), .fraction(0.6), .fraction(0.7)],
            selection: $selectedDetent
        )
        .onAppear {
            selectedDetent = groceryVM.calculateDetent(supermarkets: supermarkets)
        }
        .onChange(of: groceryVM.isEditing || groceryVM.isAddingNew) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                selectedDetent = groceryVM.calculateDetent(supermarkets: supermarkets)
            }
        }
        .onChange(of: supermarkets.count) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                selectedDetent = groceryVM.calculateDetent(supermarkets: supermarkets)
            }
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
    
    @ViewBuilder
    private func allSupermarkets() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(supermarkets, id: \.id) { supermarket in
                SupermarketButton(
                    groceryVM: groceryVM,
                    supermarkt: supermarket,
                    isSelected: selectedSupermarkt.id == supermarket.id,
                    isMarkedForDeletion: groceryVM.supermarketsToDelete.contains(supermarket.id),
                    selectedSupermarkt: $selectedSupermarkt
                )
                .wobble(groceryVM.isEditing)
            }
            Button {
                withAnimation {
                    groceryVM.isAddingNew.toggle()
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
            .disabled(groceryVM.isEditing)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func newSupermarketField() -> some View {
        if groceryVM.isAddingNew {
            VStack(spacing: 16) {
                TextField("Supermarkt Name", text: $groceryVM.newSupermarketName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                ColorPicker("Farbe auswählen", selection: $groceryVM.newSupermarketColor)
                    .padding(.horizontal)
                
                HStack {
                    Button("Abbrechen") {
                        groceryVM.isAddingNew = false
                        groceryVM.newSupermarketName = ""
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Hinzufügen") {
                        groceryVM.addNewSupermarket(context: context)
                    }
                    .disabled(groceryVM.newSupermarketName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(groceryVM.newSupermarketName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
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
    }
    
    @ViewBuilder
    private func editSupermarketsView() -> some View {
        if groceryVM.isEditing {
            HStack {
                Spacer()
                Button("Abbrechen") {
                    groceryVM.isEditing = false
                    groceryVM.supermarketsToDelete.removeAll()
                }
                Spacer()
                
                Button("Markierte löschen", role: .destructive) {
                    groceryVM.deleteSupermarkets(supermarkets: supermarkets, selectedSupermarket: &selectedSupermarkt, context: context)
                }
                Spacer()
            }
            .buttonStyle(ModernButtonStyle())
            .padding(.bottom)
        }
    }
}

#Preview {
    ChangeSupermarketForItem(selectedSupermarkt: .constant(Supermarket(name: "Billa", color: .yellow)), supermarkets: [Supermarket(name: "Billa", color: .yellow), Supermarket(name: "Spar", color: .green), Supermarket(name: "Hofer", color: .orange)])
}
