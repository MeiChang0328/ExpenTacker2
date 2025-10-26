//
//  EditExpenseView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/3.
//

import SwiftUI
import PhotosUI

struct EditExpenseView: View {
    let dataManager: ExpenseDataManager
    let expense: ExpenseRecord
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String
    @State private var remark: String
    @State private var selectedType: TransactionType
    @State private var selectedDate: Date
    @State private var selectedCategoryId: String?
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil
    
    init(dataManager: ExpenseDataManager, expense: ExpenseRecord) {
        self.dataManager = dataManager
        self.expense = expense
        _amount = State(initialValue: String(format: "%.0f", expense.amount))
        _remark = State(initialValue: expense.remark)
        _selectedType = State(initialValue: expense.type)
        _selectedDate = State(initialValue: expense.date)
        _selectedCategoryId = State(initialValue: expense.categoryId)
        // **[修復 Bug]** 初始化時載入現有照片
        _selectedPhotoData = State(initialValue: dataManager.loadImageData(for: expense.photoFilename))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("交易資訊") {
                    HStack {
                        Text("類型")
                        Spacer()
                        Picker("類型", selection: $selectedType) {
                            Text("收入").tag(TransactionType.income)
                            Text("支出").tag(TransactionType.expense)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 150)
                        .onChange(of: selectedType) { _, _ in
                            selectedCategoryId = nil
                        }
                    }
                    HStack {
                        Text("金額")
                        TextField("請輸入金額", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("備註")
                        TextField("請輸入備註", text: $remark)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    DatePicker("日期", selection: $selectedDate, displayedComponents: .date)
                }
                Section("分類選擇") {
                    let availableCategories = dataManager.getCategories(for: selectedType).filter { !$0.isDefault }
                    Picker("分類", selection: $selectedCategoryId) {
                        HStack {
                            Circle().fill(Color.gray).frame(width: 12, height: 12)
                            Text("無分類")
                        }
                        .tag(String?.none)
                        ForEach(availableCategories) { category in
                            HStack {
                                Circle().fill(category.color).frame(width: 12, height: 12)
                                Text(category.name)
                            }
                            .tag(Optional(category.id))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Section("照片（可選）") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(.blue)
                            Text(selectedPhotoData == nil ? "選擇照片" : "已選擇照片") // **[修改]** 簡化邏輯
                                .foregroundColor(selectedPhotoData == nil ? .blue : .green)
                        }
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedPhotoData = data
                            }
                        }
                    }
                    
                    // **[新增]** 顯示照片預覽 (無論是剛選的還是舊有的)
                    if let photoData = selectedPhotoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                        
                        Button(role: .destructive) {
                            selectedPhotoData = nil
                            selectedPhotoItem = nil
                        } label: {
                            Label("移除照片", systemImage: "trash")
                        }
                    }
                }
            }
            // **[新增]** 設定背景色
            .background(Color.pageBackground.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            //
            .navigationTitle("編輯明細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") { save() }
                        .disabled(amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private func save() {
        var updated = expense
        updated.amount = Double(amount) ?? expense.amount
        updated.remark = remark
        updated.type = selectedType
        updated.date = selectedDate
        updated.categoryId = selectedCategoryId
        
        // **[修復]** 完整的照片儲存/刪除邏輯
        if let data = selectedPhotoData {
            // 情況 1: 有照片資料 (新選的或舊有的)
            // 刪除舊照片 (如果檔名不同)
            if let oldFilename = expense.photoFilename, updated.photoFilename != oldFilename {
                dataManager.deleteImage(filename: oldFilename)
            }
            // 儲存新照片 (saveImageData 會給新檔名)
            updated.photoFilename = dataManager.saveImageData(data)
        } else {
            // 情況 2: 照片資料是 nil (被用戶移除)
            // 刪除舊照片 (如果存在)
            if let oldFilename = expense.photoFilename {
                dataManager.deleteImage(filename: oldFilename)
            }
            updated.photoFilename = nil
        }
        
        dataManager.updateExpense(updated)
        dismiss()
    }
}

#Preview {
    EditExpenseView(dataManager: ExpenseDataManager(), expense: ExpenseRecord(remark: "午餐", amount: 100, date: Date(), type: .expense, color: .red))
        .preferredColorScheme(ColorScheme.dark) // **[修復]**
}
