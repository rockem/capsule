//
//  CommandRunner.swift
//  capsule
//
//  Created by eli segal on 26/02/2026.
//

import Foundation

enum CommandRunner {
    struct Result {
        let output: String
        let exitCode: Int32
        let newDirectory: String?
        var success: Bool { exitCode == 0 }
    }

    private static let pwdSentinel = "__CAPSULE_PWD__"

    static func run(_ command: String, in directory: String) async -> Result {
        await withCheckedContinuation { cont in
            DispatchQueue.global().async {
                let p = Process()
                let pipe = Pipe()
                let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"

                // cd to current dir, run the command, capture exit code + new PWD
                let escaped = directory.replacingOccurrences(of: "'", with: "'\\''")
                let script = "cd '\(escaped)' 2>/dev/null; \(command); _ec=$?; printf '\\n\(pwdSentinel):%s' \"$PWD\"; exit $_ec"

                p.executableURL = URL(fileURLWithPath: shell)
                p.arguments = ["-l", "-c", script]
                p.standardOutput = pipe
                p.standardError = pipe

                do {
                    try p.run()
                    p.waitUntilExit()
                    let raw = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                                    encoding: .utf8) ?? ""
                    let (output, newDir) = parse(raw)
                    cont.resume(returning: Result(output: output,
                                                  exitCode: p.terminationStatus,
                                                  newDirectory: newDir))
                } catch {
                    cont.resume(returning: Result(output: "Error: \(error.localizedDescription)",
                                                  exitCode: -1,
                                                  newDirectory: nil))
                }
            }
        }
    }

    private static func parse(_ raw: String) -> (output: String, newDir: String?) {
        let marker = "\n\(pwdSentinel):"
        guard let range = raw.range(of: marker) else {
            return (raw.trimmingCharacters(in: .newlines), nil)
        }
        let output = String(raw[..<range.lowerBound]).trimmingCharacters(in: .newlines)
        let newDir = String(raw[range.upperBound...]).trimmingCharacters(in: .newlines)
        return (output, newDir.isEmpty ? nil : newDir)
    }
}
