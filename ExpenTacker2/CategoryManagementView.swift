//
//  CategoryManagementView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//
//  --- REDESIGNED based on Custom Header & No Default Row ---
//

import SwiftUI

struct CategoryManagementView: View {
    @ObservedObject var dataManager: ExpenseDataManager // Use @ObservedObject
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddCategory = false
    @State private var editingCategoryItem: ExpenseCategory? = nil // Correct state variable

    // Removed noneCategory
    private var incomeCategories: [ExpenseCategory] {
        dataManager.categories.filter { $0.type == .income && !$0.isDefault }
    }
    private var expenseCategories: [ExpenseCategory] {
        dataManager.categories.filter { $0.type == .expense && !$0.isDefault }
    }
    
    var body: some View {
        // **[修改]** Remove NavigationView, use ZStack + VStack
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            VStack(spacing: 0) { // Main VStack
                
                // MARK: - Custom Header
                ZStack {
                    Color.cardBackground // #2D3044
                    
                    Text("分類管理")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack {
                        Button("關閉") { dismiss() }
                            .foregroundColor(.primaryText.opacity(0.8)) // Match style
                        Spacer()
                        Button { showingAddCategory = true } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.brandGold)
                        }
                    }
                    .padding(.horizontal) // Add padding to buttons
                }
                .frame(height: 48) // Fixed header height

                // MARK: - List Content
                ScrollView {
                    VStack(spacing: 20) { // Spacing between sections
                        
                        // **[移除]** "預設" Section Removed
                        // Section("預設") { ... }
                        
                        // MARK: - Income Section
                        VStack(alignment: .leading, spacing: 10) { // Section content
                            Text("收入分類")
                                .font(.headline)
                                .foregroundColor(.primaryText.opacity(0.8))
                                .padding(.horizontal) // Align title
                            
                            if incomeCategories.isEmpty {
                                Text("尚未建立收入分類")
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center) // Center text
                            }
                            ForEach(incomeCategories) { category in
                                CategoryRowView(category: category)
                                    .contentShape(Rectangle())
                                    .onTapGesture { editingCategoryItem = category }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button { editingCategoryItem = category } label: {
                                            Label("編輯", systemImage: "pencil")
                                        }.tint(.blue)
                                        Button(role: .destructive) { dataManager.deleteCategory(category) } label: {
                                            Label("刪除", systemImage: "trash")
                                        }
                                        .tint(.highlightRed)
                                    }
                            }
                        } // End Income VStack
                        
                        // MARK: - Expense Section
                        VStack(alignment: .leading, spacing: 10) { // Section content
                            Text("支出分類")
                                .font(.headline)
                                .foregroundColor(.primaryText.opacity(0.8))
                                .padding(.horizontal) // Align title
                            
                            if expenseCategories.isEmpty {
                                Text("尚未建立支出分類")
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center) // Center text
                            }
                            ForEach(expenseCategories) { category in
                                CategoryRowView(category: category)
                                    .contentShape(Rectangle())
                                    .onTapGesture { editingCategoryItem = category }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button { editingCategoryItem = category } label: {
                                            Label("編輯", systemImage: "pencil")
                                        }.tint(.blue)
                                        Button(role: .destructive) { dataManager.deleteCategory(category) } label: {
                                            Label("刪除", systemImage: "trash")
                                        }
                                        .tint(.highlightRed)
                                    }
                            }
                        } // End Expense VStack

                    } // End Sections VStack
                    .padding(.top, 20) // Space below header
                } // End ScrollView
            } // End Main VStack
        } // End ZStack
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(dataManager: dataManager)
                .preferredColorScheme(.dark)
        }
        .sheet(item: $editingCategoryItem, content: { category in
            EditCategoryView(dataManager: dataManager, category: category)
                .preferredColorScheme(.dark)
        })
        .preferredColorScheme(.dark) // Enforce dark mode for the whole view
    }
}

// MARK: - CategoryRowView (Updated Styles)
struct CategoryRowView: View {
    let category: ExpenseCategory
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(category.color)
                .frame(width: 18, height: 18)
            
            Text(category.name)
                .font(.subheadline)
                .foregroundColor(.primaryText) // White text
            
            Spacer()
            
            Text(category.type.displayName)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                // Use semantic colors from palette
                .background(category.type == .income ? Color.highlightGreen : (category.type == .expense ? Color.highlightRed : Color.gray))
                .foregroundColor(category.type == .all ? .primaryText : .white) // Text color on label
                .cornerRadius(3) // Corner Radius = 3
        }
        .padding() // Row inner padding
        .background(Color.substrateBackground) // Row background
        .cornerRadius(3) // Row Corner Radius = 3
        .padding(.horizontal) // Row padding from screen edges
    }
}

// MARK: - Preview
#Preview {
    CategoryManagementView(dataManager: ExpenseDataManager())
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
