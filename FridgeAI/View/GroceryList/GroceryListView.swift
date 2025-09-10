//
//  ShoppingListView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 26.08.25.
//

// BIS HIER LÖSCHEN

import SwiftUI
import SwiftData

struct GroceryListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var categoryIdWithoutItems: UUID?
    
    @State private var showAddCategoryView: Bool = false
    @State private var alertDeleteCategory: Bool = false
    @State private var isEditing: Bool = false
    @State private var selectedSupermarkt: Supermarket?
    
    @Query(sort: \GroceryCategory.createdAt, order: .forward) private var categories: [GroceryCategory]
    @Query private var supermarkets: [Supermarket]
    
    private var hasVisibleCategories: Bool {
// Hier wird erstmal kontrolliert ob selectedSupermarkt nicht nil ist - also ob ein Supermarkt ausgewählt ist
        if let selectedSupermarkt = selectedSupermarkt {
// Dann wird jede Kategorie durchsucht und es wird geschaut ob mindestens 1 Item existiert mit demselben Supermarkt wie ausgewählt -> true, ansonsten false
            return categories.contains { category in
                category.items.contains { $0.supermarket.name == selectedSupermarkt.name }
            }
        } else {
// Hier wird überprüft ob es überhaupt kategorien gibt - Wenn die Liste nicht leer ist -> true, ansonsten false
            return !categories.isEmpty
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    if categories.isEmpty {
                        ContentUnavailableView("Füge Artikel für deinen nächsten Einkauf hinzu!", systemImage: "cart")
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // "Alle" Filter-Button
                                FilterPill(
                                    title: "Alle",
                                    isSelected: selectedSupermarkt == nil,
                                    color: .cyan,
                                    isEditing: .constant(false)
                                ) {
                                    selectedSupermarkt = nil
                                }
                                
                                // Supermarkt-Filter
                                ForEach(supermarkets, id: \.name) { supermarkt in
//                                    let _ = print("\(supermarkt.name) - \(supermarkt.color)")
                                    FilterPill(
                                        title: supermarkt.name,
                                        isSelected: selectedSupermarkt?.name == supermarkt.name,
                                        color: supermarkt.color,
                                        isEditing: $isEditing
                                    ) {
                                        selectedSupermarkt = supermarkt
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .background(Color(.systemGray6))
                        .padding(.top)
                        
                        if hasVisibleCategories {
                            List {
                                ForEach(categories, id: \.id) { category in
                                    if shouldShowSection(for: category) {
                                        SectionRowView(categoryIdWithoutItems: $categoryIdWithoutItems, category: category, selectedSupermarkt: selectedSupermarkt, supermarkets: supermarkets)
                                    }
                                }
                            }
                            .listStyle(.sidebar)
                            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive).animation(.spring))
                            .onChange(of: categoryIdWithoutItems) { _, newVal in
                                if newVal != nil {
                                    alertDeleteCategory = true
                                }
                            }
                        } else {
                            ContentUnavailableView("Du musst heute nicht in diesen Supermarkt", systemImage: "face.smiling")
                        }
                    }
                }
                PlusButton()
            }
            .background(Color(.systemGray6))
            
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isEditing.toggle()
                    } label: {
                        HStack {
                            Image(systemName: isEditing ? "pencil" : "pencil")
                            Text(isEditing ? "Done" : "Edit")
                        }
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background {
                            Capsule()
                                .tint(Color.black.opacity(0.4))
                        }
                    }
                }
            }
            .navigationTitle("Einkaufsliste")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.green, for: .navigationBar)
            
            .sheet(isPresented: $showAddCategoryView) {
                AddCategoryView(selectedSupermarket: selectedSupermarkt, supermarkets: supermarkets)
                    .presentationDetents([.fraction(0.7), .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .alert("Kategorie löschen?", isPresented: $alertDeleteCategory) {
            Button("Delete", role: .destructive) {
                if let index = categories.firstIndex(where: { $0.id == categoryIdWithoutItems }) {
                    deleteCategory(at: IndexSet(integer: index))
                    categoryIdWithoutItems = nil
                }
                do {
                    try context.save()
                } catch {
                    print("Fehler beim löschen der Kategorie: \(error)")
                }
            }
        } message: {
            Text("Die Kategorie und alle dazugehörigen Einträge werden gelöscht.")
        }
    }
    
    private func deleteCategory(at offSets: IndexSet) {
        for index in offSets {
            let category = categories[index]
            context.delete(category)
        }
    }
    
    private func shouldShowSection(for category: GroceryCategory) -> Bool {
        if let selectedSupermarkt = selectedSupermarkt {
            return category.items.contains { $0.supermarket.name == selectedSupermarkt.name }
        } else {
            return true
        }
    }
    
    @ViewBuilder
    func dismissButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .imageScale(.small)
                .frame(width: 44, height: 44)
                .foregroundStyle(.white)
                .background {
                    Circle()
                        .frame(width: 30, height: 30)
                        .tint(Color.black.opacity(0.4))
                }
        }
    }
    
    @ViewBuilder
    private func PlusButton() -> some View {
            Button {
                showAddCategoryView = true
            } label: {
                Image(systemName: "plus")
                    .font(.title.weight(.semibold))
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4, x: 0, y: 4)
            }
        .padding()
    }
}

struct SectionRowView: View {
    
    @Environment(\.modelContext) private var context
    
    @State private var isExpanded: Bool = true
    @Binding var categoryIdWithoutItems: UUID?
    
    var category: GroceryCategory
    var selectedSupermarkt: Supermarket?
    
    let supermarkets: [Supermarket]
    
    var body: some View {
        Section(isExpanded: $isExpanded) {
            ForEach(category.items.filter { item in
                selectedSupermarkt == nil || item.supermarket.name == selectedSupermarkt?.name
            }, id: \.id) { item in
                GroceryItemRowView(item: item, supermarkets: supermarkets)
            }
            .onDelete { offSet in
                category.items.remove(atOffsets: offSet)
                if category.items.isEmpty {
                    categoryIdWithoutItems = category.id
                }
            }
            
            //Es soll der erste Supermarkt genommen werden, wenn keiner existiert dann soll ein neuer angelegt werden
            Button {
                let newItem = GroceryItem(name: "", supermarket: selectedSupermarkt ?? (supermarkets.first ?? Supermarket(name: "Billa", color: .yellow)), einheit: .portion, anzahl: 1, isDone: false)
                withAnimation {
                    //WICHTIG: Hier wird beides benötigt, da Swiftdata sonst nicht weiß zu welchem Model es inserten soll
                    category.items.append(newItem)
                    context.insert(newItem)
                }
            } label: {
                Label("Neuer Artikel", systemImage: "plus")
                    .foregroundStyle(.blue)
            }
        } header: {
            Text("\(category.name): \(category.items.filter{ selectedSupermarkt == nil || $0.supermarket.name == selectedSupermarkt?.name }.count)")
        }
    }
}

#Preview {
    ContentView()
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let color: Color
    @Binding var isEditing: Bool
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.15))
                }
                .overlay {
                    Capsule()
                        .stroke(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
                }
        }
        .buttonStyle(ScaleButtonStyle())
        .overlay(alignment: .topTrailing) {
            if isEditing {
                Button {
                    
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
                .offset(x: 6, y: -6)
            }
        }
    }
}

// Button-Style für sanfte Animation beim Tippen
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
