//
//  ExpenTackerWidget.swift
//  ExpenTackerWidget
//
//  Created by 張郁眉 on 2025/10/13.
//

import WidgetKit
import SwiftUI
import AppIntents

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let todayExpenseTotal: Double
    let randomExpense: ExpenseRecordWidget?
    let monthlyExpensesByCategory: [CategoryExpense]
}

struct ExpenseRecordWidget: Codable {
    let id: String
    let amount: Double
    let date: Date
    let type: String // "expense" or "income"
    let remark: String
    let categoryName: String
    let categoryColor: ColorComponents
}

struct CategoryExpense: Codable {
    let categoryName: String
    let amount: Double
    let color: ColorComponents
    let percentage: Double
}

struct ColorComponents: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            todayExpenseTotal: 1250,
            randomExpense: ExpenseRecordWidget(
                id: "sample",
                amount: 85,
                date: Date(),
                type: "expense",
                remark: "午餐",
                categoryName: "餐飲",
                categoryColor: ColorComponents(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
            ),
            monthlyExpensesByCategory: [
                CategoryExpense(categoryName: "餐飲", amount: 5000, color: ColorComponents(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0), percentage: 40),
                CategoryExpense(categoryName: "交通", amount: 3000, color: ColorComponents(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0), percentage: 24),
                CategoryExpense(categoryName: "購物", amount: 2500, color: ColorComponents(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0), percentage: 20)
            ]
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        return await createEntry(for: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = await createEntry(for: configuration, date: entryDate)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    private func createEntry(for configuration: ConfigurationAppIntent, date: Date = Date()) async -> SimpleEntry {
        let data = Self.fetchWidgetData()
        return SimpleEntry(
            date: date,
            configuration: configuration,
            todayExpenseTotal: data.todayTotal,
            randomExpense: data.randomExpense,
            monthlyExpensesByCategory: data.monthlyCategories
        )
    }
    
    static func fetchWidgetData() -> (todayTotal: Double, randomExpense: ExpenseRecordWidget?, monthlyCategories: [CategoryExpense]) {
        let groupID = "group.com.YuMei.expentacker2"
        let userDefaults = UserDefaults(suiteName: groupID)
        guard let data = userDefaults?.data(forKey: "expenses") else {
            return (0, nil, [])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let records = try? decoder.decode([ExpenseRecordWidget].self, from: data) else {
            return (0, nil, [])
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // 今日支出總計
        let todayExpenses = records.filter { 
            $0.type == "expense" && calendar.isDate($0.date, inSameDayAs: now) 
        }
        let todayTotal = todayExpenses.reduce(0) { $0 + $1.amount }
        
        // 隨機今日支出
        let randomExpense = todayExpenses.randomElement()
        
        // 當月支出分類統計
        let monthlyExpenses = records.filter { 
            $0.type == "expense" && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        
        let categoryGroups = Dictionary(grouping: monthlyExpenses) { $0.categoryName }
        let monthlyTotal = monthlyExpenses.reduce(0) { $0 + $1.amount }
        
        let monthlyCategories = categoryGroups.compactMap { (categoryName, expenses) -> CategoryExpense? in
            let categoryTotal = expenses.reduce(0) { $0 + $1.amount }
            let percentage = monthlyTotal > 0 ? (categoryTotal / monthlyTotal) * 100 : 0
            
            guard let firstExpense = expenses.first else { return nil }
            
            return CategoryExpense(
                categoryName: categoryName,
                amount: categoryTotal,
                color: firstExpense.categoryColor,
                percentage: percentage
            )
        }.sorted { $0.amount > $1.amount }
        
        return (todayTotal, randomExpense, Array(monthlyCategories.prefix(6)))
    }
}

struct ExpenTackerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(todayTotal: entry.todayExpenseTotal)
        case .systemMedium:
            MediumWidgetView(randomExpense: entry.randomExpense)
        case .systemLarge:
            LargeWidgetView(categoryExpenses: entry.monthlyExpensesByCategory)
        default:
            SmallWidgetView(todayTotal: entry.todayExpenseTotal)
        }
    }
}

// MARK: - Import Design System
// Design system components are now defined in DesignSystem.swift

// MARK: - 小尺寸 Widget
struct SmallWidgetView: View {
    let todayTotal: Double
    
    var body: some View {
        Link(destination: URL(string: "expenTacker://")!) {
            VStack(spacing: WidgetSpacing.itemSpacing) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .onDarkText()
                        .font(.system(size: 20, weight: .medium))
                        .imageScale(.medium)
                    Spacer()
                    Text("今日")
                        .font(WidgetTypography.callout)
                        .fontWeight(.medium)
                        .onDarkSecondaryText()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: WidgetSpacing.tightSpacing + 2) {
                    Text("支出")
                        .font(WidgetTypography.label)
                        .fontWeight(.medium)
                        .onDarkSecondaryText()
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text("NT$\(Int(todayTotal))")
                        .font(WidgetTypography.amountLarge)
                        .fontWeight(.bold)
                        .onDarkText()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .widgetShadow(WidgetShadows.level1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .widgetPadding()
            .background(WidgetColors.Gradients.expenseGradient)
            .cornerRadius(WidgetCornerRadius.widget)
            .widgetShadow(WidgetShadows.widget)
        }
        .scaleEffect(1.0)
        .animation(WidgetAnimations.scaleEffect, value: todayTotal)
    }
}

// MARK: - 中尺寸 Widget
struct MediumWidgetView: View {
    let randomExpense: ExpenseRecordWidget?
    
    var body: some View {
        Group {
            if let expense = randomExpense {
                Link(destination: URL(string: "expenTacker://expense/\(expense.id)")!) {
                    HStack(spacing: WidgetSpacing.md) {
                        // 左側：分類圓圈
                        Circle()
                            .fill(expense.categoryColor.gradient)
                            .frame(
                                width: WidgetSpacing.categoryCircleSize,
                                height: WidgetSpacing.categoryCircleSize
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .overlay(
                                        Image(systemName: "minus.circle.fill")
                                            .onDarkText()
                                            .font(.system(size: 18, weight: .medium))
                                            .imageScale(.medium)
                                    )
                            )
                            .widgetShadow(WidgetShadows.categoryCircle)
                        
                        // 中間：消費資訊
                        VStack(alignment: .leading, spacing: WidgetSpacing.tightSpacing + 2) {
                            Text(expense.remark)
                                .font(WidgetTypography.title3)
                                .fontWeight(.semibold)
                                .primaryText()
                                .lineLimit(1)
                            
                            Text(expense.categoryName)
                                .font(WidgetTypography.callout)
                                .fontWeight(.medium)
                                .secondaryText()
                            
                            Text("NT$\(Int(expense.amount))")
                                .font(WidgetTypography.amountMedium)
                                .fontWeight(.bold)
                                .foregroundColor(WidgetColors.expense)
                        }
                        
                        Spacer()
                        
                        // 右側：刷新按鈕
                        VStack(spacing: WidgetSpacing.elementSpacing) {
                            Button(intent: RefreshExpenseIntent()) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(WidgetColors.secondary)
                                    .imageScale(.medium)
                                    .frame(
                                        width: WidgetAccessibility.minimumTouchTarget,
                                        height: WidgetAccessibility.minimumTouchTarget
                                    )
                            }
                            .buttonStyle(.plain)
                            .widgetButton()
                            
                            Spacer()
                            
                            Text("隨機消費")
                                .font(WidgetTypography.caption)
                                .fontWeight(.medium)
                                .tertiaryText()
                        }
                    }
                    .widgetCard()
                }
            } else {
                // 沒有消費記錄時的顯示
                VStack(spacing: WidgetSpacing.md) {
                    Image(systemName: "tray")
                        .font(.system(size: 32, weight: .medium))
                        .secondaryText()
                        .imageScale(.large)
                    
                    Text("今日尚無消費")
                        .font(WidgetTypography.title3)
                        .fontWeight(.medium)
                        .secondaryText()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .widgetCard()
            }
        }
        .cornerRadius(WidgetCornerRadius.widget)
    }
}

// MARK: - 大尺寸 Widget
struct LargeWidgetView: View {
    let categoryExpenses: [CategoryExpense]
    
    var body: some View {
        Link(destination: URL(string: "expenTacker://statistics")!) {
            VStack(spacing: WidgetSpacing.md) {
                // 標題
                HStack {
                    Text("本月消費分析")
                        .font(WidgetTypography.title3)
                        .fontWeight(.bold)
                        .primaryText()
                    Spacer()
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(WidgetColors.secondary)
                        .font(.system(size: 18, weight: .medium))
                }
                
                if !categoryExpenses.isEmpty {
                    HStack(spacing: WidgetSpacing.lg) {
                        // 圓餅圖
                        PieChartView(data: categoryExpenses)
                            .frame(width: 140, height: 140)
                        
                        // 分類列表
                        VStack(alignment: .leading, spacing: WidgetSpacing.elementSpacing) {
                            ForEach(Array(categoryExpenses.prefix(5).enumerated()), id: \.offset) { index, category in
                                HStack(spacing: WidgetSpacing.elementSpacing) {
                                    Circle()
                                        .fill(category.color.gradient)
                                        .frame(
                                            width: WidgetSpacing.smallCategoryCircleSize,
                                            height: WidgetSpacing.smallCategoryCircleSize
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        .widgetShadow(WidgetShadows.level1)
                                    
                                    VStack(alignment: .leading, spacing: WidgetSpacing.xs / 2) {
                                        Text(category.categoryName)
                                            .font(WidgetTypography.callout)
                                            .fontWeight(.medium)
                                            .primaryText()
                                        
                                        Text("NT$\(Int(category.amount))")
                                            .font(WidgetTypography.caption)
                                            .secondaryText()
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(Int(category.percentage))%")
                                        .font(WidgetTypography.percentage)
                                        .fontWeight(.semibold)
                                        .foregroundColor(category.color.color)
                                }
                                .frame(height: WidgetSpacing.listItemHeight)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    VStack(spacing: WidgetSpacing.itemSpacing) {
                        Image(systemName: "chart.pie")
                            .font(WidgetTypography.largeTitle)
                            .secondaryText()
                        
                        Text("本月尚無消費記錄")
                            .font(WidgetTypography.headline)
                            .secondaryText()
                    }
                    .frame(maxHeight: .infinity)
                }
                
                Spacer()
            }
            .widgetCard(
                cornerRadius: WidgetCornerRadius.xxl,
                shadow: WidgetShadows.level4,
                padding: WidgetSpacing.lg
            )
        }
        .cornerRadius(WidgetCornerRadius.widget)
    }
}

// MARK: - 圓餅圖組件 (Modern Donut Chart)
struct PieChartView: View {
    let data: [CategoryExpense]
    
    var body: some View {
        ZStack {
            // Background circle for better visual definition
            Circle()
                .fill(WidgetColors.overlayBackground)
                .frame(width: 140, height: 140)
            
            // Donut chart segments
            ForEach(Array(data.enumerated()), id: \.offset) { index, category in
                DonutSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: category.color.gradient,
                    strokeWidth: 3
                )
            }
            
            // Center hole with subtle background
            Circle()
                .fill(WidgetColors.cardBackground)
                .frame(width: 40, height: 40)
                .widgetShadow(WidgetShadows.level1)
        }
        .widgetShadow(WidgetShadows.level2)
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousPercentages = data.prefix(index).reduce(0) { $0 + $1.percentage }
        return Angle(degrees: (previousPercentages / 100) * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let previousPercentages = data.prefix(index + 1).reduce(0) { $0 + $1.percentage }
        return Angle(degrees: (previousPercentages / 100) * 360 - 90)
    }
}

struct DonutSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: LinearGradient
    let strokeWidth: CGFloat
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 70, y: 70)
            let outerRadius: CGFloat = 60
            let innerRadius: CGFloat = 20
            
            // Create donut path
            path.addArc(
                center: center,
                radius: outerRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            
            path.addLine(to: CGPoint(
                x: center.x + innerRadius * CoreGraphics.cos(CGFloat(endAngle.radians)),
                y: center.y + innerRadius * CoreGraphics.sin(CGFloat(endAngle.radians))
            ))
            
            path.addArc(
                center: center,
                radius: innerRadius,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: true
            )
            
            path.closeSubpath()
        }
        .fill(color)
        .overlay(
            // White separator between segments
            Path { path in
                let center = CGPoint(x: 70, y: 70)
                let outerRadius: CGFloat = 60
                let innerRadius: CGFloat = 20
                
                // Start separator
                path.move(to: CGPoint(
                    x: center.x + innerRadius * CoreGraphics.cos(CGFloat(startAngle.radians)),
                    y: center.y + innerRadius * CoreGraphics.sin(CGFloat(startAngle.radians))
                ))
                path.addLine(to: CGPoint(
                    x: center.x + outerRadius * CoreGraphics.cos(CGFloat(startAngle.radians)),
                    y: center.y + outerRadius * CoreGraphics.sin(CGFloat(startAngle.radians))
                ))
                
                // End separator
                path.move(to: CGPoint(
                    x: center.x + innerRadius * CoreGraphics.cos(CGFloat(endAngle.radians)),
                    y: center.y + innerRadius * CoreGraphics.sin(CGFloat(endAngle.radians))
                ))
                path.addLine(to: CGPoint(
                    x: center.x + outerRadius * CoreGraphics.cos(CGFloat(endAngle.radians)),
                    y: center.y + outerRadius * CoreGraphics.sin(CGFloat(endAngle.radians))
                ))
            }
            .stroke(Color.white, lineWidth: strokeWidth)
        )
    }
}

struct ExpenTackerWidget: Widget {
    let kind: String = "ExpenTackerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ExpenTackerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("記帳小工具")
        .description("顯示你的消費記錄和統計資訊")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    ExpenTackerWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .smiley,
        todayExpenseTotal: 1250,
        randomExpense: nil,
        monthlyExpensesByCategory: []
    )
}

#Preview(as: .systemMedium) {
    ExpenTackerWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .smiley,
        todayExpenseTotal: 1250,
        randomExpense: ExpenseRecordWidget(
            id: "sample",
            amount: 85,
            date: Date(),
            type: "expense",
            remark: "午餐便當",
            categoryName: "餐飲",
            categoryColor: ColorComponents(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        ),
        monthlyExpensesByCategory: []
    )
}

#Preview(as: .systemLarge) {
    ExpenTackerWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .smiley,
        todayExpenseTotal: 1250,
        randomExpense: nil,
        monthlyExpensesByCategory: [
            CategoryExpense(categoryName: "餐飲", amount: 5000, color: ColorComponents(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0), percentage: 40),
            CategoryExpense(categoryName: "交通", amount: 3000, color: ColorComponents(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0), percentage: 24),
            CategoryExpense(categoryName: "購物", amount: 2500, color: ColorComponents(red: 1.0, green: 0.4, blue: 0.8, alpha: 1.0), percentage: 20),
            CategoryExpense(categoryName: "娛樂", amount: 1000, color: ColorComponents(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0), percentage: 8),
            CategoryExpense(categoryName: "其他", amount: 1000, color: ColorComponents(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), percentage: 8)
        ]
    )
}
