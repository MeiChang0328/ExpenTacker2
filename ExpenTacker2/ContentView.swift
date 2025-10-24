//
//  ContentView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = ExpenseDataManager()
    @State private var showingAddExpense = false
    @State private var showingExpenseList = false
    @State private var showingCategories = false
    @State private var showingAddCategory = false
    @State private var showingActionMenu = false
    @State private var showingEditExpense = false
    @State private var editingExpense: ExpenseRecord? = nil
    
    @State private var displayedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(edges: .all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 歡迎標題區域
                        welcomeHeaderSection
                        
                        // 統計卡片區域
                        expenseCardSection
                        
                        // 交易明細區域
                        transactionsSection
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
            
            // 移除 .background (Color(.systemGroupedBackground))，避免覆蓋白色
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack(spacing: 24) {
                        Spacer(minLength: 0)
                        Button {
                            // 新增消費 action
                            showingAddExpense = true
                        } label: {
                            VStack {
                                Image(systemName: "plus.circle")
                                Text("新增消費")
                            }
                        }
                        Spacer()
                        Button {
                            // 消費分析 action
                            showingExpenseList = true
                        } label: {
                            VStack {
                                Image(systemName: "chart.bar")
                                Text("消費分析")
                            }
                        }
                        Spacer()
                        Button {
                            // 分類管理 action
                            showingCategories = true
                        } label: {
                            VStack {
                                Image(systemName: "folder")
                                Text("分類管理")
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
            
            .toolbarBackground(Color.white, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(dataManager: dataManager)
        }
        .sheet(isPresented: $showingExpenseList) {
            ExpenseListView(dataManager: dataManager)
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(dataManager: dataManager)
        }
        .sheet(isPresented: $showingEditExpense) {
            if let editingExpense = editingExpense {
                EditExpenseView(dataManager: dataManager, expense: editingExpense)
            }
        }
        // Replace deprecated actionSheet with confirmationDialog
        .confirmationDialog("選擇操作", isPresented: $showingActionMenu, titleVisibility: .visible) {
            Button("新增記錄") { showingAddExpense = true }
            Button("新增分類") { showingAddCategory = true }
            Button("取消", role: .cancel) {}
        } message: {
            Text("你想要做什麼？")
        }
        .sheet(isPresented: $showingCategories) {
            CategoryManagementView(dataManager: dataManager)
        }
    }
    
    // MARK: - 歡迎標題區域
    private var welcomeHeaderSection: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text("歡迎使用!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                Text("記帳本")
                    .font(.title2.bold())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - 統計卡片區域
    private var expenseCardSection: some View {
        VStack(spacing: 16) {
            // 日期範圍顯示
            Text(dataManager.currentMonthDateRangeText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // 主要餘額卡片
            VStack(spacing: 12) {
                Text("本月餘額")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(dataManager.formattedCurrentMonthBalance.text)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(dataManager.formattedCurrentMonthBalance.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // 收入支出卡片
            HStack(spacing: 16) {
                StatisticCard(
                    title: "本月收入",
                    amount: dataManager.formatAmount(dataManager.currentMonthIncome),
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
                
                StatisticCard(
                    title: "本月支出",
                    amount: dataManager.formatAmount(dataManager.currentMonthExpense),
                    color: .red,
                    icon: "arrow.down.circle.fill"
                )
            }
        }
    }
    
    // MARK: - 交易明細區域
    private var transactionsSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("交易明細")
                    .font(.title2.bold())
                    .opacity(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 5)
            
            if dataManager.expenses.isEmpty {
                EmptyStateView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(dataManager.expenses.prefix(5))) { expense in
                        TransactionCardView(
                            expense: expense,
                            category: dataManager.getCategory(by: expense.categoryId),
                            onEdit: {
                                editingExpense = expense
                                showingEditExpense = true
                            },
                            onDelete: {
                                dataManager.deleteExpense(expense)
                            }
                        )
                        .environmentObject(dataManager)
                    }
                }
            }
        }
        .padding(.top)
    }
    
    // MARK: - 月份選擇器 UI (NEW)
        private var monthSelectorSection: some View {
            HStack(spacing: 20) {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.8))
                }
                
                Text(formattedDisplayedMonth)
                    .font(.title2.bold())
                    .frame(minWidth: 160) // 確保有足夠寬度
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.8))
                }
            }
            .padding(.horizontal)
        }
        
        // MARK: - Helper Properties & Functions (NEW)
        
        /// 將 displayedDate 格式化為 "YYYY年 MMMM"
        private var formattedDisplayedMonth: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年 MMMM"
            formatter.locale = Locale(identifier: "zh_Hant_TW") // 假設為繁體中文
            return formatter.string(from: displayedDate)
        }
        
        /// 根據給定的月份數更改 displayedDate
        private func changeMonth(by amount: Int) {
            if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: displayedDate) {
                displayedDate = newDate
                
                // **未來實作提示**:
                // 在這裡，你應該呼叫 dataManager 來更新數據
                // 例如: dataManager.fetchData(for: displayedDate)
                // 這樣 dataManager.currentMonthDateRangeText 和其他統計數據才會更新
            }
        }
}

// MARK: - 改進的統計卡片組件
struct StatisticCard: View {
    let title: String
    let amount: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(amount)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - 交易卡片組件
struct TransactionCardView: View {
    let expense: ExpenseRecord
    let category: ExpenseCategory
    let onEdit: () -> Void
    let onDelete: () -> Void
    @EnvironmentObject var dataManager: ExpenseDataManager
    
    var body: some View {
        HStack(spacing: 15) {
            // 分類圖標或照片
            if let photoFilename = expense.photoFilename,
               let image = dataManager.loadImage(for: photoFilename) {
                // 顯示照片
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(category.color, lineWidth: 2)
                    )
            } else {
                // 沒有照片時顯示分類顏色和圖標
                Circle()
                    .fill(category.color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: expense.type == .income ? "plus" : "minus")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            
            // 交易資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.remark)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 10, height: 10)
                        
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(expense.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 金額
            Text(expense.formattedAmount)
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(expense.type == .income ? .green : .red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .swipeActions(edge: .trailing) {
            // 編輯按鈕
            Button {
                onEdit()
            } label: {
                Label("編輯", systemImage: "pencil")
            }
            .tint(.blue)
            
            // 刪除按鈕
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("刪除", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

// MARK: - 空狀態視圖
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("還沒有記錄")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("點擊「新增記錄」開始記帳")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 32)
    }
}

#Preview {
    ContentView()
}
