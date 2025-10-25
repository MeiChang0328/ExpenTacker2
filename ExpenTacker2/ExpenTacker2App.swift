//
//  ExpenTacker2App.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//

import SwiftUI

@main
struct ExpenTacker2App: App {
    @StateObject private var dataManager = ExpenseDataManager()
    @State private var selectedExpenseId: String?
    @State private var showingExpenseDetail = false
    @State private var showingStatistics = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .onAppear {
                    // 強制重新同步 Widget 數據
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let manager = dataManager
                        manager.forceWidgetSync()
                    }
                }
                .sheet(isPresented: $showingExpenseDetail) {
                    if let expenseId = selectedExpenseId {
                        if let expense = dataManager.expenses.first(where: { $0.id.uuidString == expenseId }) {
                            ExpenseDetailView(dataManager: dataManager, expense: expense)
                        } else {
                            // 調試：找不到對應的 expense
                            VStack(spacing: 20) {
                                Text("找不到消費記錄")
                                    .font(.headline)
                                Text("ID: \(expenseId)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("總共有 \(dataManager.expenses.count) 筆記錄")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("關閉") {
                                    showingExpenseDetail = false
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding()
                        }
                    } else {
                        // 調試：沒有 expenseId
                        VStack(spacing: 20) {
                            Text("沒有選擇的消費記錄")
                                .font(.headline)
                            
                            Button("關閉") {
                                showingExpenseDetail = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                }
                .sheet(isPresented: $showingStatistics) {
                    ExpenseListView(dataManager: dataManager)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "expenTacker" else { return }
        
        let path = url.host ?? ""
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        print("Deep Link - URL: \(url)")
        print("Deep Link - Host: \(path)")
        print("Deep Link - Path Components: \(pathComponents)")
        
        switch path {
        case "expense":
            if let expenseId = pathComponents.first {
                print("Deep Link - Expense ID: \(expenseId)")
                print("Deep Link - Available expenses: \(dataManager.expenses.map { $0.id.uuidString })")
                selectedExpenseId = expenseId
                showingExpenseDetail = true
            } else {
                print("Deep Link - No expense ID found in path components")
            }
        case "statistics":
            showingStatistics = true
        default:
            // 默認行為：打開主應用程式
            print("Deep Link - Default action")
            break
        }
    }
}
