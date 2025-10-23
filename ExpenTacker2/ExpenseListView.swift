//
//  ExpenseListView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//

import SwiftUI
import Charts

struct ExpenseListView: View {
    @ObservedObject var dataManager: ExpenseDataManager

    // 篩選器
    @State private var selectedTimeframe: Timeframe = .month // 年/月/日

    // UI 狀態
    @State private var showingCategoryManagement = false

    // --- 資料處理邏輯 ---
    // 取得要顯示的費用 (目前僅支出)
    private var expensesToShow: [ExpenseRecord] {
        dataManager.expenses.filter { $0.type == .expense }
    }

    // 計算圖表數據 (按分類匯總)
    private var chartData: [CategoryChartData] {
        let grouped = Dictionary(grouping: expensesToShow) { $0.categoryId ?? "none" }
        return grouped.map { (categoryId, records) in
            let category = dataManager.getCategory(by: categoryId)
            let total = records.reduce(0) { $0 + $1.amount }
            return CategoryChartData(category: category, amount: total)
        }
        .sorted { $0.amount > $1.amount } // 金額大的排前面
    }

    // 計算總支出
    private var totalExpense: Double {
        chartData.reduce(0) { $0 + $1.amount }
    }

    // 取得最高支出的分類數據
    private var topCategoryData: CategoryChartData? {
        chartData.first
    }

    // 取得最高支出分類下的細項費用
    private var topCategoryExpenses: [ExpenseRecord] {
        guard let topCatId = topCategoryData?.category.id else { return [] }
        return expensesToShow.filter { $0.categoryId == topCatId }
            .sorted { $0.amount > $1.amount } // 金額大的排前面
    }
    // --- 資料處理邏輯結束 ---

    enum Timeframe: String, CaseIterable {
        case year = "年"
        case month = "月"
        case day = "日"
    }

    var body: some View {
        NavigationView {
            // *** 在這個 VStack 加入 padding ***
            VStack(spacing: 0) {
                // 1. 頂部篩選器
                topFilterBar
                    // *** --- 移除這裡的 .padding(.top, 10) --- ***

                // ScrollView 包含主要內容
                ScrollView {
                    VStack(spacing: 25) { // 主要區塊間距
                        // 2. 圖表和主要資訊區域
                        chartSection
                            .padding(.horizontal)
                            .padding(.top, 15) // 與篩選器間距

                        // 3. 細項列表區域
                        detailsSection
                            .padding(.horizontal) // 水平 padding

                    }
                    .padding(.vertical) // 給 ScrollView 內容上下 padding
                }

                // Spacer 將內容推到上方，製造底部空白
                Spacer()
            }
            // *** --- 將頂部間距加在這裡 --- ***
            .padding(.top, 20) // <<< 與 BudgetView/ShoppingListView 一致的頂部間距
            // *** --- 修改背景色 --- ***
            .background(Color.white.ignoresSafeArea()) // <<< 背景改為白色
            .navigationTitle("圖表")
            .navigationBarTitleDisplayMode(.inline) // 確保 header 高度一致
            .navigationBarColor(backgroundColor: Color.brandGold, titleColor: .white) // Header 顏色
            .sheet(isPresented: $showingCategoryManagement) {
                CategoryManagementView(dataManager: dataManager)
            }
            // 確保 Tab 選中時 Navigation Bar 顏色一致
            .onAppear {
                 // 再次套用顏色設定
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.brandGold)
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().tintColor = .white // Back button
            }
        }
    }

    // MARK: - 頂部篩選器
    private var topFilterBar: some View {
        HStack {
            Picker("時間範圍", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .tint(Color.brandGold)

            Spacer()

            Button { print("Filter button tapped") } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        // *** --- 微調垂直 Padding 使其在背景內置中 --- ***
        .padding(.vertical, 10) // <<< 上下各 10，使其垂直居中
    }

    // MARK: - 圖表區域
    private var chartSection: some View {
        HStack(alignment: .top, spacing: 15) {
            // 左側：圖表 + 左上角文字
            VStack(alignment: .leading, spacing: 10) {
                Menu {
                    Button("支出") {}
                    Button("收入") {}
                } label: {
                    HStack(spacing: 4) {
                        Text("支出").font(.subheadline).foregroundColor(.primary)
                        Image(systemName: "chevron.down").font(.caption).foregroundColor(.secondary)
                    }
                }

                // 圓環圖
                Chart(chartData) { data in
                    SectorMark(
                        angle: .value("金額", data.amount),
                        innerRadius: .ratio(0.7),
                        outerRadius: .ratio(0.95)
                    )
                    .foregroundStyle(data.category.color)
                }
                .frame(width: 160, height: 160)
            }

            // 右側：分類管理按鈕 + 最大分類資訊
            VStack(alignment: .leading, spacing: 5) {
                 Button {
                     showingCategoryManagement = true
                 } label: {
                     Text("分類管理")
                         .font(.caption)
                         .foregroundColor(.blue)
                 }
                 .frame(maxWidth: .infinity, alignment: .trailing)

                Spacer(minLength: 30) // 往下推

                if let topData = topCategoryData {
                    Text(topData.category.name)
                        .font(.subheadline)
                    Text(dataManager.formatAmount(topData.amount).replacingOccurrences(of: "NT$", with: "") + " 元")
                        .font(.title3).bold()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                } else {
                     Text("無支出資料")
                         .font(.subheadline)
                         .foregroundColor(.secondary)
                }

                Spacer() // 佔據剩餘空間
            }
             .frame(height: 160) // 與圖表等高
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(3)
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - 細項列表區域
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Menu {
                    if let topData = topCategoryData { Button(topData.category.name) {} }
                } label: {
                    HStack(spacing: 4) {
                        Text(topCategoryData?.category.name ?? "選擇分類")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down").font(.caption).foregroundColor(.secondary)
                    }
                }
                Spacer()
            }

            Text("總支出 \(dataManager.formatAmount(totalExpense))")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)

            // 細項列表卡片
            VStack(spacing: 0) {
                if topCategoryExpenses.isEmpty {
                    Text("此分類無支出記錄")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(topCategoryExpenses.prefix(2)) { expense in
                        ExpenseDetailRow(expense: expense, dataManager: dataManager)
                        if expense.id != topCategoryExpenses.prefix(2).last?.id {
                             Divider().padding(.leading, 15)
                        }
                    }
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(3)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.cardBorder, lineWidth: 1))
        }
    }
}

// MARK: - 細項列表的單行
struct ExpenseDetailRow: View {
    let expense: ExpenseRecord
    let dataManager: ExpenseDataManager

    var body: some View {
        HStack {
            Text(expense.remark).font(.subheadline)
            Spacer()
            Text("共花 " + dataManager.formatAmount(expense.amount).replacingOccurrences(of: "NT$", with: "") + " 元")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// MARK: - 圖表用的資料結構
struct CategoryChartData: Identifiable {
    let id: String
    let category: ExpenseCategory
    let amount: Double
    init(category: ExpenseCategory, amount: Double) {
        self.id = category.id; self.category = category; self.amount = amount
    }
}

// MARK: - Preview
#Preview {
    ExpenseListView(dataManager: ExpenseDataManager())
}
