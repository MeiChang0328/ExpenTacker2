//
//  ExpenseDataManager.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/1.
//

import Foundation
import SwiftUI
import Combine
import WidgetKit

class ExpenseDataManager: ObservableObject {
    @Published var expenses: [ExpenseRecord] = []
    @Published var categories: [ExpenseCategory] = []
    @Published var budgets: [Budget] = []
    @Published var shoppingItems: [ShoppingItem] = []
    @Published var todoItems: [TodoItem] = []
     
    private let fileManager = FileManager.default
    private let expensesFileName = "expenses.json"
    private let categoriesFileName = "categories.json"
    private let budgetsFileName = "budgets.json"
    private let shoppingListFileName = "shopping.json"
    private let todoListFileName = "todo.json"
    private let imagesDirectoryName = "ExpenseImages"
     
    // --- File URLs ---
    private var expensesFileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(expensesFileName)
    }
    private var categoriesFileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(categoriesFileName)
    }
    private var budgetsFileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(budgetsFileName)
    }
    private var shoppingListFileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(shoppingListFileName)
    }
    private var todoListFileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(todoListFileName)
    }
    private var imagesDirectoryURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = documentsPath.appendingPathComponent(imagesDirectoryName, isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
     
    init() {
        // *** 修改：檢查並建立假資料 ***
        setupDummyDataIfNeeded()
        
        // 載入所有資料
        loadCategories()
        loadExpenses()
        loadBudgets()
        loadShoppingItems()
        loadTodoItems()
    }
    
    // MARK: - *** 建立假資料 (核心) ***
    private func setupDummyDataIfNeeded() {
        // 檢查記帳記錄檔是否存在，如果不存在，才建立所有假資料
        guard !fileManager.fileExists(atPath: expensesFileURL.path) else {
            print("資料檔已存在，跳過建立假資料。")
            return
        }
        
        print("偵測到第一次啟動，正在建立假資料...")
        
        // 1. 建立假分類 (會自動儲存)
        createDefaultCategories()
        
        // 獲取剛建立的分類 ID
        let catDining = categories.first(where: { $0.name == "餐飲" })!
        let catTransport = categories.first(where: { $0.name == "交通" })!
        let catShopping = categories.first(where: { $0.name == "購物" })!
        
        // 2. 建立假交易紀錄 (符合線稿 16-1, 16-2)
        let dummyExpenses = [
            ExpenseRecord(remark: "慶生聚餐", amount: 80, date: Date().addingTimeInterval(-86400 * 1), type: .expense, color: catDining.color, categoryId: catDining.id),
            ExpenseRecord(remark: "七海拉麵", amount: 120, date: Date().addingTimeInterval(-86400 * 2), type: .expense, color: catDining.color, categoryId: catDining.id),
            ExpenseRecord(remark: "法式焗飯", amount: 300, date: Date().addingTimeInterval(-86400 * 3), type: .expense, color: catDining.color, categoryId: catDining.id),
            ExpenseRecord(remark: "老媽激動鍋", amount: 1000, date: Date().addingTimeInterval(-86400 * 4), type: .expense, color: catDining.color, categoryId: catDining.id),
            ExpenseRecord(remark: "計程車", amount: 120, date: Date().addingTimeInterval(-86400 * 5), type: .expense, color: catTransport.color, categoryId: catTransport.id),
            ExpenseRecord(remark: "捷運", amount: 170, date: Date().addingTimeInterval(-86400 * 6), type: .expense, color: catTransport.color, categoryId: catTransport.id),
            ExpenseRecord(remark: "買衣服", amount: 4000, date: Date().addingTimeInterval(-86400 * 1), type: .expense, color: catShopping.color, categoryId: catShopping.id)
        ]
        self.expenses = dummyExpenses
        saveExpenses() // 儲存假資料
        
        // 3. 建立假預算 (符合線稿 16-5, 16-6)
        // let catClothes = categories.first(where: { $0.name == "購物" })! // 假設衣櫃=購物
        // let catHousehold = categories.first(where: { $0.name == "居家" })! // 假設生活用品=居家
        
        let dummyBudgets = [
            // 進行中
            Budget(name: "衣櫃", totalAmount: 5000, startDate: Date().addingTimeInterval(-86400 * 10), endDate: Date().addingTimeInterval(86400 * 20)),
            // 已結束 (多出)
            Budget(name: "生活用品", totalAmount: 1000, startDate: Date().addingTimeInterval(-86400 * 40), endDate: Date().addingTimeInterval(-86400 * 10))
        ]
        self.budgets = dummyBudgets
        saveBudgets() // 儲存假資料
        
        // 4. 建立假清單 (符合線稿 16-3, 16-4)
        self.shoppingItems = [
            ShoppingItem(name: "錢包", isCompleted: true)
        ]
        saveShoppingItems()
        
        self.todoItems = [
            TodoItem(name: "買晚餐", isCompleted: true)
        ]
        saveTodoItems()
        
        print("假資料建立完畢。")
    }

    // MARK: - 分類管理
    func loadCategories() {
        guard fileManager.fileExists(atPath: categoriesFileURL.path) else {
            print("分類文件不存在，創建預設分類")
            createDefaultCategories()
            return
        }
        do {
            let data = try Data(contentsOf: categoriesFileURL)
            self.categories = try JSONDecoder().decode([ExpenseCategory].self, from: data)
        } catch {
            print("載入分類失敗: \(error)")
            createDefaultCategories()
        }
    }
    
    private func createDefaultCategories() {
        // 只有在 categories 為空時才建立
        guard self.categories.isEmpty else { return }
        
        categories = [ExpenseCategory.noneCategory] +
                      ExpenseCategory.defaultIncomeCategories +
                      ExpenseCategory.defaultExpenseCategories
        saveCategories()
    }
    
    private func saveCategories() {
        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: categoriesFileURL)
        } catch {
            print("儲存分類失敗: \(error)")
        }
    }
    
    func addCategory(_ category: ExpenseCategory) {
        categories.append(category)
        saveCategories()
    }
    
    func updateCategory(_ category: ExpenseCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }
    
    func deleteCategory(_ category: ExpenseCategory) {
        guard !category.isDefault else { return }
        for i in 0..<expenses.count {
            if expenses[i].categoryId == category.id {
                expenses[i].categoryId = nil
            }
        }
        categories.removeAll { $0.id == category.id }
        saveCategories()
        saveExpenses()
    }
    
    func getCategories(for type: TransactionType) -> [ExpenseCategory] {
        return categories.filter { $0.type == type || $0.type == .all }
    }
    
    func getCategory(by id: String?) -> ExpenseCategory {
        guard let id = id,
              let category = categories.first(where: { $0.id == id }) else {
            return ExpenseCategory.noneCategory
        }
        return category
    }
     
    // MARK: - 記帳記錄管理
    func loadExpenses() {
        guard fileManager.fileExists(atPath: expensesFileURL.path) else {
            self.expenses = []
            return
        }
        do {
            let data = try Data(contentsOf: expensesFileURL)
            let decodedExpenses = try JSONDecoder().decode([ExpenseRecord].self, from: data)
            self.expenses = decodedExpenses.sorted { $0.date > $1.date }
        } catch {
            print("載入記帳記錄失敗: \(error)")
            self.expenses = []
        }
    }
    
    private func saveExpenses() {
        do {
            let data = try JSONEncoder().encode(expenses)
            try data.write(to: expensesFileURL)
            syncExpensesToWidget()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("儲存記帳記錄失敗: \(error)")
        }
    }
    
    private func syncExpensesToWidget() {
        let groupID = "group.com.YuMei.expentacker2"
        guard let userDefaults = UserDefaults(suiteName: groupID) else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let widgetRecords = expenses.map { exp in
            ExpenseRecordWidget(amount: exp.amount, date: exp.date, type: exp.type.rawValue)
        }
        if let data = try? encoder.encode(widgetRecords) {
            userDefaults.set(data, forKey: "expenses")
        }
    }
    
    func addExpense(_ expense: ExpenseRecord) {
        expenses.append(expense)
        expenses.sort { $0.date > $1.date }
        saveExpenses()
    }
    
    func updateExpense(_ expense: ExpenseRecord) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            expenses.sort { $0.date > $1.date }
            saveExpenses()
        }
    }
    
    func deleteExpense(_ expense: ExpenseRecord) {
        expenses.removeAll { $0.id == expense.id }
        saveExpenses()
    }
    
    func deleteExpense(at indexSet: IndexSet) {
        expenses.remove(atOffsets: indexSet)
        saveExpenses()
    }
     
    // MARK: - 統計功能
    private var currentMonthDateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end.addingTimeInterval(-1) ?? now
        return (startOfMonth, endOfMonth)
    }
    
    var currentMonthDateRangeText: String {
        let dateRange = currentMonthDateRange
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "M月dd日"
        let startDateText = formatter.string(from: dateRange.start)
        let endDateText = formatter.string(from: dateRange.end)
        return "\(startDateText) - \(endDateText)"
    }
    
    var currentMonthIncome: Double {
        let dateRange = currentMonthDateRange
        return expenses.filter {
            $0.type == .income &&
            $0.date >= dateRange.start &&
            $0.date <= dateRange.end
        }.reduce(0) { $0 + $1.amount }
    }
    
    var currentMonthExpense: Double {
        let dateRange = currentMonthDateRange
        return expenses.filter {
            $0.type == .expense &&
            $0.date >= dateRange.start &&
            $0.date <= dateRange.end
        }.reduce(0) { $0 + $1.amount }
    }
    
    var currentMonthBalance: Double {
        currentMonthIncome - currentMonthExpense
    }
    
    var formattedCurrentMonthBalance: (text: String, color: Color) {
        let balanceValue = currentMonthBalance
        let formattedText = formatAmount(abs(balanceValue))
        if balanceValue > 0 {
            return ("+\(formattedText)", .green)
        } else if balanceValue < 0 {
            return ("-\(formattedText)", .red)
        } else {
            return (formattedText, .primary)
        }
    }
     
    // MARK: - 格式化
    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TWD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "NT$0"
    }
     
    // MARK: - 圖片儲存
    func saveImageData(_ data: Data) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = imagesDirectoryURL.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("儲存圖片失敗: \(error)")
            return nil
        }
    }
    
    func loadImage(for filename: String?) -> UIImage? {
        guard let filename = filename else { return nil }
        let url = imagesDirectoryURL.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
    
    func deleteImage(filename: String?) {
        guard let filename = filename else { return }
        let url = imagesDirectoryURL.appendingPathComponent(filename)
        try? fileManager.removeItem(at: url)
    }
    
    // MARK: - 預算管理
    func loadBudgets() {
        guard fileManager.fileExists(atPath: budgetsFileURL.path) else {
            self.budgets = []
            return
        }
        do {
            let data = try Data(contentsOf: budgetsFileURL)
            self.budgets = try JSONDecoder().decode([Budget].self, from: data)
        } catch {
            print("載入預算失敗: \(error)")
            self.budgets = []
        }
    }
    
    private func saveBudgets() {
        do {
            let data = try JSONEncoder().encode(budgets)
            try data.write(to: budgetsFileURL)
        } catch {
            print("儲存預算失敗: \(error)")
        }
    }
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        budgets.sort { $0.endDate > $1.endDate }
        saveBudgets()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    func getSpentAmount(for budget: Budget) -> Double {
        return expenses.filter {
            $0.type == .expense &&
            $0.date >= budget.startDate &&
            $0.date <= budget.endDate
        }.reduce(0) { $0 + $1.amount }
    }

    
    // MARK: - 清單管理
    func loadShoppingItems() {
        guard fileManager.fileExists(atPath: shoppingListFileURL.path) else {
            self.shoppingItems = []
            return
        }
        do {
            let data = try Data(contentsOf: shoppingListFileURL)
            self.shoppingItems = try JSONDecoder().decode([ShoppingItem].self, from: data)
        } catch {
            print("載V購物清單失敗: \(error)")
            self.shoppingItems = []
        }
    }

    private func saveShoppingItems() {
        do {
            let data = try JSONEncoder().encode(shoppingItems)
            try data.write(to: shoppingListFileURL)
        } catch {
            print("儲存購物清單失敗: \(error)")
        }
    }
    
    func addShoppingItem(name: String) {
        let newItem = ShoppingItem(name: name, isCompleted: false)
        shoppingItems.append(newItem)
        saveShoppingItems()
    }
    
    func updateShoppingItem(_ item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index] = item
            saveShoppingItems()
        }
    }
    
    func deleteShoppingItem(at offsets: IndexSet) {
        shoppingItems.remove(atOffsets: offsets)
        saveShoppingItems()
    }

    func loadTodoItems() {
        guard fileManager.fileExists(atPath: todoListFileURL.path) else {
            self.todoItems = []
            return
        }
        do {
            let data = try Data(contentsOf: todoListFileURL)
            self.todoItems = try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            print("載入待辦事項失敗: \(error)")
            self.todoItems = []
        }
    }

    private func saveTodoItems() {
        do {
            let data = try JSONEncoder().encode(todoItems)
            try data.write(to: todoListFileURL)
        } catch {
            print("儲存待辦事項失敗: \(error)")
        }
    }
    
    func addTodoItem(name: String) {
        let newItem = TodoItem(name: name, isCompleted: false)
        todoItems.append(newItem)
        saveTodoItems()
    }
    
    func updateTodoItem(_ item: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[index] = item
            saveTodoItems()
        }
    }
    
    func deleteTodoItem(at offsets: IndexSet) {
        todoItems.remove(atOffsets: offsets)
        saveTodoItems()
    }
}

// Widget 同步用
fileprivate struct ExpenseRecordWidget: Codable {
    let amount: Double
    let date: Date
    let type: String
}
