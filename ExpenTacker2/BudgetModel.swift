//
//  BudgetModel.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/20.
//

import Foundation

struct Budget: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var totalAmount: Double
    var startDate: Date
    var endDate: Date
    
    init(id: String = UUID().uuidString, name: String, totalAmount: Double, startDate: Date, endDate: Date) {
        self.id = id
        self.name = name
        self.totalAmount = totalAmount
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // 判斷預算是否已結束
    var isCompleted: Bool {
        return Date() > endDate
    }
    
    // 格式化日期範圍
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
