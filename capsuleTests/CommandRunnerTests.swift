@testable import capsule
import Testing

struct CommandRunnerTests {
    @Test func resultSuccessFlagTrueOnZeroExitCode() {
        let result = CommandRunner.Result(output: "", exitCode: 0, newDirectory: nil)
        #expect(result.success == true)
    }

    @Test func resultSuccessFlagFalseOnNonZeroExitCode() {
        let result = CommandRunner.Result(output: "", exitCode: 1, newDirectory: nil)
        #expect(result.success == false)
    }
}
