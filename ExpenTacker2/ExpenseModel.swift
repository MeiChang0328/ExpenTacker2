//
//  ExpenseModel.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//

import SwiftUI
import Foundation

// 交易類型枚舉
enum TransactionType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
    case all = "all"
     
    var displayName: String {
        switch self {
        case .income:
            return "收入"
        case .expense:
            return "支出"
        case .all:
            return "全部"
        }
    }
     
    var iconName: String {
        switch self {
        case .income:
            return "plus"
        case .expense:
            return "minus"
        case .all:
            return "circle.fill"
        }
    }
}

// 記帳記錄模型
struct ExpenseRecord: Identifiable, Codable {
    let id: String // 改為 String 以便儲存 UUID
    var remark: String
    var amount: Double
    var date: Date
    var type: TransactionType
    var color: Color           // 儲存顏色
    var categoryId: String?
    var photoFilename: String?
     
    init(id: String = UUID().uuidString, remark: String, amount: Double, date: Date = Date(), type: TransactionType, color: Color = .blue, categoryId: String? = nil, photoFilename: String? = nil) {
        self.id = id
        self.remark = remark
        self.amount = amount
        self.date = date
        self.type = type
        self.color = color
        self.categoryId = categoryId
        self.photoFilename = photoFilename
    }
     
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TWD"
        formatter.maximumFractionDigits = 0
         
        let prefix = type == .expense ? "-" : "+"
        let formattedNumber = formatter.string(from: NSNumber(value: abs(amount))) ?? "NT$0"
         
        return prefix + formattedNumber
    }
     
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

// Color 的 Codable 擴展 (不變)
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
     
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
         
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
     
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
         
        guard let components = UIColor(self).cgColor.components else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Cannot get color components"))
        }
         
        try container.encode(Double(components[0]), forKey: .red)
        try container.encode(Double(components[1]), forKey: .green)
        try container.encode(Double(components[2]), forKey: .blue)
        try container.encode(Double(components.count > 3 ? components[3] : 1.0), forKey: .alpha)
    }
}

// 分類模型 (*** 重大修改 ***)
struct ExpenseCategory: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var color: Color
    var type: TransactionType
    var iconName: String      // *** 新增圖示名稱 ***
    var isDefault: Bool = false
     
    init(id: String = UUID().uuidString, name: String, color: Color, type: TransactionType, iconName: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.color = color
        self.type = type
        self.iconName = iconName // *** 新增 ***
        self.isDefault = isDefault
    }
     
    // 預設的none分類
    static let noneCategory = ExpenseCategory(
        id: "none",
        name: "無分類",
        color: .gray,
        type: .all,
        iconName: "questionmark.circle",
        isDefault: true
    )
     
    // 預設收入分類 (*** 加入 iconName ***)
    static let defaultIncomeCategories = [
        ExpenseCategory(name: "薪水", color: .green, type: .income, iconName: "banknote.fill"),
        ExpenseCategory(name: "副業", color: .blue, type: .income, iconName: "dollarsign.circle.fill"),
        ExpenseCategory(name: "投資", color: .purple, type: .income, iconName: "chart.line.uptrend.xyaxis"),
        ExpenseCategory(name: "其他", color: .mint, type: .income, iconName: "ellipsis")
    ]
     
    // 預設支出分類 (*** 加入 iconName, 符合線稿 16-1, 16-2 ***)
    static let defaultExpenseCategories = [
        ExpenseCategory(name: "餐飲", color: .red, type: .expense, iconName: "fork.knife"),
        ExpenseCategory(name: "交通", color: .orange, type: .expense, iconName: "bus.fill"),
        ExpenseCategory(name: "購物", color: .pink, type: .expense, iconName: "cart.fill"),
        ExpenseCategory(name: "娛樂", color: .yellow, type: .expense, iconName: "play.tv.fill"),
        ExpenseCategory(name: "居家", color: .brown, type: .expense, iconName: "house.fill"),
        ExpenseCategory(name: "其他", color: .gray, type: .expense, iconName: "ellipsis")
    ]
}
