//
//  Color+Extensions.swift
//  ExpenTacker2
//
//  Created by Gemini on 2025/10/26.
//

import SwiftUI

extension Color {
    
    // 品牌色 (Brand)
    static let brandGold = Color(hex: "#F1B606")
    
    // 語意色 (Semantic)
    // 根據圖一的調色盤，這兩個是文字高光色
    static let highlightGreen = Color(hex: "#6FCF97")
    static let highlightRed = Color(hex: "#EB5757")

    // 中性色 (Neutral) - 用於深色模式
    static let pageBackground = Color(hex: "#1A1D2E")
    static let cardBackground = Color(hex: "#2D3044") // 用於卡片背景 (非主要)
    static let substrateBackground = Color(hex: "#293158") // 用於主要卡片 (襯底)
    static let primaryText = Color(hex: "#FFFFFF")
    
    // Hex 字串轉 Color
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
