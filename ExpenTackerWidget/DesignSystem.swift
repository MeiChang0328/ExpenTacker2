//
//  DesignSystem.swift
//  ExpenTackerWidget
//
//  Created by Kiro on 2025/10/25.
//

import SwiftUI

// MARK: - Enhanced Color System
struct WidgetColors {
    // MARK: - Primary Colors with Modern Palette
    static let primary = Color(red: 0.95, green: 0.26, blue: 0.21) // Modern red
    static let secondary = Color(red: 0.20, green: 0.60, blue: 1.0) // Modern blue
    static let accent = Color(red: 0.91, green: 0.12, blue: 0.39) // Deep pink
    
    // MARK: - Semantic Colors
    static let expense = Color(red: 0.95, green: 0.26, blue: 0.21)
    static let income = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let neutral = Color(red: 0.55, green: 0.55, blue: 0.58)
    
    // MARK: - Background Colors
    static let cardBackground = Color(.systemBackground)
    static let overlayBackground = Color.black.opacity(0.05)
    
    // MARK: - Text Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color.primary.opacity(0.6)
    static let onDarkText = Color.white
    static let onDarkSecondaryText = Color.white.opacity(0.85)
    
    // MARK: - Gradient Systems
    struct Gradients {
        static let expenseGradient = LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.26, blue: 0.21),
                Color(red: 0.91, green: 0.12, blue: 0.39),
                Color(red: 0.85, green: 0.05, blue: 0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let incomeGradient = LinearGradient(
            colors: [
                Color(red: 0.20, green: 0.78, blue: 0.35),
                Color(red: 0.15, green: 0.68, blue: 0.38)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let neutralGradient = LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.95, blue: 0.97),
                Color(red: 0.90, green: 0.90, blue: 0.93)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardGradient = LinearGradient(
            colors: [
                Color.white,
                Color.white.opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Shadow Colors
    struct Shadows {
        static let primary = Color.black.opacity(0.15)
        static let secondary = Color.black.opacity(0.08)
        static let subtle = Color.black.opacity(0.05)
        static let expense = Color(red: 0.95, green: 0.26, blue: 0.21).opacity(0.3)
        static let income = Color(red: 0.20, green: 0.78, blue: 0.35).opacity(0.3)
    }
}

// MARK: - Enhanced Typography System
struct WidgetTypography {
    // MARK: - Font Scale following 8pt grid
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)
    static let title1 = Font.system(size: 24, weight: .bold, design: .default)
    static let title2 = Font.system(size: 20, weight: .bold, design: .default)
    static let title3 = Font.system(size: 18, weight: .semibold, design: .default)
    static let headline = Font.system(size: 16, weight: .semibold, design: .default)
    static let body = Font.system(size: 14, weight: .regular, design: .default)
    static let callout = Font.system(size: 12, weight: .medium, design: .default)
    static let caption = Font.system(size: 10, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 8, weight: .regular, design: .default)
    
    // MARK: - Specialized Widget Fonts
    static let amountLarge = Font.system(size: 24, weight: .bold, design: .rounded)
    static let amountMedium = Font.system(size: 20, weight: .bold, design: .rounded)
    static let amountSmall = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let label = Font.system(size: 10, weight: .medium, design: .default)
    static let percentage = Font.system(size: 12, weight: .semibold, design: .default)
}

// MARK: - Spacing System (8pt Grid)
struct WidgetSpacing {
    // MARK: - Base spacing units (multiples of 8pt)
    static let xs: CGFloat = 4    // 0.5x
    static let sm: CGFloat = 8    // 1x
    static let md: CGFloat = 16   // 2x
    static let lg: CGFloat = 24   // 3x
    static let xl: CGFloat = 32   // 4x
    static let xxl: CGFloat = 40  // 5x
    
    // MARK: - Semantic spacing
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 12
    static let elementSpacing: CGFloat = 8
    static let tightSpacing: CGFloat = 4
    
    // MARK: - Component-specific spacing
    static let iconSpacing: CGFloat = 8
    static let buttonPadding: CGFloat = 12
    static let listItemHeight: CGFloat = 32
    static let categoryCircleSize: CGFloat = 56
    static let smallCategoryCircleSize: CGFloat = 16
}

// MARK: - Corner Radius System
struct WidgetCornerRadius {
    // MARK: - Base radius values
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    
    // MARK: - Component-specific radius
    static let card: CGFloat = 16
    static let button: CGFloat = 8
    static let categoryCircle: CGFloat = 28 // Half of categoryCircleSize
    static let smallCategoryCircle: CGFloat = 8
    static let widget: CGFloat = 20
}

// MARK: - Shadow and Elevation System
struct WidgetShadows {
    // MARK: - Elevation levels
    static let level1 = Shadow(
        color: WidgetColors.Shadows.subtle,
        radius: 2,
        x: 0,
        y: 1
    )
    
    static let level2 = Shadow(
        color: WidgetColors.Shadows.secondary,
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let level3 = Shadow(
        color: WidgetColors.Shadows.primary,
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let level4 = Shadow(
        color: WidgetColors.Shadows.primary,
        radius: 12,
        x: 0,
        y: 6
    )
    
    static let level5 = Shadow(
        color: WidgetColors.Shadows.primary,
        radius: 16,
        x: 0,
        y: 8
    )
    
    // MARK: - Component-specific shadows
    static let card = level2
    static let button = level1
    static let categoryCircle = level2
    static let widget = level3
    
    // MARK: - Colored shadows for semantic elements
    static let expenseShadow = Shadow(
        color: WidgetColors.Shadows.expense,
        radius: 6,
        x: 0,
        y: 3
    )
    
    static let incomeShadow = Shadow(
        color: WidgetColors.Shadows.income,
        radius: 6,
        x: 0,
        y: 3
    )
}

// MARK: - Shadow Helper Struct
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions for Design System
extension View {
    // MARK: - Shadow Application
    func widgetShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    // MARK: - Card Style
    func widgetCard(
        cornerRadius: CGFloat = WidgetCornerRadius.card,
        shadow: Shadow = WidgetShadows.card,
        padding: CGFloat = WidgetSpacing.cardPadding
    ) -> some View {
        self
            .padding(padding)
            .background(WidgetColors.cardBackground)
            .cornerRadius(cornerRadius)
            .widgetShadow(shadow)
    }
    
    // MARK: - Button Style
    func widgetButton(
        cornerRadius: CGFloat = WidgetCornerRadius.button,
        shadow: Shadow = WidgetShadows.button
    ) -> some View {
        self
            .cornerRadius(cornerRadius)
            .widgetShadow(shadow)
    }
    
    // MARK: - Typography Styles
    func primaryText() -> some View {
        self.foregroundColor(WidgetColors.primaryText)
    }
    
    func secondaryText() -> some View {
        self.foregroundColor(WidgetColors.secondaryText)
    }
    
    func tertiaryText() -> some View {
        self.foregroundColor(WidgetColors.tertiaryText)
    }
    
    func onDarkText() -> some View {
        self.foregroundColor(WidgetColors.onDarkText)
    }
    
    func onDarkSecondaryText() -> some View {
        self.foregroundColor(WidgetColors.onDarkSecondaryText)
    }
    
    // MARK: - Spacing Helpers
    func widgetPadding(_ padding: CGFloat = WidgetSpacing.cardPadding) -> some View {
        self.padding(padding)
    }
    
    func widgetSpacing(_ spacing: CGFloat = WidgetSpacing.itemSpacing) -> some View {
        self.padding(.vertical, spacing / 2)
    }
}

// MARK: - Enhanced Color Components for Backward Compatibility
extension ColorComponents {
    // MARK: - Modern color palette presets
    static let modernRed = ColorComponents(red: 0.95, green: 0.26, blue: 0.21, alpha: 1.0)
    static let modernBlue = ColorComponents(red: 0.20, green: 0.60, blue: 1.0, alpha: 1.0)
    static let modernGreen = ColorComponents(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0)
    static let modernOrange = ColorComponents(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
    static let modernPurple = ColorComponents(red: 0.69, green: 0.32, blue: 0.87, alpha: 1.0)
    static let modernPink = ColorComponents(red: 0.91, green: 0.12, blue: 0.39, alpha: 1.0)
    static let modernYellow = ColorComponents(red: 1.0, green: 0.80, blue: 0.0, alpha: 1.0)
    static let modernTeal = ColorComponents(red: 0.35, green: 0.78, blue: 0.98, alpha: 1.0)
    
    // MARK: - Semantic color helpers
    var isExpenseColor: Bool {
        return red > 0.8 && green < 0.4 && blue < 0.4
    }
    
    var isIncomeColor: Bool {
        return green > 0.6 && red < 0.4 && blue < 0.6
    }
    
    // MARK: - Enhanced color with shadow
    var colorWithShadow: Color {
        if isExpenseColor {
            return color
        } else if isIncomeColor {
            return color
        } else {
            return color
        }
    }
    
    // MARK: - Gradient version of color
    var gradient: LinearGradient {
        let baseColor = color
        let darkerColor = Color(
            red: max(0, red - 0.1),
            green: max(0, green - 0.1),
            blue: max(0, blue - 0.1),
            opacity: alpha
        )
        
        return LinearGradient(
            colors: [baseColor, darkerColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Animation System
struct WidgetAnimations {
    // MARK: - Standard animations
    static let quick = Animation.easeInOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.5)
    
    // MARK: - Spring animations
    static let springQuick = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let springStandard = Animation.spring(response: 0.5, dampingFraction: 0.8)
    
    // MARK: - Micro-interaction animations
    static let buttonTap = Animation.easeInOut(duration: 0.1)
    static let scaleEffect = Animation.spring(response: 0.2, dampingFraction: 0.6)
}

// MARK: - Accessibility Helpers
struct WidgetAccessibility {
    // MARK: - Minimum touch target size (44pt as per Apple guidelines)
    static let minimumTouchTarget: CGFloat = 44
    
    // MARK: - Contrast ratio helpers
    static func meetsContrastRequirement(foreground: Color, background: Color) -> Bool {
        // Simplified contrast check - in production, you'd want a more sophisticated implementation
        return true // Placeholder for actual contrast calculation
    }
    
    // MARK: - Dynamic type scaling
    static func scaledFont(_ font: Font, for category: DynamicTypeSize) -> Font {
        // Simplified scaling - in production, you'd implement proper scaling logic
        return font
    }
}