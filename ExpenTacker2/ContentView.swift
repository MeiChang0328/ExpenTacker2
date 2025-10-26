//
//  ContentView.swift
//  ExpenTacker2
//
//  Created by Gemini on 2025/10/26.
//
//  --- ABSOLUTELY COMPLETE CODE (Oct 27 - Swipe Release Trigger Final, No Omissions) ---
//

import SwiftUI

// Enum for Tabs
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

    @State private var displayedDate: Date = Date() // Default to current month

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
        return "$ \(numberString)" // Screenshot style (absolute value)
    }
    
    private static var monthFormatter: DateFormatter = {
         let formatter = DateFormatter()
         formatter.locale = Locale(identifier: "zh_TW")
         formatter.dateFormat = "yyyy年 M月"
         return formatter
     }()
     
     private var formattedSelectedMonth: String {
         ContentView.monthFormatter.string(from: displayedDate)
     }
     
     private var selectedMonthDateRange: (start: Date, end: Date) {
         let calendar = Calendar.current
         guard let startOfMonth = calendar.dateInterval(of: .month, for: displayedDate)?.start,
               let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
             return (displayedDate, displayedDate) // Fallback
         }
         let endOfDay = calendar.startOfDay(for: endOfMonth).addingTimeInterval(24*60*60 - 1)
         return (startOfMonth, endOfDay)
     }

    private var filteredExpensesForSelectedMonth: [ExpenseRecord] {
        let range = selectedMonthDateRange
        return dataManager.expenses.filter { expense in
            expense.date >= range.start && expense.date <= range.end
        }.sorted { $0.date > $1.date } // Keep sorted by date descending
    }
    
    private var selectedMonthIncome: Double {
        filteredExpensesForSelectedMonth.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    private var selectedMonthExpense: Double {
        filteredExpensesForSelectedMonth.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    private var selectedMonthBalance: Double {
        selectedMonthIncome - selectedMonthExpense
    }
    // --- End Formatting & Filtering Helpers ---

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

                            // MARK: - 月份選單 (Interactive)
                            monthSelector // Use the extracted view
                                .padding(.bottom, 25) // Space below month selector

                            // MARK: - 收支區塊 (Centered Horizontally)
                            HStack {
                                Spacer()
                                expenseCardSection // Uses selected month data
                                Spacer()
                            }
                            .padding(.bottom, 25) // Space below stats card

                            // MARK: - 交易明細 (Centered Horizontally)
                            HStack {
                                Spacer()
                                transactionsSection // Uses selected month data
                                Spacer()
                            }

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
                         ) { selectedTab = .home; showingAddExpense = true } // Action added
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
                 }
             }
             .toolbarBackground(.hidden, for: .bottomBar) // Make system background transparent

        } // End NavigationView
        // Sheets
         .sheet(isPresented: $showingAddExpense) { AddExpenseView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingExpenseList) { ExpenseListView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingCategories) { CategoryManagementView(dataManager: dataManager).preferredColorScheme(.dark) }
         .sheet(isPresented: $showingEditExpense, onDismiss: { editingExpense = nil }) { // Clear editingExpense on dismiss
             if let expenseToEdit = editingExpense {
                 EditExpenseView(dataManager: dataManager, expense: expenseToEdit)
                     .preferredColorScheme(.dark)
             } else {
                 Text("錯誤：找不到要編輯的資料").padding().preferredColorScheme(.dark)
             }
         }
    } // End body

    // MARK: - 月份選單 View
    private var monthSelector: some View {
        HStack(spacing: 15) {
            Spacer()
            Button { changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.brandGold)
            }
            Text(formattedSelectedMonth)
                .font(.system(size: 14)).foregroundColor(.primaryText)
                .frame(minWidth: 100)
            Button { changeMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.brandGold)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.pageBackground)
    }

    // MARK: - 統計卡片區域 (Uses Selected Month Data)
    private var expenseCardSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            HStack {
                Text("收入").font(.system(size: 14)).foregroundColor(.primaryText.opacity(0.8))
                Spacer()
                Text(formatAmountValue(selectedMonthIncome)).font(.system(size: 14)).foregroundColor(.highlightGreen).fontWeight(.medium)
            }
            HStack {
                Text("支出").font(.system(size: 14)).foregroundColor(.primaryText.opacity(0.8))
                Spacer()
                Text(formatAmountValue(selectedMonthExpense)).font(.system(size: 14)).foregroundColor(.highlightRed).fontWeight(.medium)
            }
            Rectangle().fill(Color.brandGold).frame(height: 1).padding(.vertical, 5)
            VStack(spacing: 4) {
                Text("本月結餘").font(.system(size: 14)).foregroundColor(.primaryText.opacity(0.8))
                Text(formatBalanceValue(selectedMonthBalance)).font(.system(size: 24, weight: .bold))
                    .foregroundColor(selectedMonthBalance >= 0 ? .highlightGreen : .highlightRed)
            }
            .frame(maxWidth: .infinity).padding(.top, 4)
            Spacer()
        }
        .padding(17)
        .frame(width: 343, height: 189)
        .background(Color.substrateBackground)
        .cornerRadius(3)
    }

     // MARK: - 交易明細區域 (Uses Selected Month Data)
     private var transactionsSection: some View {
         VStack(alignment: .leading, spacing: 10) {
             Text("交易明細")
                 .font(.headline) // Non-bold title
                 .foregroundColor(.primaryText)
                 .padding(.bottom, 5)

             if filteredExpensesForSelectedMonth.isEmpty {
                 EmptyStateView().frame(maxWidth: .infinity)
             } else {
                 VStack(spacing: 10) { // Card Spacing
                     ForEach(filteredExpensesForSelectedMonth.prefix(5), id: \.id) { expense in
                         let category = dataManager.getCategory(by: expense.categoryId)
                         TransactionCardView( // <<< Uses the updated TransactionCardView below
                             expense: expense, category: category,
                             onEdit: { // This action is triggered by the swipe gesture end
                                 editingExpense = expense
                                 showingEditExpense = true
                             },
                             onDelete: { // Placeholder for delete action
                                 print("Delete action placeholder for \(expense.remark)")
                             },
                             onTap: { // Simple tap action (optional)
                                 print("Tapped on \(expense.remark)")
                             }
                         )
                         .environmentObject(dataManager)
                     }
                 } // End ForEach VStack
             } // End if/else

         }
         .frame(maxWidth: 343) // Constrain width
     }
     
     // MARK: - Helper Function to Change Month
     private func changeMonth(by amount: Int) {
         if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: displayedDate) {
             displayedDate = newDate
         }
     }

} // End ContentView struct

// MARK: - TabBarButton Helper View
struct TabBarButton: View {
    let iconName: String; let text: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName).font(.title2).foregroundColor(isSelected ? .brandGold : .brandGold.opacity(0.7))
                Text(text).font(.caption2).foregroundColor(isSelected ? .primaryText : .primaryText.opacity(0.7))
            }
            .padding(.vertical, 8).padding(.horizontal, 12)
            .background( Capsule().fill(isSelected ? Color.brandGold.opacity(0.15) : Color.clear) )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - 交易卡片組件 (Custom Swipe Gesture, Release Trigger, Black Text)
 struct TransactionCardView: View {
     let expense: ExpenseRecord
     let category: ExpenseCategory
     let onEdit: () -> Void
     let onDelete: () -> Void // Keep for potential future use
     let onTap: () -> Void // Keep for potential future use

     @EnvironmentObject var dataManager: ExpenseDataManager
     
     // --- State for Drag Gesture ---
     @State private var offset: CGFloat = 0
     @State private var isDragging: Bool = false
     private let revealWidth: CGFloat = 80 // Width of the area to reveal
     private let editTriggerThreshold: CGFloat = -60 // Threshold to trigger edit on release
     // --- End State ---
     
     // Date Formatter
     private static var dateFormatter: DateFormatter = {
         let formatter = DateFormatter(); formatter.locale = Locale(identifier: "zh_TW"); formatter.dateFormat = "M月dd日"; return formatter
     }()
     private var formattedDisplayDate: String { TransactionCardView.dateFormatter.string(from: expense.date) }
     private var formattedAmountForDisplay: String { "\(String(format: "%.0f", abs(expense.amount))) 元" }

     var body: some View {
         ZStack {
             // MARK: - Background Reveal Area (Edit Action)
             HStack {
                 Spacer() // Push content to the right
                 Text("編輯")
                     // Set text color to black
                     .foregroundColor(.black)
                     .font(.system(size: 16, weight: .medium))
                     .padding(.horizontal)
                     .frame(width: revealWidth, height: 60) // Match card height
                     // Remove long press gesture here
             }
             .background(Color.brandGold) // Brand color background
             .cornerRadius(8) // Match card corner radius

             // MARK: - Foreground Card Content
             HStack(spacing: 15) {
                 // Image ('X' or Photo)
                 if let photoFilename = expense.photoFilename, let image = dataManager.loadImage(for: photoFilename) {
                      Image(uiImage: image).resizable().scaledToFill().frame(width: 50, height: 50).clipShape(RoundedRectangle(cornerRadius: 8)).clipped()
                 } else {
                     Image(systemName: "xmark").font(.title2).foregroundColor(.primaryText.opacity(0.7)).frame(width: 50, height: 50).background(Color.gray.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 8))
                 }
                 // Middle Text (Remark & Date)
                 VStack(alignment: .leading, spacing: 4) {
                     Text(expense.remark).font(.subheadline).fontWeight(.medium).foregroundColor(.primaryText).lineLimit(1)
                     Text(formattedDisplayDate).font(.caption).foregroundColor(.primaryText.opacity(0.7))
                 }
                 Spacer(minLength: 10)
                 // Amount Text
                 Text(formattedAmountForDisplay).font(.subheadline).fontWeight(.medium).foregroundColor(.primaryText).padding(.trailing, 5)
             }
             .padding(.vertical, 5)
             .frame(height: 60)
             .background(Color.substrateBackground) // Card main background
             .cornerRadius(8)
             .offset(x: offset) // Apply horizontal offset based on drag
             .gesture(
                 DragGesture()
                     .onChanged { gesture in
                         // Only allow dragging left (negative offset)
                         let newOffset = gesture.translation.width
                         // Allow dragging slightly past the reveal width for elasticity
                         offset = max(newOffset, -revealWidth - 20) // Limit drag slightly past reveal
                         if newOffset >= 0 { // Prevent right swipe beyond origin
                             offset = 0
                         }
                         isDragging = true
                     }
                     .onEnded { gesture in
                         withAnimation(.spring()) { // Use spring animation for snap back/trigger
                             // Check threshold to trigger edit action on release
                             if gesture.translation.width < editTriggerThreshold {
                                 // Swiped far enough, trigger edit AFTER animation finishes slightly
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                      onEdit()
                                 }
                                 // Snap back after triggering
                                 offset = 0
                             } else {
                                 // Not swiped far enough, snap back to 0
                                 offset = 0
                             }
                         }
                         isDragging = false
                     }
             ) // End gesture

         } // End ZStack
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

// MARK: - Preview (Simplified)
#Preview {
    ContentView()
        .environmentObject(ExpenseDataManager()) // Provide a basic manager
        .preferredColorScheme(.dark)
}

// --- Formatting Helper Implementations ---
fileprivate func formatAmountValue(_ amount: Double) -> String {
    let formatter = NumberFormatter(); formatter.numberStyle = .decimal; formatter.maximumFractionDigits = 0
    return "\((formatter.string(from: NSNumber(value: abs(amount))) ?? "0")) 元"
}
fileprivate func formatBalanceValue(_ amount: Double) -> String {
    let formatter = NumberFormatter(); formatter.numberStyle = .decimal; formatter.maximumFractionDigits = 0
    return "$ \((formatter.string(from: NSNumber(value: abs(amount))) ?? "0"))"
}

// --- Date Formatter ---
fileprivate extension TransactionCardView {
    static var dateFormatterInstance: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "M月dd日"
        return formatter
    }()
}
// --- End Date Formatter ---
