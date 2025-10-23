//
//  ContentView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//

import SwiftUI

struct ContentView: View {

    // MARK: - Properties
    @ObservedObject var dataManager: ExpenseDataManager

    // UI State
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
    @State private var showingEditExpense = false
    @State private var editingExpense: ExpenseRecord? = nil
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    let months = Array(1...12)

    // MARK: - Initialization (for Navigation Bar Styling)
    init(dataManager: ExpenseDataManager) {
        self.dataManager = dataManager // Initialize @ObservedObject

        // Configure Navigation Bar Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.brandGold) // Brand color background
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // White title
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        // Apply Appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    monthSelector         // Month dropdown
                    summaryCard           // Income/Expense/Balance card
                    addTransactionButtons // Add Income/Expense buttons
                    transactionsSection   // List of recent transactions
                }
                .padding()
            }
            .background(Color.white.ignoresSafeArea()) // White background
            .navigationTitle("總覽")
            .navigationBarTitleDisplayMode(.inline)
            // Apply Navigation Bar color helper (defined below)
            .navigationBarColor(backgroundColor: Color.brandGold, titleColor: .white)
        }
        // Modal Sheets
        .sheet(isPresented: $showingAddIncome) {
            AddExpenseView(dataManager: dataManager, initialType: .income)
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(dataManager: dataManager, initialType: .expense)
        }
        .sheet(isPresented: $showingEditExpense) {
            if let editingExpense = editingExpense {
                EditExpenseView(dataManager: dataManager, expense: editingExpense)
            }
        }
    }

    // MARK: - Private Views

    // Month Selector Dropdown
    private var monthSelector: some View {
        HStack {
            Menu {
                Picker("選擇月份", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { month in
                        Text("\(month)月").tag(month)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("\(selectedMonth)月")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.bottom, 5)
    }

    // Income/Expense/Balance Summary Card
    private var summaryCard: some View {
        VStack(spacing: 8) {
            SummaryRow(label: "收入", amount: dataManager.currentMonthIncome, color: .green)
            SummaryRow(label: "支出", amount: dataManager.currentMonthExpense, color: .red)
            Divider().padding(.vertical, 2)
            SummaryRow(label: "結餘", amount: dataManager.currentMonthBalance, color: dataManager.currentMonthBalance >= 0 ? .primary : .red, isBalance: true)
        }
        .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
        .background(Color.cardBackground)
        .cornerRadius(3)
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.cardBorder, lineWidth: 1))
    }

    // Add Income/Expense Buttons
    private var addTransactionButtons: some View {
        HStack(spacing: 10) {
            Button {
                showingAddIncome = true
            } label: {
                Text("收入 +")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.brandGold) // Brand color background
                    .foregroundColor(.white)      // White text
                    .cornerRadius(3)
            }

            Button {
                showingAddExpense = true
            } label: {
                Text("支出 +")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.brandGold) // Brand color background
                    .foregroundColor(.white)      // White text
                    .cornerRadius(3)
            }
        }
    }

    // Recent Transactions List Section
    private var transactionsSection: some View {
        VStack(spacing: 8) {
            Text("交易明細")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 3)

            if dataManager.expenses.isEmpty {
                EmptyStateView()
                    .padding(.vertical, 30)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(dataManager.expenses.prefix(7))) { expense in
                        WireframeTransactionRow(
                            expense: expense,
                            category: dataManager.getCategory(by: expense.categoryId),
                            onTap: {
                                editingExpense = expense
                                showingEditExpense = true
                            }
                        )
                        if expense.id != dataManager.expenses.prefix(7).last?.id {
                            Divider().padding(.leading, 50) // Indented divider
                        }
                    }
                }
                .background(Color.cardBackground)
                .cornerRadius(3)
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.cardBorder, lineWidth: 1))
            }
        }
        .padding(.top)
    }

} // End of ContentView struct

// MARK: - Nested Helper Structs (Only one definition for each)

// Row inside the Summary Card
struct SummaryRow: View {
    let label: String
    let amount: Double
    let color: Color
    var isBalance: Bool = false

    private var formattedAmount: String {
        let formatter = NumberFormatter(); formatter.numberStyle = .decimal; formatter.maximumFractionDigits = 0
        let value = abs(amount); let formatted = formatter.string(from: NSNumber(value: value)) ?? "0"
        if isBalance { return (amount >= 0 ? "" : "-") + formatted + " 元" } else { return formatted + " 元" }
    }

    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundColor(.secondary)
            Spacer()
            Text(formattedAmount).font(.subheadline).fontWeight(isBalance ? .semibold : .regular).foregroundColor(color)
        }
    }
}

// Row inside the Transactions List (Wireframe Style)
struct WireframeTransactionRow: View {
    let expense: ExpenseRecord
    let category: ExpenseCategory
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: category.iconName)
                .font(.title2)
                .frame(width: 25, alignment: .center)
                .foregroundColor(category.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.remark)
                    .font(.subheadline)
                    .lineLimit(1)
            }

            Spacer()

            Text(expense.formattedAmount.replacingOccurrences(of: "NT$", with: "") + " 元")
                .font(.subheadline)
                .foregroundColor(expense.type == .income ? .green : .primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

// View shown when there are no transactions
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("還沒有交易記錄")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("點擊「收入+」或「支出+」開始記帳")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Helper Modifier for Navigation Bar Color
// (Keep this outside the ContentView struct definition)
struct NavigationBarColor: ViewModifier {
    var backgroundColor: Color
    var titleColor: Color

    init(backgroundColor: Color, titleColor: Color) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        // Apply appearance settings here... (same as before)
         let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(backgroundColor)
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(titleColor)]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(titleColor)]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationBarColor(backgroundColor: Color, titleColor: Color) -> some View {
        self.modifier(NavigationBarColor(backgroundColor: backgroundColor, titleColor: titleColor))
    }
}

// MARK: - Preview
#Preview {
    ContentView(dataManager: ExpenseDataManager())
}
