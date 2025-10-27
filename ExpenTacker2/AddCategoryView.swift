//
//  AddCategoryView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//
//  --- REDESIGNED based on Wireframe, Dark Palette & CornerRadius 3 ---
//

import SwiftUI

struct AddCategoryView: View {
    let dataManager: ExpenseDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var categoryName = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedColor: Color = .blue
    
    // Check if form is valid (name is not empty)
    private var isFormValid: Bool {
        !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea() // Main background

            VStack(spacing: 0) { // Main VStack
                
                // MARK: - Custom Header
                ZStack {
                    Color.cardBackground // #2D3044
                    
                    Text("新增分類")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack {
                        Button("取消") { dismiss() }
                            .foregroundColor(.primaryText.opacity(0.8))
                        Spacer()
                        Button("儲存") { saveCategory() }
                            .foregroundColor(isFormValid ? .brandGold : .gray) // Use gold, disable if invalid
                            .disabled(!isFormValid)
                    }
                    .padding(.horizontal)
                }
                .frame(height: 48) // Fixed header height

                // MARK: - Content Area
                ScrollView {
                    VStack(spacing: 20) { // Spacing between elements
                        
                        // MARK: - Input Card
                        VStack(alignment: .leading, spacing: 15) { // Spacing inside card
                            
                            // Name Row
                            HStack {
                                Text("名稱")
                                    .foregroundColor(.primaryText.opacity(0.8))
                                    .frame(width: 60, alignment: .leading)
                                TextField("", text: $categoryName, prompt: Text("請輸入分類名稱").foregroundColor(.gray.opacity(0.5)))
                                    .foregroundColor(.primaryText)
                                    .textFieldStyle(.plain)
                                    .padding(8)
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(3) // Corner Radius 3
                                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            }
                            .frame(height: 60)
                            
                            // Type Row (Custom Picker)
                            HStack {
                                Text("類型")
                                    .foregroundColor(.primaryText.opacity(0.8))
                                    .frame(width: 60, alignment: .leading)
                                
                                HStack(spacing: 5) {
                                    Button("收入") { selectedType = .income }
                                        .frame(maxWidth: .infinity, minHeight: 32)
                                        .background(selectedType == .income ? Color.highlightGreen : Color.black.opacity(0.2))
                                        .foregroundColor(.primaryText)
                                        .cornerRadius(3) // Corner Radius 3

                                    Button("支出") { selectedType = .expense }
                                        .frame(maxWidth: .infinity, minHeight: 32)
                                        .background(selectedType == .expense ? Color.highlightRed : Color.black.opacity(0.2))
                                        .foregroundColor(.primaryText)
                                        .cornerRadius(3) // Corner Radius 3
                                }
                                .padding(3)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(3) // Corner Radius 3
                            }
                            .frame(height: 60)
                            
                            // Color Picker Row
                            HStack {
                                Text("顏色")
                                    .foregroundColor(.primaryText.opacity(0.8))
                                    .frame(width: 60, alignment: .leading)
                                
                                ColorPicker("", selection: $selectedColor, supportsOpacity: true)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity, alignment: .trailing) // Push picker to the right
                            }
                            .frame(height: 60)

                        } // End Card VStack
                        .padding() // Inner padding for the card
                        .frame(width: 322) // Fixed width
                        .background(Color.substrateBackground) // Card background
                        .cornerRadius(3) // Card Corner Radius 3
                        
                    } // End Main Content VStack
                    .padding(.top, 25) // Space below header
                    .padding(.bottom, 20) // Space at bottom
                    
                } // End ScrollView
                
            } // End Main VStack
        } // End ZStack
        .preferredColorScheme(.dark)
    }
    
    // Removed private var previewSection
    
    private func saveCategory() {
        guard isFormValid else { return } // Double check validity
        
        let newCategory = ExpenseCategory(
            name: categoryName.trimmingCharacters(in: .whitespacesAndNewlines),
            color: selectedColor,
            type: selectedType
        )
        
        dataManager.addCategory(newCategory)
        dismiss()
    }
}

#Preview {
    AddCategoryView(dataManager: ExpenseDataManager())
        .preferredColorScheme(.dark)
}

// --- Color Extension Placeholder ---
// Assume Color+Extensions.swift exists in your project.
/*
 extension Color {
     static let pageBackground = Color(hex: "#1A1D2E")
     static let cardBackground = Color(hex: "#2D3044")
     static let substrateBackground = Color(hex: "#293158")
     static let primaryText = Color(hex: "#FFFFFF")
     static let brandGold = Color(hex: "#F1B606")
     static let highlightGreen = Color(hex: "#6FCF97")
     static let highlightRed = Color(hex: "#EB5757")
     init(hex: String) { ... }
 }
*/
