import CoreGraphics

enum Appearence {
    static let panelWidth: CGFloat = 640
    static let outputMaxHeight: CGFloat = 300
    static let menuBarIconSize: CGFloat = 18
    static let cornerRadius: CGFloat = 12

    enum Font {
        static let directory: CGFloat = 10
        static let prompt: CGFloat = 16
        static let commandInput: CGFloat = 20
        static let commandHeader: CGFloat = 14
        static let commandOutput: CGFloat = 13
    }

    enum Padding {
        static let input: CGFloat = 16
        static let output: CGFloat = 12
    }
}
