//
//  AppIntent.swift
//  ExpenTackerWidget
//
//  Created by 張郁眉 on 2025/10/13.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}

struct RefreshExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "刷新隨機消費"
    static var description = IntentDescription("刷新顯示另一筆隨機消費記錄")
    
    func perform() async throws -> some IntentResult {
        // 刷新 Widget 時間線
        WidgetCenter.shared.reloadTimelines(ofKind: "ExpenTackerWidget")
        return .result()
    }
}
