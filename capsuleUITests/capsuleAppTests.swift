import XCTest

final class CapsuleAppTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor func testChangeDirectoryToUsers() async {
        let capsule = CapsuleAppDriver(self)
        await capsule.launch()
        capsule.execute("cd /Users")
        await capsule.assertCurrentDirectory("/Users")
    }

    @MainActor func testLastCommandShownInResultPanel() async {
        let capsule = CapsuleAppDriver(self)
        await capsule.launch()
        capsule.execute("echo hello")
        await capsule.assertLastCommandHeader("echo hello")
    }
}
