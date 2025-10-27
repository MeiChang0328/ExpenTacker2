//
//  EditExpenseView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/3.
//
//  --- REDESIGNED based on Dark Palette & CornerRadius 3 ---
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
    
    // Check if form is valid (amount is not empty)
    private var isFormValid: Bool {
        !amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && Double(amount) != nil
    }

    init(dataManager: ExpenseDataManager, expense: ExpenseRecord) {
        self.dataManager = dataManager
        self.expense = expense
        _amount = State(initialValue: String(format: "%.0f", expense.amount))
        _remark = State(initialValue: expense.remark)
        _selectedType = State(initialValue: expense.type)
        _selectedDate = State(initialValue: expense.date)
        _selectedCategoryId = State(initialValue: expense.categoryId)
        _selectedPhotoData = State(initialValue: dataManager.loadImageData(for: expense.photoFilename))
    }
    
    // Calculated property for available categories
    private var availableCategories: [ExpenseCategory] {
        dataManager.getCategories(for: selectedType).filter { !$0.isDefault }
    }

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea() // Main background

            VStack(spacing: 0) { // Main VStack
                
                // MARK: - Custom Header
                ZStack {
                    Color.cardBackground // #2D3044
                    
                    Text("編輯明細") // Title
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .bold))
                    
                    HStack {
                        Button("取消") { dismiss() }
                            .foregroundColor(.primaryText.opacity(0.8))
                        Spacer()
                        Button("儲存") { save() }
                            .foregroundColor(isFormValid ? .brandGold : .gray) // Use gold, disable if invalid
                            .disabled(!isFormValid)
                    }
                    .padding(.horizontal)
                }
                .frame(height: 48) // Fixed header height

                // MARK: - Scrollable Content Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) { // Spacing between sections

                        // MARK: - Transaction Info Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("交易資訊")
                                .font(.headline)
                                .foregroundColor(.primaryText.opacity(0.9))
                                .padding(.horizontal) // Align title

                            transactionInfoCard
                        }
                        
                        // MARK: - Photo Section
                        VStack(alignment: .leading, spacing: 20) {
                             Text("照片（可選）")
                                .font(.headline)
                                .foregroundColor(.primaryText.opacity(0.9))
                                .padding(.horizontal)

                             photoCard
                         }
                        
                    } // End ScrollView Content VStack
                    .padding(.horizontal) // Add horizontal padding to the ScrollView content VStack
                    .padding(.vertical, 20) // Add padding above/below scrollable content
                } // End ScrollView
                
                // No bottom buttons, actions are in the header
                
            } // End Main VStack
            .background(Color.pageBackground.ignoresSafeArea())
            .preferredColorScheme(.dark)
        } // End ZStack
    } // End body
    
    // MARK: - Transaction Info Card View
    private var transactionInfoCard: some View {
        VStack(alignment: .leading, spacing: 15) { // Spacing between rows
            
            // Type Row (Custom Picker)
            HStack {
                Text("類型")
                    .foregroundColor(.primaryText.opacity(0.8))
                    .frame(width: 60, alignment: .leading)
                
                HStack(spacing: 5) {
                    Button("收入") { selectedType = .income; selectedCategoryId = nil }
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(selectedType == .income ? Color.highlightGreen : Color.black.opacity(0.2))
                        .foregroundColor(.primaryText)
                        .cornerRadius(3) // Corner Radius 3

                    Button("支出") { selectedType = .expense; selectedCategoryId = nil }
                        .frame(maxWidth: .infinity, minHeight: 32)
                        .background(selectedType == .expense ? Color.highlightRed : Color.black.opacity(0.2))
                        .foregroundColor(.primaryText)
                        .cornerRadius(3) // Corner Radius 3
                }
                .padding(3)
                .background(Color.black.opacity(0.2))
                .cornerRadius(3) // Corner Radius 3
            }
            .frame(height: 60)
            .padding(.horizontal)

            // Amount Row
            HStack {
                Text("金額").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                TextField("", text: $amount, prompt: Text("請輸入金額").foregroundColor(.gray.opacity(0.5)))
                    .foregroundColor(.primaryText).keyboardType(.decimalPad).textFieldStyle(.plain)
                    .padding(8).background(Color.black.opacity(0.2)).cornerRadius(3)
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            }.frame(height: 60).padding(.horizontal)

            // Remark (Item Name) Row
            HStack {
                Text("備註") // Label "備註" matches original code
                    .foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                TextField("", text: $remark, prompt: Text("請輸入備註").foregroundColor(.gray.opacity(0.5)))
                    .foregroundColor(.primaryText).textFieldStyle(.plain)
                    .padding(8).background(Color.black.opacity(0.2)).cornerRadius(3)
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            }.frame(height: 60).padding(.horizontal)

            // Date Row
            HStack {
                Text("日期").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden().accentColor(.brandGold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(height: 60).padding(.horizontal)

            // Category Picker Row
            HStack {
                Text("分類").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                Picker("分類", selection: $selectedCategoryId) {
                    Text("無分類").tag(String?.none) // Use "無分類" as placeholder
                    ForEach(availableCategories) { category in Text(category.name).tag(Optional(category.id)) }
                }.pickerStyle(MenuPickerStyle()).accentColor(.primaryText.opacity(0.8)).frame(maxWidth: .infinity, alignment: .trailing)
            }.frame(height: 60).padding(.horizontal)

        } // End Card VStack
        .padding(.vertical, 15)
        .frame(width: 322) // Fixed width
        .background(Color.cardBackground) // **[修改]** Use cardBackground
        .cornerRadius(3) // Card Corner Radius 3
        // No left border needed for this view based on AddExpenseView
    }
    
    // MARK: - Photo Card View
    private var photoCard: some View {
         HStack(spacing: 15) {
             // Placeholder Image / Selected Image Preview
             ZStack {
                 // Placeholder
                 Image(systemName: "xmark")
                     .font(.largeTitle)
                     .foregroundColor(.secondary)
                     .frame(width: 80, height: 80)
                     .background(Color.gray.opacity(0.2))
                     .clipShape(RoundedRectangle(cornerRadius: 3))

                 // Selected Image
                 if let photoData = selectedPhotoData, let uiImage = UIImage(data: photoData) {
                     Image(uiImage: uiImage)
                         .resizable().scaledToFill()
                         .frame(width: 80, height: 80).clipShape(RoundedRectangle(cornerRadius: 3)).clipped()
                 }
             }

             // Photos Picker Button/Text
             PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                 Text("選擇照片").foregroundColor(.blue)
             }
             .onChange(of: selectedPhotoItem) { _, newItem in
                 Task {
                     if let data = try? await newItem?.loadTransferable(type: Data.self) {
                         selectedPhotoData = data
                     } else if newItem == nil {
                         // Don't clear data if picker was just dismissed, only if selection is cleared
                     } else {
                         selectedPhotoData = nil // Clear on error
                     }
                 }
             }
             Spacer()
             // Remove Button
             if selectedPhotoData != nil {
                 Button(role: .destructive) {
                     selectedPhotoData = nil; selectedPhotoItem = nil
                 } label: { Image(systemName: "trash") }
                 .padding(.leading)
             }
         }
         .padding()
         .background(Color.cardBackground) // **[修改]** Use cardBackground
         .cornerRadius(3) // Corner Radius 3
         .frame(width: 322) // Match transaction card width
    }

    // MARK: - Save Expense Function
    private func save() {
        guard isFormValid else { return }
        
        var updated = expense
        updated.amount = Double(amount) ?? expense.amount
        updated.remark = remark.isEmpty ? "無備註" : remark // Ensure remark isn't empty
        updated.type = selectedType
        updated.date = selectedDate
        updated.categoryId = selectedCategoryId
        
        // Handle photo saving logic
        if let data = selectedPhotoData {
            // Check if data is new data (different from original)
            // This simple check works if original was nil or data differs
            if data != dataManager.loadImageData(for: expense.photoFilename) {
                // Delete old photo if it exists
                if let oldFilename = expense.photoFilename {
                    dataManager.deleteImage(filename: oldFilename)
                }
                // Save new photo
                updated.photoFilename = dataManager.saveImageData(data)
            }
            // If data is the same, do nothing
        } else {
            // Photo data is nil (was removed or never existed)
            // Delete old photo if it existed
            if let oldFilename = expense.photoFilename {
                dataManager.deleteImage(filename: oldFilename)
            }
            updated.photoFilename = nil
        }
        
        dataManager.updateExpense(updated)
        dismiss()
    }
}

// Preview
#Preview {
    EditExpenseView(dataManager: ExpenseDataManager(), expense: ExpenseRecord(remark: "午餐", amount: 100, date: Date(), type: .expense, color: .red))
        .preferredColorScheme(.dark)
}

// --- Color Extension Placeholder ---
// Assume Color+Extensions.swift exists in your project.
/*
 extension Color {
     static let pageBackground = Color(hex: "#1A1D2E")
     static let cardBackground = Color(hex: "#2D3044") // 卡片 header / 卡片背景-非主要
     static let substrateBackground = Color(hex: "#293158") // 襯底
     static let primaryText = Color(hex: "#FFFFFF")
     static let brandGold = Color(hex: "#F1B606")
     static let highlightGreen = Color(hex: "#6FCF97")
     static let highlightRed = Color(hex: "#EB5757")
     init(hex: String) { ... }
 }
*/
