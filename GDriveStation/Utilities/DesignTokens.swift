import SwiftUI

enum DesignTokens {
    // MARK: - Corner Radius
    enum Radius {
        static let artwork: CGFloat = 8
        static let container: CGFloat = 12
        static let sheet: CGFloat = 16
    }

    // MARK: - Opacity Scale
    enum Opacity {
        static let primary: Double = 1.0
        static let secondary: Double = 0.5
        static let tertiary: Double = 0.25
        static let ghost: Double = 0.12
        static let subtle: Double = 0.06
    }

    // MARK: - Typography
    enum Typography {
        static let titleFont: Font = .headline
        static let titleWeight: Font.Weight = .bold

        static let secondaryFont: Font = .subheadline
        static let secondaryWeight: Font.Weight = .regular

        static let tertiaryFont: Font = .caption

        static let timeFont: Font = .caption2
    }

    // MARK: - Spacing (4pt grid)
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Shadow
    enum Shadow {
        static let sm: (color: Color, radius: CGFloat, y: CGFloat) = (.black.opacity(0.4), 12, 4)
        static let md: (color: Color, radius: CGFloat, y: CGFloat) = (.black.opacity(0.5), 20, 8)
    }

    // MARK: - Animation
    enum Animation {
        static let springResponse: Double = 0.45
        static let springDamping: Double = 0.88
        static let spring: SwiftUI.Animation = .spring(
            response: springResponse,
            dampingFraction: springDamping
        )
        static let colorTransition: SwiftUI.Animation = .easeInOut(duration: 0.5)
    }

    // MARK: - Layout
    enum Layout {
        static let albumArtMaxSize: CGFloat = 320
        static let albumArtFallbackIcon: CGFloat = 48
        static let progressBarHeight: CGFloat = 4
        static let progressThumbSize: CGFloat = 12
        static let playButtonSize: CGFloat = 56
    }
}
