//
//  CategoryManagementView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/21. // 假設日期
//

import SwiftUI

struct CategoryManagementView: View {
    @ObservedObject var dataManager: ExpenseDataManager
    @Environment(\.dismiss) private var dismiss // 用於關閉 Modal
    
    // 編輯狀態
    @State private var showingAddCategory = false
    @State private var editingCategory: ExpenseCategory? = nil
    
    // 網格佈局
    private let gridItems: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    // 分類資料
    private var incomeCategories: [ExpenseCategory] {
        dataManager.categories.filter { $0.type == .income && !$0.isDefault }
    }
    private var expenseCategories: [ExpenseCategory] {
        dataManager.categories.filter { $0.type == .expense && !$0.isDefault }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("收入分類")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: gridItems, spacing: 20) {
                        ForEach(incomeCategories) { category in
                            CategoryGridItem(category: category)
                                .onTapGesture {
                                    editingCategory = category
                                }
                        }
                    }
                    .padding(.horizontal)

                    Text("支出分類")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)

                    LazyVGrid(columns: gridItems, spacing: 20) {
                        ForEach(expenseCategories) { category in
                            CategoryGridItem(category: category)
                                .onTapGesture {
                                    editingCategory = category
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("分類管理")
            .navigationBarTitleDisplayMode(.inline) // 標題置中
            .toolbar {
                 // 左上角關閉按鈕
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(Color.brandGold) // 品牌色
                }
                // 右上角新增按鈕
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(Color.brandGold) // 品牌色
                }
            }
            // 彈出新增/編輯頁面
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(dataManager: dataManager)
            }
            .sheet(item: $editingCategory) { category in
                EditCategoryView(dataManager: dataManager, category: category)
            }
        }
    }
}

// MARK: - 網格項目 (與 ExpenseListView 中的一致)
struct CategoryGridItem: View {
    let category: ExpenseCategory

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: category.iconName)
                .font(.title2)
                .foregroundColor(category.color)
                .frame(width: 40, height: 40)
                .background(category.color.opacity(0.15))
                .clipShape(Circle())

            Text(category.name)
                .font(.caption2)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    CategoryManagementView(dataManager: ExpenseDataManager())
}
