//
//  ContentView.swift
//  ExpenTacker2
//
//  Created by Gemini on 2025/10/26.
//
//  --- ABSOLUTELY COMPLETE CODE (Oct 26 - Final Version) ---
//  Includes all previous refinements + TransactionCardView bg-substrate background.
//  No omissions ('/* ... */').
//

import SwiftUI

// Enum for Tabs (Keep outside ContentView)
enum Tab {
    case home, analysis, categories
}

struct ContentView: View {
    @EnvironmentObject var dataManager: ExpenseDataManager
    @State private var showingAddExpense = false
    @State private var showingExpenseList = false
    @State private var showingCategories = false
    @State private var showingEditExpense = false
    @State private var editingExpense: ExpenseRecord? = nil
    @State private var selectedTab: Tab = .home

    // --- Formatting Helpers ---
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
         return dataManager.currentMonthDateRangeText // Use dynamic data
        // return "10月01日 - 10月31日" // Static text fallback
    }
    // --- End Formatting Helpers ---

    // --- Dummy Data ---
    let dummyExpenses: [ExpenseRecord] = [
        ExpenseRecord(remark: "蓬萊自助餐", amount: 80, date: Date(), type: .expense, color: .red),
        ExpenseRecord(remark: "電影票", amount: 250, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, type: .expense, color: .orange),
        ExpenseRecord(remark: "捷運", amount: 35, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, type: .expense, color: .blue),
        ExpenseRecord(remark: "薪水", amount: 50000, date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, type: .income, color: .green),
        ExpenseRecord(remark: "晚餐", amount: 120, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, type: .expense, color: .red)
    ]
    // --- End Dummy Data ---

    var body: some View {
        NavigationView {
            ZStack {
                Color.pageBackground.ignoresSafeArea() // Background color extends to all safe areas

                VStack(spacing: 25) { // Controls space between Header and ScrollView

                    // MARK: - Header (Fixed at the top)
                    ZStack {
                        Color.cardBackground // Header background uses cardBackground
                        Text("總覽")
                            .foregroundColor(.primaryText)
                            .font(.system(size: 16, weight: .bold)) // Header remains bold
                    }
                    .frame(height: 48)

                    // MARK: - Scrollable Content Area
                    ScrollView {
                        VStack(spacing: 0) { // spacing: 0, controlled by padding below elements

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
                            .background(Color.pageBackground) // Ensure background matches page
                            .padding(.bottom, 25) // Space below month selector

                            // MARK: - 收支區塊 (Centered Horizontally)
                            HStack {
                                Spacer()
                                expenseCardSection // The card itself
                                Spacer()
                            }
                            .padding(.bottom, 25) // Space below stats card

                            // MARK: - 交易明細 (Centered Horizontally)
                            HStack {
                                Spacer()
                                transactionsSectionWithDummyData // The list section
                                Spacer()
                            }
                            // No bottom padding needed here, let ScrollView handle it

                        } // End ScrollView's inner VStack
                    } // End ScrollView
                    
                } // End Main VStack controlling Header and ScrollView
                
            } // End ZStack
            .navigationBarHidden(true) // Keep Nav Bar hidden
            .environmentObject(dataManager)
            .preferredColorScheme(.dark) // Enforce dark mode
            
            // MARK: - Toolbar (Bottom Tab Bar)
            .toolbar {
                 ToolbarItemGroup(placement: .bottomBar) {
                     HStack { // Container for tab buttons
                         // Tab 1: Home
                         TabBarButton(
                            iconName: "house.fill", text: "新增消費",
                            isSelected: selectedTab == .home
                         ) { selectedTab = .home }
                         Spacer()
                         // Tab 2: Analysis
                         TabBarButton(
                            iconName: "chart.pie.fill", text: "消費分析",
                            isSelected: selectedTab == .analysis
                         ) { selectedTab = .analysis; showingExpenseList = true }
                         Spacer()
                         // Tab 3: Categories
                         TabBarButton(
                            iconName: "list.bullet.rectangle.portrait.fill", text: "分類管理",
                            isSelected: selectedTab == .categories
                         ) { selectedTab = .categories; showingCategories = true }
                     }
                     .padding(.horizontal) // Padding for button spacing from edges
                     .padding(.vertical, 15) // Vertical padding for height
                     .frame(maxWidth: .infinity) // Span full width
                     // Background is now handled by ZStack's Color.pageBackground
                 }
             }
             .toolbarBackground(.hidden, for: .bottomBar) // Make system background transparent

        } // End NavigationView
        // Sheets
         .sheet(isPresented: $showingAddExpense) { AddExpenseView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingExpenseList) { ExpenseListView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingCategories) { CategoryManagementView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingEditExpense) {
             if let editingExpense = editingExpense { EditExpenseView(dataManager: dataManager, expense: editingExpense).preferredColorScheme(.dark) }
         }
    } // End body

    // MARK: - 統計卡片區域 (Fixed size 343x189, Padding 17, Centered Content)
    private var expenseCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer() // Top spacer for vertical centering
            HStack {
                Text("收入")
                    .font(.system(size: 14)).foregroundColor(.primaryText.opacity(0.8))
                Spacer()
                Text(formatAmountValue(dataManager.currentMonthIncome))
                    .font(.system(size: 14)).foregroundColor(.highlightGreen).fontWeight(.medium)
            }
            HStack {
                Text("支出")
                    .font(.system(size: 14)).foregroundColor(.primaryText.opacity(0.8))
                Spacer()
                Text(formatAmountValue(dataManager.currentMonthExpense))
                    .font(.system(size: 14)).foregroundColor(.highlightRed).fontWeight(.medium)
            }
            Rectangle().fill(Color.brandGold).frame(height: 1).padding(.vertical, 5)
            VStack(spacing: 4) {
                Text("本月結餘")
                    .font(.system(size: 14)).foregroundColor(.primaryText.opacity(0.8))
                Text(formatBalanceValue(dataManager.currentMonthBalance))
                    .font(.system(size: 24, weight: .bold)).foregroundColor(.highlightGreen)
            }
            .frame(maxWidth: .infinity).padding(.top, 4)
            Spacer() // Bottom spacer for vertical centering
        }
        .padding(17) // Apply 17px padding
        .frame(width: 343, height: 189) // Apply fixed frame
        .background(Color.substrateBackground) // This card uses substrateBackground
        .cornerRadius(3)
    }

     // MARK: - 交易明細區域 (Max Width 343, Spacing 10, Non-Bold Title)
     private var transactionsSectionWithDummyData: some View {
         VStack(alignment: .leading, spacing: 10) { // Controls spacing between title and list
             Text("交易明細")
                 .font(.headline) // Use headline size, default weight (not bold)
                 .foregroundColor(.primaryText)
                 .padding(.bottom, 5) // Space below title

             VStack(spacing: 10) { // **THIS VSTACK CONTROLS CARD SPACING**
                 ForEach(dummyExpenses.indices, id: \.self) { index in
                     let expense = dummyExpenses[index]
                     let category = dataManager.getCategory(by: expense.categoryId) // Get category info

                     TransactionCardView( // <<< Uses the updated TransactionCardView below
                         expense: expense, category: category,
                         onEdit: { print("Edit \(expense.remark)") }, // Dummy action
                         onDelete: { print("Delete \(expense.remark)") } // Dummy action
                     )
                     .environmentObject(dataManager) // Pass manager
                     
                     // No Divider needed, spacing handles separation
                 }
             } // End ForEach VStack

         }
         .frame(maxWidth: 343) // Constrain width of the whole section
     }

} // End ContentView struct

// MARK: - TabBarButton Helper View
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

// MARK: - 交易卡片組件 (Height 60, Date Format, Amount Padding, substrateBackground)
 struct TransactionCardView: View {
     let expense: ExpenseRecord
     let category: ExpenseCategory
     let onEdit: () -> Void
     let onDelete: () -> Void
     @EnvironmentObject var dataManager: ExpenseDataManager

     // Date Formatter for "M月dd日"
     private static var dateFormatter: DateFormatter = {
         let formatter = DateFormatter()
         formatter.locale = Locale(identifier: "zh_TW") // Correct locale
         formatter.dateFormat = "M月dd日"
         return formatter
     }()

     // Use the new date formatter
     private var formattedDisplayDate: String {
         TransactionCardView.dateFormatter.string(from: expense.date)
     }

     // Format amount as "80 元"
     private var formattedAmountForDisplay: String {
         let numberString = String(format: "%.0f", abs(expense.amount))
         return "\(numberString) 元"
     }

     var body: some View {
         HStack(spacing: 15) {
             // Image ('X' or Photo)
             if let photoFilename = expense.photoFilename, let image = dataManager.loadImage(for: photoFilename) {
                  Image(uiImage: image)
                     .resizable().scaledToFill().frame(width: 50, height: 50)
                     .clipShape(RoundedRectangle(cornerRadius: 8)).clipped()
             } else {
                 Image(systemName: "xmark") // Fallback 'X'
                     .font(.title2).foregroundColor(.primaryText.opacity(0.7))
                     .frame(width: 50, height: 50).background(Color.gray.opacity(0.3))
                     .clipShape(RoundedRectangle(cornerRadius: 8))
             }

             // Middle Text (Remark & Date)
             VStack(alignment: .leading, spacing: 4) {
                 Text(expense.remark)
                     .font(.subheadline).fontWeight(.medium).foregroundColor(.primaryText)
                     .lineLimit(1)
                 Text(formattedDisplayDate) // Use new date format
                     .font(.caption).foregroundColor(.primaryText.opacity(0.7))
             }
             
             Spacer(minLength: 10) // Minimum space before amount

             // Amount Text
             Text(formattedAmountForDisplay)
                 .font(.subheadline).fontWeight(.medium).foregroundColor(.primaryText)
                 .padding(.trailing, 5) // Padding from right edge

         }
         .padding(.vertical, 5) // Adjust vertical padding to fit content
         .frame(height: 60)      // Set fixed height
         // **[確認修改]** Use bg-substrate background
         .background(Color.substrateBackground) // <-- Use bg-substrate (#293158)
         .cornerRadius(8)
         .swipeActions(edge: .trailing) {
             Button { onEdit() } label: { Label("編輯", systemImage: "pencil") }.tint(.blue)
             Button(role: .destructive) { onDelete() } label: { Label("刪除", systemImage: "trash") }.tint(.red)
         }
     }
 }

// MARK: - 空狀態視圖
 struct EmptyStateView: View {
     var body: some View {
         VStack(spacing: 16) {
             Image(systemName: "tray").font(.system(size: 48)).foregroundColor(.gray)
             Text("還沒有記錄").font(.headline).foregroundColor(.gray)
             Text("點擊下方的「新增消費」開始記帳").font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
         }
         .padding(.vertical, 32)
     }
 }

// MARK: - Preview
#Preview {
    let previewDataManager = ExpenseDataManager();
    // Example: Add dummy data for preview consistency
    // let dummyExpenses = ContentView().dummyExpenses
    // previewDataManager.expenses = dummyExpenses // Assign dummy data

    return ContentView()
        .environmentObject(previewDataManager)
        .preferredColorScheme(.dark)
}

// --- Formatting Helper Implementations (Copied from above for completeness) ---
// Note: Fileprivate helpers are only visible within this file.
// If needed elsewhere, they should be moved or made internal/public.
fileprivate func formatAmountValue(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    let numberString = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
    return "\(numberString) 元"
}

fileprivate func formatBalanceValue(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    let numberString = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
    return "$ \(numberString)"
}
// --- End Formatting Helpers ---
