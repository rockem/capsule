import XCTest

@MainActor
final class CapsuleAppDriver {
    private let app = XCUIApplication()
    private unowned let testCase: XCTestCase

    init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }

    func launch() async {
        app.launch()
        await testCase.fulfillment(
            of: [testCase.expectation(for: NSPredicate(format: "exists == true"),
                                      evaluatedWith: app.textFields["commandInputField"])],
            timeout: 5
        )
    }

    func execute(_ command: String) {
        let field = app.textFields["commandInputField"]
        field.click()
        field.typeText(command)
        field.typeKey(.return, modifierFlags: [])
    }

    func assertCurrentDirectory(_ path: String, timeout: TimeInterval = 10) async {
        let label = app.staticTexts["currentDirectoryLabel"]
        await testCase.fulfillment(
            of: [testCase.expectation(for: NSPredicate(format: "value LIKE[c] %@", path),
                                      evaluatedWith: label)],
            timeout: timeout
        )
    }
}
