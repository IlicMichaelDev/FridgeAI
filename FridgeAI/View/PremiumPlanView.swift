//
//  PremiumPlanView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 01.07.25.
//

import SwiftUI

struct PremiumPlanView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: SubscriptionPlan = .monthly
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.4),
                             Color(red: 0.3, green: 0.1, blue: 0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        VStack(spacing: 8) {
                            Text("Upgrade zu Premium")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Schalte alle Funktionen frei und verbessere dein Erlebnis")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        SubscriptionCard(
                            plan: .monthly,
                            price: "4,99€",
                            period: "monatlich",
                            isSelected: selectedPlan == .monthly
                        ) {
                            selectedPlan = .monthly
                        }
                        
                        SubscriptionCard(
                            plan: .yearly,
                            price: "49,99€",
                            period: "jährlich",
                            isSelected: selectedPlan == .yearly,
                            savingsText: "17% billger als monatlich",
                            isBestValue: true
                        ) {
                            selectedPlan = .yearly
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        FeatureRow(icon: "sparkles", text: "Unbegrenzte Rezepte")
                        FeatureRow(icon: "qrcode", text: "Fortgeschrittener QR-Code Scanner")
                        FeatureRow(icon: "heart.fill", text: "")
                        FeatureRow(icon: "bell.badge.fill", text: "Ablaufdatum Benachrichtigung")
                        FeatureRow(icon: "basket.fill", text: "Automatisierte Einkaufsliste")
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: purchasePremium) {
                        Text("Continue - \(selectedPlan == .monthly ? "€4.99/month" : "€49.99/year")")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.body.weight(.semibold))
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private func purchasePremium() {
        print("Purchasing \(selectedPlan.rawValue) plan")
    }
}

struct SubscriptionCard: View {
    let plan: SubscriptionPlan
    let price: String
    let period: String
    let isSelected: Bool
    var savingsText: String?
    var isBestValue: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.rawValue)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                        
                        if let savings = savingsText {
                            Text(savings)
                                .font(.caption)
                                .foregroundColor(isSelected ? .white.opacity(0.9) : .green)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                    
                    if isBestValue {
                        Text("BESTES ANGEBOT")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(6)
                    }
                    
                    VStack(alignment: .trailing) {
                        Text(price)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : .primary)
                        
                        Text("/\(period)")
                            .font(.subheadline)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                    }
                }
            }
            .padding()
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .font(.system(size: 18))
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(.white)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.system(size: 14, weight: .bold))
        }
    }
}

enum SubscriptionPlan: String {
    case monthly = "Monatlich"
    case yearly = "Jährlich"
}

#Preview {
    PremiumPlanView()
}
