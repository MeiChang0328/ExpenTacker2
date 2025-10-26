//
//  AddExpenseView.swift
//  ExpenTacker
//
//  Created by 張郁眉 on 2025/10/1.
//
//  --- FINAL VERSION (Oct 27 - Final Layout Spacing & Button Style) ---
//

import SwiftUI
import PhotosUI

struct AddExpenseView: View {
    // State variables and Environment properties
    let dataManager: ExpenseDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var remark = "" // Internal name for "項目名稱"
    @State private var selectedType: TransactionType = .expense
    @State private var selectedDate = Date()
    @State private var selectedCategoryId: String? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil
    
    // Calculated property for available categories
    private var availableCategories: [ExpenseCategory] {
        dataManager.getCategories(for: selectedType).filter { !$0.isDefault }
    }

    var body: some View {
        // Main container using ZStack to layer background and content
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            VStack(spacing: 0) { // Main VStack controlling vertical layout
                
                // MARK: - Custom Header
                ZStack {
                    Color.cardBackground // Header uses cardBackground #2D3044
                    Text("新增紀錄")
                        .foregroundColor(.primaryText) // White #FFFFFF
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(height: 48) // Fixed header height

                // MARK: - Scrollable Form Content
                ScrollView {
                    // Set spacing to 25 for inter-section spacing
                    VStack(alignment: .leading, spacing: 25) { // Add alignment: .leading

                        // MARK: - Transaction Info Section
                        // Set spacing to 20 for title <-> card
                        VStack(alignment: .leading, spacing: 20) { // Keep leading alignment
                            Text("交易資訊")
                                .font(.headline) // Or adjust size as needed
                                .foregroundColor(.primaryText.opacity(0.9))
                                .padding(.horizontal) // Align title with card edge

                            // The Card itself - Now with updated rows inside
                            transactionInfoCard
                        }
                        // Padding handled by outer VStack

                        // MARK: - Photo Section
                        // Set spacing to 20 for title <-> card
                        VStack(alignment: .leading, spacing: 20) { // Keep leading alignment
                             Text("照片")
                                .font(.headline)
                                .foregroundColor(.primaryText.opacity(0.9))
                                .padding(.horizontal)

                             photoCard // Extracted photo section content
                         }
                         // Padding handled by outer VStack
                        
                    } // End ScrollView Content VStack
                    .padding(.horizontal) // Add horizontal padding to the ScrollView content VStack
                    .padding(.vertical, 20) // Add padding above/below scrollable content
                } // End ScrollView

                // MARK: - Bottom Buttons (Updated Style)
                HStack(spacing: 20) {
                    Button("關閉") { dismiss() }
                        .frame(width: 96, height: 60)
                        // Use substrate background
                        .background(Color.substrateBackground)
                        .foregroundColor(.primaryText) // Keep white text
                        .cornerRadius(8)
                        // Add gold border overlay
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brandGold, lineWidth: 1) // Gold border, 1px width
                        )

                    Button("儲存") { saveExpense() }
                        .frame(width: 96, height: 60)
                        // Use substrate background
                        .background(Color.substrateBackground)
                        .foregroundColor(.primaryText) // Keep white text
                        .cornerRadius(8)
                        // Add gold border overlay
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brandGold, lineWidth: 1) // Gold border, 1px width
                        )
                        .disabled(amount.isEmpty || Double(amount) == nil)
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity) // Center buttons
                .background(Color.pageBackground)

            } // End Main VStack
            .background(Color.pageBackground.ignoresSafeArea())
            .preferredColorScheme(.dark)
        } // End ZStack
    } // End body
    
    // MARK: - Transaction Info Card View (Updated Row Styles)
    private var transactionInfoCard: some View {
        // Adjusted spacing, rows have fixed height now
        VStack(alignment: .leading, spacing: 15) { // Spacing between rows
            
            // Income/Expense Picker Row
            HStack {
                Text("請選擇").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                Picker("類型", selection: $selectedType) {
                    Text("收入").tag(TransactionType.income)
                    Text("支出").tag(TransactionType.expense)
                }.pickerStyle(SegmentedPickerStyle()).onChange(of: selectedType) { _, _ in selectedCategoryId = nil }
            }.frame(height: 60).padding(.horizontal)
            // Category Picker Row
            HStack {
                Text("類型").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                Picker("類型", selection: $selectedCategoryId) {
                    Text("請選擇").tag(String?.none)
                    ForEach(availableCategories) { category in Text(category.name).tag(Optional(category.id)) }
                }.pickerStyle(MenuPickerStyle()).accentColor(.primaryText.opacity(0.8)).frame(maxWidth: .infinity, alignment: .trailing)
            }.frame(height: 60).padding(.horizontal)
            // Item Name Row
            HStack {
                Text("項目名稱").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                TextField("", text: $remark, prompt: Text("請輸入項目名稱").foregroundColor(.gray.opacity(0.5))).foregroundColor(.primaryText).textFieldStyle(.plain).padding(.vertical, 8).padding(.horizontal, 5).overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            }.frame(height: 60).padding(.horizontal)
            // Amount Row
            HStack {
                Text("金額").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                TextField("", text: $amount, prompt: Text("請輸入金額").foregroundColor(.gray.opacity(0.5))).foregroundColor(.primaryText).keyboardType(.decimalPad).textFieldStyle(.plain).padding(.vertical, 8).padding(.horizontal, 5).overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5), lineWidth: 1))
            }.frame(height: 60).padding(.horizontal)
            // Date Row
            HStack {
                Text("日期").foregroundColor(.primaryText.opacity(0.8)).frame(width: 60, alignment: .leading)
                DatePicker("", selection: $selectedDate, displayedComponents: .date).labelsHidden().accentColor(.brandGold).padding(.vertical, 8).padding(.horizontal, 5).overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5), lineWidth: 1)).frame(maxWidth: .infinity, alignment: .leading)
            }.frame(height: 60).padding(.horizontal)

        } // End Card VStack
        .padding(.vertical, 15)
        .frame(width: 350) // Keep width fixed
        .background(Color.substrateBackground)
        .cornerRadius(4)
        .overlay( // Keep left border
            HStack { Rectangle().fill(Color.brandGold).frame(width: 3); Spacer() }
        )
        .clipped()
    }
    
    // MARK: - Photo Card View
    private var photoCard: some View {
         HStack(spacing: 15) {
             Image(systemName: "xmark")
                 .font(.largeTitle)
                 .foregroundColor(.secondary)
                 .frame(width: 80, height: 80)
                 .background(Color.gray.opacity(0.2))
                 .clipShape(RoundedRectangle(cornerRadius: 8))
                 .overlay {
                     if let photoData = selectedPhotoData, let uiImage = UIImage(data: photoData) {
                         Image(uiImage: uiImage)
                             .resizable().scaledToFill()
                             .frame(width: 80, height: 80).clipShape(RoundedRectangle(cornerRadius: 8)).clipped()
                     }
                 }

             PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                 Text("選擇照片").foregroundColor(.blue)
             }
             .onChange(of: selectedPhotoItem) { _, newItem in
                 Task {
                     if let data = try? await newItem?.loadTransferable(type: Data.self) {
                         selectedPhotoData = data
                     } else {
                         selectedPhotoData = nil
                     }
                 }
             }
             Spacer()
             if selectedPhotoData != nil {
                 Button(role: .destructive) {
                     selectedPhotoData = nil; selectedPhotoItem = nil
                 } label: { Image(systemName: "trash") }
                 .padding(.leading)
             }
         }
         .padding()
         .background(Color.substrateBackground.opacity(0.5))
         .cornerRadius(4)
         .frame(width: 350) // Match transaction card width
    }

    // MARK: - Save Expense Function (Primary Definition)
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        let category = dataManager.getCategory(by: selectedCategoryId)
        var photoFilename: String? = nil
        
        if let photoData = selectedPhotoData {
            photoFilename = dataManager.saveImageData(photoData)
        }
        
        let newExpense = ExpenseRecord(
            remark: remark.isEmpty ? "無備註" : remark,
            amount: amountValue,
            date: selectedDate,
            type: selectedType,
            color: category.color,
            categoryId: selectedCategoryId,
            photoFilename: photoFilename
        )
        
        dataManager.addExpense(newExpense)
        dismiss()
    }
}

// MARK: - Fileprivate Helper Extensions (Photo Helpers Only)
fileprivate extension AddExpenseView {
    // Make overlay logic reusable
    @ViewBuilder func photoOverlay() -> some View {
        if let photoData = selectedPhotoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable().scaledToFill()
                .frame(width: 80, height: 80).clipShape(RoundedRectangle(cornerRadius: 8)).clipped()
        }
    }
    
    // Make task logic reusable
    func loadPhotoData(newItem: PhotosPickerItem?) {
         Task {
             if let data = try? await newItem?.loadTransferable(type: Data.self) {
                 selectedPhotoData = data
             } else {
                 selectedPhotoData = nil
             }
         }
    }

    // Make remove photo logic reusable
    func removePhoto() {
        selectedPhotoData = nil
        selectedPhotoItem = nil
    }
}

// Preview
#Preview {
    AddExpenseView(dataManager: ExpenseDataManager())
        .preferredColorScheme(.dark)
}

// --- Color Extension Placeholder (Assume exists in Color+Extensions.swift) ---
// Ensure Color+Extensions.swift is in your project and contains the necessary definitions.
/*
 extension Color {
     static let pageBackground = Color(hex: "#1A1D2E")
     static let cardBackground = Color(hex: "#2D3044")
     static let substrateBackground = Color(hex: "#293158")
     static let primaryText = Color(hex: "#FFFFFF")
     static let brandGold = Color(hex: "#F1B606")
     static let highlightGreen = Color(hex: "#6FCF97")
     static let highlightRed = Color(hex: "#EB5757")

     init(hex: String) { ... }
 }
*/
