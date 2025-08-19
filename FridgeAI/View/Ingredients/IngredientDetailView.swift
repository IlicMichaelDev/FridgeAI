//
//  IngredientDetailView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 19.08.25.
//

import SwiftUI
import SwiftData

struct IngredientDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let ingredient: Ingredient
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Image(systemName: "\(ingredient.category.iconName)")
                    .font(.system(size: 50))
                    .foregroundColor(ingredient.category.iconColor)
                    .frame(width: 120, height: 120)
                    .background(ingredient.category.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.leading, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(ingredient.name)
                        .font(.title2.weight(.semibold))
                        .padding(.top, 8)
                    
                    HStack(spacing: 12) {
                        Text("Menge")
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Button {
                                guard ingredient.amount > 0 else { return }
                                ingredient.amount -= 1
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(ingredient.amount > 0 ? .red : .gray)
                            }
                            
                            Text("\(ingredient.amount)")
                                .font(.body.monospaced())
                                .frame(minWidth: 24)
                            
                            Button {
                                ingredient.amount += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.top, 4)
                    
                    Text(ingredient.category.rawValue.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundColor(ingredient.category.iconColor)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Capsule().fill(ingredient.category.backgroundColor))
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(.leading)
            }
            .padding(.leading, 10)
            .padding(.top, 26)
            
            Divider()
                .padding(.vertical, 8)
            
            VStack(spacing: 12) {
                InfoRow(icon: "calendar", title: "Haltbar bis", value: "12.06.2024")
                InfoRow(icon: "leaf.fill", title: "Bio", value: "Ja")
                InfoRow(icon: "location.fill", title: "Herkunft", value: "Deutschland")
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    IngredientDetailView(ingredient: Ingredient(name: "Test", amount: 2, category: .beverages, imageData: nil))
}
