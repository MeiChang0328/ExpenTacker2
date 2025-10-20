//
//  AddItemView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/20.
//

import SwiftUI

struct AddItemView: View {
    @ObservedObject var dataManager: ExpenseDataManager
    @Environment(\.dismiss) private var dismiss
    
    let listType: ShoppingListView.ListType
    @State private var name: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("項目名稱", text: $name)
            }
            .navigationTitle(listType == .shopping ? "新增購物項目" : "新增待辦事項")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        if listType == .shopping {
            dataManager.addShoppingItem(name: name)
        } else {
            dataManager.addTodoItem(name: name)
        }
        dismiss()
    }
}

#Preview {
    AddItemView(dataManager: ExpenseDataManager(), listType: .shopping)
}
