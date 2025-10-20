//
//  BudgetView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/20.
//

import SwiftUI

struct BudgetView: View {
    @ObservedObject var dataManager: ExpenseDataManager
    @State private var selectedTab: BudgetStatus = .inProgress
    @State private var showingAddBudget = false

    enum BudgetStatus: String, CaseIterable {
        case inProgress = "進行中"
        case ended = "已結束"
    }
    
    private var inProgressBudgets: [Budget] {
        dataManager.budgets.filter { !$0.isCompleted }
    }
    
    private var endedBudgets: [Budget] {
        dataManager.budgets.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("預算狀態", selection: $selectedTab) {
                    ForEach(BudgetStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom)
                .tint(Color.brandGold)

                List {
                    if selectedTab == .inProgress {
                        ForEach(inProgressBudgets) { budget in
                            BudgetRowView(budget: budget, dataManager: dataManager)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                    } else {
                        if endedBudgets.isEmpty {
                            Text("沒有已結束的預算").foregroundColor(.secondary).listRowBackground(Color.white)
                        }
                        ForEach(endedBudgets) { budget in
                            EndedBudgetRowView(budget: budget, dataManager: dataManager)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .background(Color.white)
            }
            .padding(.top, 10) // 您可以調整 10 這個數值
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("預算")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBudget = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(dataManager: dataManager)
            }
        }
        .onAppear {
             // 再次套用顏色設定，避免切換 Tab 時顏色變回預設
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

// 進行中的預算行 (線稿 5)
struct BudgetRowView: View {
    let budget: Budget
    @ObservedObject var dataManager: ExpenseDataManager
    
    private var spentAmount: Double {
        dataManager.getSpentAmount(for: budget)
    }
    
    private var progress: Double {
        guard budget.totalAmount > 0 else { return 0 }
        return min(spentAmount / budget.totalAmount, 1.0) // 確保進度條不超過 100%
    }
    
    private var progressPercentage: Int {
        Int(progress * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(budget.name)
                .font(.headline)
            Text(budget.dateRangeString)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: progress)
                .tint(progress > 0.9 ? .red : .blue)
            
            HStack {
                Text(String(format: "NT$%.0f", spentAmount))
                    .font(.subheadline)
                    .foregroundColor(progress > 0.9 ? .red : .primary)
                Spacer()
                Text(String(format: "NT$%.0f", budget.totalAmount))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(progressPercentage)%")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(.vertical, 8)
    }
}

// 已結束的預算行 (線稿 6)
struct EndedBudgetRowView: View {
    let budget: Budget
    @ObservedObject var dataManager: ExpenseDataManager
    
    private var spentAmount: Double {
        dataManager.getSpentAmount(for: budget)
    }
    
    private var difference: Double {
        spentAmount - budget.totalAmount
    }
    
    private var differenceText: String {
        if difference > 0 {
            let percentage = (difference / budget.totalAmount) * 100
            return String(format: "多出 %.0f%% 支出", percentage)
        } else if difference < 0 {
            return String(format: "剩下 NT$%.0f", abs(difference))
        } else {
            return "支出持平"
        }
    }
    
    private var differenceColor: Color {
        difference > 0 ? .red : .green
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(budget.name)
                    .font(.headline)
                Text("預算 \(String(format: "NT$%.0f", budget.totalAmount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(String(format: "實際支出 NT$%.0f", spentAmount))
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(differenceText)
                    .font(.caption)
                    .foregroundColor(differenceColor)
            }
        }
        .padding(.vertical, 8)
        
    }
}

#Preview {
    BudgetView(dataManager: ExpenseDataManager())
}
