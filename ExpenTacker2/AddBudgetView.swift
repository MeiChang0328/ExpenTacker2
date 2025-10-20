//
//  AddBudgetView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/20.
//

import SwiftUI

struct AddBudgetView: View {
    @ObservedObject var dataManager: ExpenseDataManager
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var totalAmount: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    private var isFormValid: Bool {
        !name.isEmpty && Double(totalAmount) != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("預算資訊") {
                    TextField("預算名稱 (例如: 旅遊)", text: $name)
                    TextField("總金額", text: $totalAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section("日期範圍") {
                    DatePicker("開始日期", selection: $startDate, displayedComponents: .date)
                    DatePicker("結束日期", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("新增預算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveBudget()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let amount = Double(totalAmount) else { return }
        
        let newBudget = Budget(
            name: name,
            totalAmount: amount,
            startDate: startDate,
            endDate: endDate
        )
        dataManager.addBudget(newBudget)
        dismiss()
    }
}

#Preview {
    AddBudgetView(dataManager: ExpenseDataManager())
}
