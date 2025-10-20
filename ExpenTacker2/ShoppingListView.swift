//
//  ShoppingListView.swift
//  ExpenTacker2
//
//  Created by 張郁眉 on 2025/10/20.
//

import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var dataManager: ExpenseDataManager
    @State private var selectedList: ListType = .shopping
    @State private var showingAddItem = false

    enum ListType: String, CaseIterable {
        case shopping = "購物清單"
        case todo = "待辦事項" // 線稿是 "特別事項"，這裡保持程式碼一致性
    }

    var body: some View {
        NavigationView {
            // *** 在這個 VStack 加入 padding ***
            VStack(spacing: 0) {
                Picker("清單類型", selection: $selectedList) {
                    ForEach(ListType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal) // 原有的水平 padding
                .padding(.bottom)     // 加上底部 padding，讓 Picker 和 List 分開
                .tint(Color.brandGold)

                List {
                    // ... (List 內容不變) ...
                    if selectedList == .shopping {
                        ForEach($dataManager.shoppingItems) { $item in
                            ItemRowView(item: $item) { dataManager.updateShoppingItem(item) }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal)
                                .padding(.vertical, 8) // 自訂行高
                        }
                        .onDelete(perform: dataManager.deleteShoppingItem)
                    } else {
                        ForEach($dataManager.todoItems) { $item in
                            ItemRowView(item: $item) { dataManager.updateTodoItem(item) }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal)
                                .padding(.vertical, 8) // 自訂行高
                        }
                        .onDelete(perform: dataManager.deleteTodoItem)
                    }
                }
                .listStyle(.plain)
                .background(Color.white)
            }
             // *** --- 加入這一行，增加頂部間距 --- ***
            .padding(.top, 10) // 與 BudgetView 一致
             // *** --- 加入結束 --- ***
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("清單") // Navigation Bar 標題
             // *** 修改：確保 Navigation Bar 顏色正確 ***
            .navigationBarColor(backgroundColor: Color.brandGold, titleColor: .white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                     .foregroundColor(.white) // *** 修改：Toolbar 按鈕改為白色 ***
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(dataManager: dataManager, listType: selectedList)
            }
        }
         // *** 修改：確保 Tab 選中時 Navigation Bar 顏色一致 ***
        .onAppear {
             // 再次套用顏色設定
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.brandGold)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().tintColor = .white // Back button
        }
    }
}

// MARK: - ItemRowView (不變)
struct ItemRowView<T: Identifiable>: View {
    // ... (ItemRowView 程式碼保持不變) ...
     @Binding var item: T; var onToggle: () -> Void
    private var name: String; private var isCompleted: Binding<Bool>; private var iconName: String
    init(item: Binding<T>, onToggle: @escaping () -> Void) {
        self._item = item; self.onToggle = onToggle
        if let shoppingItem = item.wrappedValue as? ShoppingItem {
            self.name = shoppingItem.name; self.iconName = "bag.fill"
            self.isCompleted = Binding(get: { (item.wrappedValue as! ShoppingItem).isCompleted }, set: { nv in if var temp = item.wrappedValue as? ShoppingItem { temp.isCompleted = nv; item.wrappedValue = temp as! T } })
        } else if let todoItem = item.wrappedValue as? TodoItem {
            self.name = todoItem.name; self.iconName = "person.fill" // Or maybe "checkmark.square"?
            self.isCompleted = Binding(get: { (item.wrappedValue as! TodoItem).isCompleted }, set: { nv in if var temp = item.wrappedValue as? TodoItem { temp.isCompleted = nv; item.wrappedValue = temp as! T } })
        } else { self.name = "??"; self.iconName = "?"; self.isCompleted = .constant(false) }
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                Image(systemName: iconName).font(.title3).foregroundColor(isCompleted.wrappedValue ? .secondary : .primary).frame(width: 25)
                Text(name).font(.body).strikethrough(isCompleted.wrappedValue, color: .secondary).foregroundColor(isCompleted.wrappedValue ? .secondary : .primary)
                Spacer()
                Image(systemName: isCompleted.wrappedValue ? "checkmark.circle.fill" : "circle").foregroundColor(isCompleted.wrappedValue ? Color.brandGold : .secondary).font(.title2)
                    .onTapGesture { isCompleted.wrappedValue.toggle(); onToggle() }
            }
            .padding(.vertical, 12).padding(.leading, 15) // Adjusted padding slightly
            .contentShape(Rectangle())
            .onTapGesture { isCompleted.wrappedValue.toggle(); onToggle() }
            Divider().padding(.leading, 55)
        }
    }
}

// MARK: - Preview
#Preview {
    ShoppingListView(dataManager: ExpenseDataManager())
}
