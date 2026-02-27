import XCTest

final class CapsuleUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor func testChangeDirectoryToUsers() async throws {
        let capsule = CapsuleAppDriver(self)
        await capsule.launch()
        capsule.execute("cd /Users")
        await capsule.assertCurrentDirectory("/Users")
    }
}
