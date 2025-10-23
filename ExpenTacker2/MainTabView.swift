//
//  MainTabView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/20.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = ExpenseDataManager()

    init() {
        // --- Tab Bar 外觀設定 (品牌色等) ---
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.brandGold) // #EAC100
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.brandGold)] // #EAC100
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        // --- 設定結束 ---
    }

    var body: some View {
        TabView {
            // 分頁 1: 主畫面
            ContentView(dataManager: dataManager)
                .tabItem {
                    Label("主畫面", systemImage: "house.fill")
                }

            // 分頁 2: 圖表
            ExpenseListView(dataManager: dataManager)
                .tabItem {
                    // *** 圖示修正：改為 chart.bar.xaxis ***
                    Label("圖表", systemImage: "chart.bar.xaxis")
                }

            // 分頁 3: 清單
            ShoppingListView(dataManager: dataManager)
                .tabItem {
                    Label("清單", systemImage: "list.bullet.clipboard.fill")
                }

            // 分頁 4: 預算
            BudgetView(dataManager: dataManager)
                .tabItem {
                    Label("預算", systemImage: "bag.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
