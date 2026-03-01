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

        let statusItem = app.statusItems["Capsule"]
        guard statusItem.waitForExistence(timeout: 5) else {
            XCTFail("Capsule status item did not appear")
            return
        }
        statusItem.click()
        let openCapsuleItem = app.menuItems["Open Capsule"]
        guard openCapsuleItem.waitForExistence(timeout: 2) else {
            XCTFail("Open Capsule menu item did not appear")
            return
        }
        openCapsuleItem.click()

        await testCase.fulfillment(
            of: [
                testCase.expectation(
                    for: NSPredicate(format: "exists == true"),
                    evaluatedWith: app.textFields["commandInputField"]
                )
            ],
            timeout: 5
        )
    }

    func execute(_ command: String) {
        let field = app.textFields["commandInputField"]
        field.click()
        field.typeText(command)
        field.typeKey(.return, modifierFlags: [])
    }

    func assertCurrentDirectory(_ path: String, timeout: TimeInterval = 10)
        async {
        let label = app.staticTexts["currentDirectoryLabel"]
        await testCase.fulfillment(
            of: [
                testCase.expectation(
                    for: NSPredicate(format: "value LIKE[c] %@", path),
                    evaluatedWith: label
                )
            ],
            timeout: timeout
        )
    }

    func assertLastCommandHeader(_ command: String, timeout: TimeInterval = 10)
        async {
        let header = app.staticTexts["lastCommandHeader"]
        await testCase.fulfillment(
            of: [
                testCase.expectation(
                    for: NSPredicate(format: "value == %@", "$ \(command)"),
                    evaluatedWith: header
                )
            ],
            timeout: timeout
        )
    }
}
