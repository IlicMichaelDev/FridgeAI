//
//  PremiumPlanView.swift
//  FridgeAI
//
//  Created by Michael Ilic on 01.07.25.
//

import SwiftUI

struct PremiumPlanView: View {
    
    @State private var testView: Bool  = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
                VStack {
                    Text("Premium Pläne")
                        .font(.system(size: 24, weight: .bold, design: .default))
                    
                    ScrollView(.horizontal) {
                        HStack {
                            PremiumCard(image: "crown.fill", version: "Pro", gradientColors: [Color.blue, Color.cyan], preis: "3")
                            PremiumCard(image: "diamond.fill", version: "Premium", gradientColors: [Color.pink, Color.purple], preis: "5")
                        }
                    }
                    .padding(.horizontal)
                    
                    Button("Show Test View") {
                        testView = true
                    }
                }
            .fullScreenCover(isPresented: $testView) {
                TestPremiumView()
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.gray)
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background {
                                Circle()
                                    .fill(.gray.opacity(0.2))
                            }
                    }
                }
            }
        }
    }
}

struct TestPremiumView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                Color.red.opacity(0.3).ignoresSafeArea()
                VStack(spacing: 20) {
                // Image von irgendwas
                Spacer()
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 150)
                
                HStack {
                    Text("Get")
                    Text("PRO")
                        .padding(.horizontal, 7)
                        .bold()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(colors: [Color.lightBlue, Color.purple], startPoint: .leading, endPoint: .trailing))
                        }
                    Text("Version")
                }
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 45)
                    .fill(.white)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .bottom)
                    .frame(height: 400)
                    .overlay {
                        VStack {
//                            subscriptionButton()
//                                .padding(.top)
//                            subscriptionButton()
                            ForEach(0..<3) { _ in
                                SubscriptionButton()
                            }
                            .padding(.top)
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Text("Continue")
                                    .foregroundStyle(.white)
                                    .padding(.vertical)
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(LinearGradient(colors: [Color.lightBlue, Color.purple], startPoint: .leading, endPoint: .trailing))
                                    }
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .background(Color.red.ignoresSafeArea())
    }
}

struct SubscriptionButton: View {
    
    @State private var isSelected = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(isSelected ? .white : .red)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .overlay {
                HStack {
                    Text("Monatlich")
                    Spacer()
                    Text("10€ / Monat")
                }
                .padding(30)
            }
            .padding(.bottom, 15)
            .onTapGesture {
                isSelected.toggle()
            }
    }
}

struct PremiumCard: View {
    
    let image: String
    let version: String
    let gradientColors: [Color]
    let preis: String
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 250, height: 500)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: image)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(Color.gray.opacity(0.8))
                        }
                    
                    Text(version)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                }
                .padding(.top)
                
                VorteilRow(vorteil: "3 Rezepte pro Tag")
                    .padding(.top)
                VorteilRow(vorteil: "QR-Code Scanner")
                VorteilRow(vorteil: "Test")
                
            }
            
            Button {
                
            } label: {
                Text("\(preis)€ pro Monat")
                    .foregroundStyle(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing))
                    .padding()
                    .font(.system(size: 18))
                    .bold()
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                    }
            }
            .padding(.top, 420)
        }
    }
    
    @ViewBuilder
    private func VorteilRow(vorteil: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            
            Text(vorteil)
                .font(.system(size: 18))
                .foregroundStyle(.white)
        }
    }
}


#Preview {
    TestPremiumView()
}

#Preview {
    PremiumPlanView()
}
