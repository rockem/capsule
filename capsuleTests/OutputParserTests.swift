import Testing

@testable import capsule

struct OutputParserTests {
    @Test func parseNormalOutputWithSentinel() {
        verifyOutputAndDirectory(
            raw: "hello world\n\(OutputParser.pwdSentinel):/tmp/mydir",
            output: "hello world",
            newDirectory: "/tmp/mydir"
        )
    }

    func verifyOutputAndDirectory(
        raw: String,
        output: String,
        newDirectory: String?
    ) {
        let result = OutputParser.parse(raw)
        #expect(result.output == output)
        #expect(result.newDirectory == newDirectory)
    }

    @Test func parseNoSentinel() {
        verifyOutputAndDirectory(
            raw: "some output\nwith multiple lines",
            output: "some output\nwith multiple lines",
            newDirectory: nil
        )
    }

    @Test func parseEmptyOutputWithSentinel() {
        verifyOutputAndDirectory(
            raw: "\n\(OutputParser.pwdSentinel):/Users/me",
            output: "",
            newDirectory: "/Users/me"
        )
    }

    @Test func parsePwdWithSpaces() {
        verifyOutputAndDirectory(
            raw: "done\n\(OutputParser.pwdSentinel):/Users/me/my projects/foo bar",
            output: "done",
            newDirectory: "/Users/me/my projects/foo bar"
        )
    }

    @Test func parsePwdWithSpecialChars() {
        verifyOutputAndDirectory(
            raw: "ok\n\(OutputParser.pwdSentinel):/tmp/café & more",
            output: "ok",
            newDirectory: "/tmp/café & more"
        )
    }
}
