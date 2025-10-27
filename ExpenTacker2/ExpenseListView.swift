//
//  ExpenseListView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//
//  --- ABSOLUTELY COMPLETE CODE (Oct 27 - All Segment Pickers CornerRadius 3) ---
//

import SwiftUI
import Charts

// Struct to hold category summary data
struct CategorySummary: Identifiable {
    var id: String { category.id } // Use category ID as the unique ID
    let category: ExpenseCategory
    let amount: Double
    
    // Helper to format amount
    var formattedAmount: String {
        "\(String(format: "%.0f", abs(amount))) 元"
    }
}


struct ExpenseListView: View {
    @ObservedObject var dataManager: ExpenseDataManager
    @Environment(\.dismiss) private var dismiss
    
    // --- State Variables ---
    @State private var selectedAnalysisType: AnalysisType = .report // Default to Report view
    @State private var selectedTypeFilter: TransactionType = .all // Default filter to 'All'
    @State private var selectedCategoryId: String? = nil
    @State private var selectedDateFilter: DateFilter = .thisMonth
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    @State private var showingEditExpense = false // Keep state for editing from list
    @State private var editingExpense: ExpenseRecord? = nil
    @State private var selectedChartType: ChartType = .donut // Default to Donut
    // --- End State Variables ---

    // Enum for Report/Chart Toggle
    enum AnalysisType: String, CaseIterable { case report = "報表"; case chart = "圖表" }
    // Enum for Chart Type Toggle
    enum ChartType: String, CaseIterable { case donut = "圓餅圖"; case bar = "直條圖" }
    // Enum for Date Filter Options
    enum DateFilter: String, CaseIterable { case today = "今天"; case thisWeek = "本週"; case thisMonth = "本月"; case custom = "自訂範圍" }
    
    // --- Computed Properties for Filtering ---
    private var availableCategories: [ExpenseCategory] {
        let base: [ExpenseCategory]; if selectedTypeFilter == .all { base = dataManager.categories } else { base = dataManager.getCategories(for: selectedTypeFilter) }; return base.filter { !$0.isDefault }
    }
    private var dateRange: (start: Date, end: Date) {
        let cal = Calendar.current; let now = Date(); switch selectedDateFilter { case .today: let s = cal.startOfDay(for: now); return (s, cal.date(byAdding: .day, value: 1, to: s)!); case .thisWeek: let s = cal.dateInterval(of: .weekOfYear, for: now)?.start ?? now; return (s, cal.date(byAdding: .weekOfYear, value: 1, to: s)!); case .thisMonth: let s = cal.dateInterval(of: .month, for: now)?.start ?? now; return (s, cal.date(byAdding: .month, value: 1, to: s)!); case .custom: let e = cal.startOfDay(for: customEndDate).addingTimeInterval(24*60*60-1); return (cal.startOfDay(for: customStartDate), e) }
    }
    private var filteredExpenses: [ExpenseRecord] {
        let byType: [ExpenseRecord]; switch selectedTypeFilter { case .all: byType = dataManager.expenses; case .income: byType = dataManager.expenses.filter { $0.type == .income }; case .expense: byType = dataManager.expenses.filter { $0.type == .expense } }; let byCat = selectedCategoryId == nil ? byType : byType.filter { $0.categoryId == selectedCategoryId }; let range = dateRange; return byCat.filter { $0.date >= range.start && $0.date <= range.end }.sorted { $0.date > $1.date }
    }
    
    // Computed property to generate category summary
    private var categorySummaryData: [CategorySummary] {
        guard selectedCategoryId == nil else {
            let category = dataManager.getCategory(by: selectedCategoryId)
            let total = filteredExpenses.reduce(0) { $0 + $1.amount }
            if total != 0 { return [CategorySummary(category: category, amount: total)] }
            else { return [] }
        }
        let grouped = Dictionary(grouping: filteredExpenses) { $0.categoryId ?? ExpenseCategory.noneCategory.id }
        let summary = grouped.map { (categoryId, expenses) -> CategorySummary in
            let category = dataManager.getCategory(by: categoryId)
            let totalAmount = expenses.reduce(0) { $0 + $1.amount }
            return CategorySummary(category: category, amount: totalAmount)
        }
        return summary.sorted { abs($0.amount) > abs($1.amount) }
    }
    
    // Total for the filtered type
    private var totalAmountForFiltered: Double {
         if selectedTypeFilter == .all {
             if selectedCategoryId != nil {
                  return filteredExpenses.filter{$0.type == .expense}.reduce(0){$0 + $1.amount}
             } else {
                  return filteredExpenses.filter{$0.type == .expense}.reduce(0){$0 + $1.amount}
             }
         } else {
             return filteredExpenses.reduce(0){$0 + $1.amount}
         }
    }
     private var formattedTotalAmount: String { "\(String(format: "%.0f", abs(totalAmountForFiltered))) 元" }
     
     private var selectedCategoryNameOrTotal: String {
         if let catId = selectedCategoryId, let cat = dataManager.categories.first(where: { $0.id == catId }) {
             return cat.name
         } else {
              switch selectedTypeFilter {
                  case .income: return "總收入"
                  case .expense: return "總支出"
                  case .all: return "總支出"
              }
         }
     }
    // --- End Computed Properties ---

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea() // Main background

            VStack(spacing: 0) { // Main VStack
                
                // MARK: - Custom Header
                ZStack {
                    Color.cardBackground // #2D3044
                    Text("消費分析")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(height: 48)

                // MARK: - Scrollable Content
                ScrollView {
                    VStack(spacing: 20) { // Controls spacing BETWEEN major content blocks

                        // MARK: - Report/Chart Toggle (Custom)
                        HStack(spacing: 5) {
                            Button("報表") { selectedAnalysisType = .report }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(selectedAnalysisType == .report ? Color.gray : Color.black.opacity(0.2)) // Use gray for selected
                                .foregroundColor(.primaryText)
                                .cornerRadius(3) // **[修改]** Corner Radius 3
                            
                            Button("圖表") { selectedAnalysisType = .chart }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(selectedAnalysisType == .chart ? Color.gray : Color.black.opacity(0.2)) // Use gray for selected
                                .foregroundColor(.primaryText)
                                .cornerRadius(3) // **[修改]** Corner Radius 3
                        }
                        .padding(3) // Inner padding
                        .background(Color.black.opacity(0.2)) // Overall background
                        .cornerRadius(3) // **[修改]** Outer Corner Radius 3
                        .frame(width: 322) // Fixed width
                        
                        // MARK: - Filter Section Card
                        filterCardView
                        
                        // MARK: - Conditional Result Area (Report or Chart, Centered, Width 322)
                        HStack { // Center the conditional content
                             Spacer()
                             if selectedAnalysisType == .report {
                                 // Show combined Total + List section
                                 reportResultSection
                             } else {
                                 // Show Chart section ONLY
                                  chartSection
                             }
                             Spacer()
                        } // End Centering HStack

                    } // End ScrollView Content VStack
                    .padding(.top, 25) // Header <-> Toggle Spacing
                    .padding(.bottom, 20) // Padding below content before buttons

                } // End ScrollView
                
                Spacer() // Pushes content up

                // MARK: - Bottom Buttons (Removed Toggle Button)
                HStack(spacing: 20) {
                    // Toggle Button Removed
                    
                    Button("關閉") { dismiss() }
                        .frame(width: 96, height: 60)
                        .background(Color.substrateBackground)
                        .foregroundColor(.primaryText)
                        .cornerRadius(3) // Corner Radius = 3
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.brandGold, lineWidth: 1)) // Match Corner Radius
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity) // Center the remaining button(s)
                .background(Color.pageBackground) // Ensure background matches

            } // End Main VStack
            .background(Color.pageBackground.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationBarHidden(true) // Hide the system navigation bar
        } // End ZStack
        // Sheet for editing expense
        .sheet(isPresented: $showingEditExpense, onDismiss: { editingExpense = nil }) {
             if let expenseToEdit = editingExpense {
                 EditExpenseView(dataManager: dataManager, expense: expenseToEdit)
                     .preferredColorScheme(.dark)
             } else {
                 Text("錯誤：找不到要編輯的資料").padding().preferredColorScheme(.dark)
             }
         }
    } // End body

    // MARK: - Subviews for organization

    // View for the Filter Card (With Custom Segmented Picker)
    private var filterCardView: some View {
        VStack(alignment: .leading, spacing: 15) { // Spacing inside filter card
            
            // Custom Segmented Picker
            HStack {
                Text("請選擇")
                    .foregroundColor(.primaryText.opacity(0.8))
                    .frame(width: 60, alignment: .leading) // Fixed width label
                
                HStack(spacing: 5) {
                    Button("全部") { selectedTypeFilter = .all; selectedCategoryId = nil }
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(selectedTypeFilter == .all ? Color.gray : Color.black.opacity(0.2))
                        .foregroundColor(.primaryText)
                        .cornerRadius(3) // **[修改]** Corner Radius 3
                    Button("收入") { selectedTypeFilter = .income; selectedCategoryId = nil }
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(selectedTypeFilter == .income ? Color.highlightGreen : Color.black.opacity(0.2)) // Green
                        .foregroundColor(.primaryText)
                        .cornerRadius(3) // **[修改]** Corner Radius 3
                    Button("支出") { selectedTypeFilter = .expense; selectedCategoryId = nil }
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(selectedTypeFilter == .expense ? Color.highlightRed : Color.black.opacity(0.2)) // Red
                        .foregroundColor(.primaryText)
                        .cornerRadius(3) // **[修改]** Corner Radius 3
                }
                .padding(3)
                .background(Color.black.opacity(0.2))
                .cornerRadius(3) // **[修改]** Corner Radius 3
            }
            
            // Category Filter
            HStack {
                Text("類型").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                Picker("類型", selection: $selectedCategoryId) { Text("請選擇").tag(String?.none); ForEach(availableCategories) { category in Text(category.name).tag(Optional(category.id)) } }.pickerStyle(MenuPickerStyle()).accentColor(.primaryText.opacity(0.8)).frame(maxWidth: .infinity, alignment: .trailing)
            }
            // Date Filter
            HStack {
                Text("日期").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                Picker("日期", selection: $selectedDateFilter) { ForEach(DateFilter.allCases, id: \.self) { filter in Text(filter.rawValue).tag(filter) } }.pickerStyle(MenuPickerStyle()).accentColor(.primaryText.opacity(0.8)).frame(maxWidth: .infinity, alignment: .trailing)
            }
             if selectedDateFilter == .custom {
                 customDatePickers // Extracted view for custom dates
             }
        } // End Filter Card VStack
        .padding().frame(width: 322).frame(minHeight: 180).background(Color.cardBackground).cornerRadius(3) // Corner Radius = 3
    }

    // View for custom date pickers
    private var customDatePickers: some View {
        VStack {
            DatePicker("開始日期", selection: $customStartDate, displayedComponents: .date).foregroundColor(.primaryText.opacity(0.8))
            DatePicker("結束日期", selection: $customEndDate, displayedComponents: .date).foregroundColor(.primaryText.opacity(0.8))
        }.padding(.top, 10)
    }
    
    // View for Combined Report Result (Total + List)
    private var reportResultSection: some View {
         VStack(spacing: 20) { // Spacing between Total and List
             // totalAmountSection Removed
             expenseListSection // Only show the Category Summary List
         }
         .frame(maxWidth: 322) // Constrain the combined width
    }

    // View for Total Amount Section (No longer used)
    // private var totalAmountSection: some View { ... }
    
    // Extracted view for the *Category Summary* list
    private var expenseListSection: some View {
         VStack { // VStack has the list content
             if categorySummaryData.isEmpty {
                 ExpenseListEmptyView().frame(maxWidth: .infinity) // Use custom empty view
             } else {
                 LazyVStack(spacing: 10) { // Spacing between rows
                     ForEach(categorySummaryData) { summary in
                         CategorySummaryRowView(summary: summary)
                     }
                 } // End LazyVStack
             } // End if/else
         } // End outer VStack
         // Width constraint applied by parent (reportResultSection)
    }

    // Extracted view for the chart
    private var chartSection: some View {
        VStack(spacing: 15) { // Spacing between toggle and chart
            // **[修改]** Custom Toggle for chart type
            HStack(spacing: 5) {
                Button("圓餅圖") { selectedChartType = .donut }
                    .frame(maxWidth: .infinity, minHeight: 32)
                    .background(selectedChartType == .donut ? Color.gray : Color.black.opacity(0.2))
                    .foregroundColor(.primaryText)
                    .cornerRadius(3) // **[修改]** Corner Radius 3
                
                Button("直條圖") { selectedChartType = .bar }
                    .frame(maxWidth: .infinity, minHeight: 32)
                    .background(selectedChartType == .bar ? Color.gray : Color.black.opacity(0.2))
                    .foregroundColor(.primaryText)
                    .cornerRadius(3) // **[修改]** Corner Radius 3
            }
            .padding(3)
            .background(Color.black.opacity(0.2))
            .cornerRadius(3) // **[修改]** Corner Radius 3
            
            // Conditional Chart View
            if categorySummaryData.isEmpty {
                ExpenseListEmptyView().frame(maxWidth: .infinity, minHeight: 300)
            } else {
                if selectedChartType == .donut {
                    donutChartView // Show donut chart
                } else {
                    barChartView // Show bar chart
                }
            }
        }
        .frame(maxWidth: 322) // Apply width constraint
        .padding() // Add internal padding
        .background(Color.cardBackground)
        .cornerRadius(3) // Corner Radius = 3
    }
    
    // Donut Chart View
    private var donutChartView: some View {
        let chartTotal = categorySummaryData.reduce(0) { $0 + abs($1.amount) }
        
        if chartTotal == 0 {
            return AnyView(ExpenseListEmptyView().frame(height: 250))
        } else {
            return AnyView(
                Chart(categorySummaryData) { summary in
                    SectorMark(
                        angle: .value("金額", abs(summary.amount)),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("類別", summary.category.name))
                    .cornerRadius(3) // **[修改]** Corner Radius 3
                    .annotation(position: .overlay) {
                        let percentage = abs(summary.amount) / chartTotal
                        if percentage > 0.05 {
                            Text(percentage, format: .percent.precision(.fractionLength(0)))
                                .font(.caption).fontWeight(.bold)
                                .foregroundColor(.primaryText).shadow(radius: 2)
                        }
                    }
                }
                .chartLegend(position: .bottom, alignment: .center)
                .frame(height: 250)
            )
        }
    }
    
    // Bar Chart View
    private var barChartView: some View {
        let sortedSummary = categorySummaryData.sorted { abs($0.amount) > abs($1.amount) }
        return Chart(sortedSummary) { summary in
            BarMark(
                x: .value("金額", abs(summary.amount)),
                y: .value("類別", summary.category.name)
            )
            .foregroundStyle(by: .value("類別", summary.category.name))
            .annotation(position: .trailing, alignment: .leading) {
                 Text(summary.formattedAmount)
                    .font(.caption2)
                    .foregroundColor(.primaryText.opacity(0.7))
            }
        }
        .chartYAxis { AxisMarks(preset: .automatic, position: .leading) }
        .chartXAxis(.hidden)
        .chartLegend(.hidden)
        .frame(height: CGFloat(categorySummaryData.count) * 40.0)
        .frame(minHeight: 250)
    }
}

// MARK: - CategorySummaryRowView (Internal to this file)
struct CategorySummaryRowView: View {
    let summary: CategorySummary
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: summary.category.type == .income ? "arrow.up" : "arrow.down")
                .font(.headline).foregroundColor(.primaryText)
                .frame(width: 50, height: 50)
                .background(summary.category.color)
                .clipShape(RoundedRectangle(cornerRadius: 3)) // Corner Radius = 3
            
            Text(summary.category.name)
                .font(.subheadline).fontWeight(.medium).foregroundColor(.primaryText)
            Spacer()
            Text(summary.formattedAmount)
                .font(.subheadline).fontWeight(.medium)
                .foregroundColor(.primaryText) // Use primaryText (white)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(3) // Corner Radius = 3
    }
}
 
// MARK: - ExpenseListEmptyView (Internal to this file)
struct ExpenseListEmptyView: View {
     var body: some View {
         VStack(spacing: 16) {
             Image(systemName: "tray").font(.system(size: 48)).foregroundColor(.gray)
             Text("此條件下無記錄").font(.subheadline).foregroundColor(.secondary)
         }
         .padding(.vertical, 50)
     }
 }


// Preview
#Preview {
    ExpenseListView(dataManager: ExpenseDataManager())
        .preferredColorScheme(.dark)
}

// --- Color Extension Placeholder ---
// Assume Color+Extensions.swift exists in your project.
/*
 extension Color { ... }
*/

// --- TransactionCardView Placeholder ---
// This file assumes TransactionCardView is defined elsewhere (e.g., in ContentView.swift)
/*
 struct TransactionCardView: View { ... }
*/
