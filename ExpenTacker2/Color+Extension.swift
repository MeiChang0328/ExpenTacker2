// ---- Color+Extension.swift (或放在任一檔案頂部) ----
import SwiftUI

extension Color {
    init(hex: String) {
        // ... (hex 初始化方法不變) ...
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
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }

    // *** --- 修改這一行 --- ***
    // 定義品牌色，使用新的 Hex Code #EAC100
    static let brandGold = Color(hex: "EAC100")
    // *** --- 修改結束 --- ***

    // 定義一個淺灰色，用於白色背景上的卡片邊框或陰影 (不變)
    static let cardBackground = Color.white
    static let cardShadow = Color.black.opacity(0.08)
    static let cardBorder = Color.gray.opacity(0.2)
}
// ---- 顏色定義結束 ----
