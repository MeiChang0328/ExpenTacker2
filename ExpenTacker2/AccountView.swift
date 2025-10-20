//
//  AccountView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/20.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var dataManager: ExpenseDataManager
    @State private var showingCategories = false
    
    // 為了 "分類管理" 線稿中的網格圖示 (雖然我們使用列表)
    // 這裡我們只是建立一個範例網格。
    private let gridItems: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    var body: some View {
        NavigationView {
            Form {
                Section("設定") {
                    Button {
                        showingCategories = true
                    } label: {
                        Label("分類管理", systemImage: "rectangle.3.group.fill")
                    }
                }
                
                // 這裡是線稿中 "分類管理" 網格的 "範例" 實現
                // 如果您想將 "分類管理" 頁面改成網格，
                // 您需要修改 CategoryManagementView.swift
                Section("分類預覽 (範例)") {
                    LazyVGrid(columns: gridItems, spacing: 20) {
                        ForEach(dataManager.categories.filter { !$0.isDefault }.prefix(8)) { category in
                            VStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 44, height: 44)
                                Text(category.name)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("帳戶")
            .sheet(isPresented: $showingCategories) {
                // 打開您現有的分類管理視圖
                CategoryManagementView(dataManager: dataManager)
            }
        }
    }
}

#Preview {
    AccountView(dataManager: ExpenseDataManager())
}
