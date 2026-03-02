//
//  capsuleTests.swift
//  capsuleTests
//
//  Created by eli segal on 26/02/2026.
//

@testable import capsule
import Testing

struct CapsuleTests {
    // MARK: – CommandRunner.parse

    @Test func parseNormalOutputWithSentinel() {
        let raw = "hello world\n__CAPSULE_PWD__:/tmp/mydir"
        let (output, newDir) = CommandRunner.parse(raw)
        #expect(output == "hello world")
        #expect(newDir == "/tmp/mydir")
    }

    @Test func parseNoSentinel() {
        let raw = "some output\nwith multiple lines"
        let (output, newDir) = CommandRunner.parse(raw)
        #expect(output == "some output\nwith multiple lines")
        #expect(newDir == nil)
    }

    @Test func parseEmptyOutputWithSentinel() {
        let raw = "\n__CAPSULE_PWD__:/Users/me"
        let (output, newDir) = CommandRunner.parse(raw)
        #expect(output == "")
        #expect(newDir == "/Users/me")
    }

    @Test func parsePwdWithSpaces() {
        let raw = "done\n__CAPSULE_PWD__:/Users/me/my projects/foo bar"
        let (output, newDir) = CommandRunner.parse(raw)
        #expect(output == "done")
        #expect(newDir == "/Users/me/my projects/foo bar")
    }

    @Test func parsePwdWithSpecialChars() {
        let raw = "ok\n__CAPSULE_PWD__:/tmp/café & more"
        let (output, newDir) = CommandRunner.parse(raw)
        #expect(output == "ok")
        #expect(newDir == "/tmp/café & more")
    }

    @Test func resultSuccessFlagTrueOnZeroExitCode() {
        let result = CommandRunner.Result(output: "", exitCode: 0, newDirectory: nil)
        #expect(result.success == true)
    }

    @Test func resultSuccessFlagFalseOnNonZeroExitCode() {
        let result = CommandRunner.Result(output: "", exitCode: 1, newDirectory: nil)
        #expect(result.success == false)
    }
}
