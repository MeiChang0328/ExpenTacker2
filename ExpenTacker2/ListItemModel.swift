
//
//  ListItemModel.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/20.
//

import Foundation

// 購物清單項目
struct ShoppingItem: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var isCompleted: Bool
    
    init(id: String = UUID().uuidString, name: String, isCompleted: Bool) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
    }
}

// 待辦事項項目
struct TodoItem: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var isCompleted: Bool
    
    init(id: String = UUID().uuidString, name: String, isCompleted: Bool) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
    }
}
