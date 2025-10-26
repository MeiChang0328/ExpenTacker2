//
//  ContentView.swift
//  ExpenTacker2
//
//  Created by Gemini on 2025/10/26.
//

import SwiftUI

// **[新增]** Enum to represent the tabs
enum Tab {
    case home, analysis, categories
}

struct ContentView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager // Still needed for Card Section + Preview
    @State private var showingAddExpense = false
    @State private var showingExpenseList = false
    @State private var showingCategories = false
    @State private var showingEditExpense = false
    @State private var editingExpense: ExpenseRecord? = nil

    @State private var selectedTab: Tab = .home

    // --- Formatting Helpers (保持不變) ---
    private func formatAmountValue(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let numberString = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
        return "\(numberString) 元"
    }
    private func formatBalanceValue(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let numberString = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
        return "$ \(numberString)"
    }
    private var currentMonthDateRangeText: String {
         // For preview consistency, use static text, but keep dynamic for real use
         // return "10月01日 - 10月31日"
         return dataManager.currentMonthDateRangeText
    }
    // --- End Formatting Helpers ---

    // **[新增]** Dummy Data for Transaction List Preview
    let dummyExpenses: [ExpenseRecord] = [
        ExpenseRecord(remark: "蓬萊自助餐", amount: 80, date: Date(), type: .expense, color: .red, categoryId: nil),
        ExpenseRecord(remark: "電影票", amount: 250, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, type: .expense, color: .orange, categoryId: nil),
        ExpenseRecord(remark: "捷運", amount: 35, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, type: .expense, color: .blue, categoryId: nil),
        ExpenseRecord(remark: "薪水", amount: 50000, date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, type: .income, color: .green, categoryId: nil),
        ExpenseRecord(remark: "晚餐", amount: 120, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, type: .expense, color: .red, categoryId: nil)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // **[修改]** 背景色延伸至包含 Tab Bar 區域 (移除 edges: .top)
                Color.pageBackground.ignoresSafeArea() // Let it extend everywhere

                VStack(spacing: 25) { // Header 與 ScrollView 的間距

                    // MARK: - Header (Fixed at the top)
                    ZStack {
                        Color.cardBackground
                        Text("總覽")
                            .foregroundColor(.primaryText)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(height: 48)

                    // MARK: - Scrollable Content Area
                    ScrollView {
                        VStack(spacing: 0) { // spacing: 0 由 padding 控制

                            // MARK: - 月份選單
                            HStack(spacing: 4) {
                                Spacer()
                                Text(currentMonthDateRangeText)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primaryText)
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 6)
                                    .foregroundColor(.brandGold)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .background(Color.pageBackground)
                            .padding(.bottom, 25) // 間距: 月份 -> 收支

                            // MARK: - 收支區塊
                            HStack {
                                Spacer()
                                expenseCardSection
                                Spacer()
                            }
                            .padding(.bottom, 25) // 卡片與交易明細區塊的間隔

                            // MARK: - 交易明細 (使用假資料)
                            transactionsSectionWithDummyData // **[修改]** 使用假資料版本

                        }
                    } // End ScrollView
                    
                } // End Main VStack
                
            } // End ZStack
            .navigationBarHidden(true)
            .environmentObject(dataManager) // Still needed for Preview & Card
            .preferredColorScheme(.dark)
            
            // MARK: - Toolbar (Bottom Tab Bar) - No Background
            .toolbar {
                 ToolbarItemGroup(placement: .bottomBar) {
                     HStack {
                         TabBarButton(iconName: "house.fill", text: "新增消費", isSelected: selectedTab == .home) { selectedTab = .home }
                         Spacer()
                         TabBarButton(iconName: "chart.pie.fill", text: "消費分析", isSelected: selectedTab == .analysis) { selectedTab = .analysis; showingExpenseList = true }
                         Spacer()
                         TabBarButton(iconName: "list.bullet.rectangle.portrait.fill", text: "分類管理", isSelected: selectedTab == .categories) { selectedTab = .categories; showingCategories = true }
                     }
                     .padding(.horizontal)
                     .padding(.vertical, 15) // Height Adjustment
                     .frame(maxWidth: .infinity)
                     // **[修改]** 背景由 ZStack 的 pageBackground 提供
                     // .background(Color.cardBackground) // Removed background color
                 }
             }
             // **[修改]** 移除 toolbarBackground 設定，使其透明
             // .toolbarBackground(Color.cardBackground, for: .bottomBar) // Removed
             .toolbarBackground(.hidden, for: .bottomBar) // Make it explicitly hidden/transparent
             // .toolbarBackground(.visible, for: .bottomBar) // Removed

        } // End NavigationView
        // Sheets (保持不變)
         .sheet(isPresented: $showingAddExpense) { AddExpenseView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingExpenseList) { ExpenseListView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingCategories) { CategoryManagementView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingEditExpense) {
             if let editingExpense = editingExpense { EditExpenseView(dataManager: dataManager, expense: editingExpense).preferredColorScheme(.dark) }
         }
    } // End body

    // MARK: - 統計卡片區域 (保持不變)
    private var expenseCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            HStack {
                Text("收入")
                    .font(.system(size: 14))
                    .foregroundColor(.primaryText.opacity(0.8))
                Spacer()
                Text(formatAmountValue(dataManager.currentMonthIncome))
                    .font(.system(size: 14))
                    .foregroundColor(.highlightGreen)
                    .fontWeight(.medium)
            }
            HStack {
                Text("支出")
                    .font(.system(size: 14))
                    .foregroundColor(.primaryText.opacity(0.8))
                Spacer()
                Text(formatAmountValue(dataManager.currentMonthExpense))
                    .font(.system(size: 14))
                    .foregroundColor(.highlightRed)
                    .fontWeight(.medium)
            }
            Rectangle()
                .fill(Color.brandGold)
                .frame(height: 1)
                .padding(.vertical, 5)
            VStack(spacing: 4) {
                Text("本月結餘")
                    .font(.system(size: 14))
                     .foregroundColor(.primaryText.opacity(0.8))
                Text(formatBalanceValue(dataManager.currentMonthBalance))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.highlightGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            Spacer()
        }
        .padding(17)
        .frame(width: 343, height: 189)
        .background(Color.substrateBackground)
        .cornerRadius(3)
    }


     // MARK: - 交易明細區域 (使用假資料)
     private var transactionsSectionWithDummyData: some View { // **[修改]** Renamed
         VStack(alignment: .leading, spacing: 10) {
             Text("交易明細")
                 .font(.headline)
                 .foregroundColor(.primaryText)
                 .padding(.bottom, 5)
                 .padding(.horizontal) // Match card horizontal padding visually

             // **[修改]** 使用 dummyExpenses 陣列
             VStack(spacing: 0) {
                 ForEach(dummyExpenses.indices, id: \.self) { index in
                     let expense = dummyExpenses[index]
                     // Use dummy category info or fetch default 'none'
                     let category = dataManager.getCategory(by: expense.categoryId) // Can still use this

                     TransactionCardView(
                         expense: expense,
                         category: category, // Pass category info
                         onEdit: { /* Dummy action */ print("Edit \(expense.remark)") },
                         onDelete: { /* Dummy action */ print("Delete \(expense.remark)") }
                     )
                     // **[修改]** EnvironmentObject might not be strictly needed if card doesn't load image, but keep for consistency
                     .environmentObject(dataManager)

                     // Add divider if not the last item
                     if index < dummyExpenses.count - 1 {
                          Divider()
                             .background(Color.gray.opacity(0.3))
                             // **[修改]** Divider padding should match card's internal content padding start/end
                             .padding(.leading, 15 + 50 + 15) // Card H Padding + Icon Width + Spacing
                             // Or simply full width: .padding(.horizontal)
                     }
                 }
             }
             // **[修改]** Add horizontal padding to the list container to match card padding
             .padding(.horizontal)

         }
         // 間距由上方的 expenseCardSection 控制
     }

} // End ContentView struct

// MARK: - TabBarButton Helper View (保持不變)
struct TabBarButton: View {
    let iconName: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .brandGold : .brandGold.opacity(0.7))
                Text(text)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .primaryText : .primaryText.opacity(0.7))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background( Capsule().fill(isSelected ? Color.brandGold.opacity(0.15) : Color.clear) )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - 交易卡片組件 (保持不變)
 struct TransactionCardView: View {
     let expense: ExpenseRecord
     let category: ExpenseCategory
     let onEdit: () -> Void
     let onDelete: () -> Void
     @EnvironmentObject var dataManager: ExpenseDataManager

     private var formattedAmountForDisplay: String {
         let numberString = String(format: "%.0f", abs(expense.amount))
         return "\(numberString) 元"
     }

     var body: some View {
         HStack(spacing: 15) {
             // **[修改]** Check for actual image even with dummy data
             if let photoFilename = expense.photoFilename, let image = dataManager.loadImage(for: photoFilename) {
                  Image(uiImage: image)
                     .resizable().scaledToFill().frame(width: 50, height: 50).clipShape(RoundedRectangle(cornerRadius: 8))
             } else {
                 Image(systemName: "xmark") // Fallback 'X'
                     .font(.title2)
                     .foregroundColor(.primaryText.opacity(0.7))
                     .frame(width: 50, height: 50)
                     .background(Color.gray.opacity(0.3))
                     .clipShape(RoundedRectangle(cornerRadius: 8))
             }

             VStack(alignment: .leading, spacing: 4) {
                 Text(expense.remark)
                     .font(.subheadline).fontWeight(.medium).foregroundColor(.primaryText)
                 Text(expense.formattedDate) // Use expense's date formatter
                     .font(.caption).foregroundColor(.primaryText.opacity(0.7))
             }
             Spacer()
             Text(formattedAmountForDisplay)
                 .font(.subheadline).fontWeight(.medium).foregroundColor(.primaryText)
         }
         .padding(.horizontal, 0) // No internal horizontal padding
         .padding(.vertical, 10)
         .background(Color.cardBackground) // Card background color
         // Note: Swipe actions might not work correctly on dummy data unless integrated properly
         .swipeActions(edge: .trailing) {
             Button { onEdit() } label: { Label("編輯", systemImage: "pencil") }.tint(.blue)
             Button(role: .destructive) { onDelete() } label: { Label("刪除", systemImage: "trash") }.tint(.red)
         }
     }
 }


// MARK: - 空狀態視圖 (保持不變)
 struct EmptyStateView: View {
     var body: some View {
         VStack(spacing: 16) { /* ... Same as before ... */ }
     }
 }


#Preview {
    let previewDataManager = ExpenseDataManager()
    // You could add dummy data to previewDataManager as well
    // previewDataManager.expenses = ContentView().dummyExpenses // Example

    return ContentView()
        .environmentObject(previewDataManager)
        .preferredColorScheme(.dark)
}
