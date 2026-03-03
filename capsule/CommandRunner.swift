import Foundation

enum CommandRunner {
    struct Result {
        let output: String
        let exitCode: Int32
        let newDirectory: String?
        var success: Bool { exitCode == 0 }
    }

    static func run(_ command: String, in directory: String) async -> Result {
        await withCheckedContinuation { cont in
            DispatchQueue.global().async {
                let p = Process()
                let pipe = Pipe()
                let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"

                // cd to current dir, run the command, capture exit code + new PWD
                let escaped = directory.replacingOccurrences(of: "'", with: "'\\''")
                let script = "cd '\(escaped)' 2>/dev/null; \(command); _ec=$?; printf '\\n\(OutputParser.pwdSentinel):%s' \"$PWD\"; exit $_ec"

                p.executableURL = URL(fileURLWithPath: shell)
                p.arguments = ["-l", "-c", script]
                p.standardOutput = pipe
                p.standardError = pipe

                do {
                    try p.run()
                    p.waitUntilExit()
                    let raw = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                                     encoding: .utf8) ?? ""
                    let parsed = OutputParser.parse(raw)
                    cont.resume(returning: Result(output: parsed.output,
                                                  exitCode: p.terminationStatus,
                                                  newDirectory: parsed.newDirectory))
                } catch {
                    cont.resume(returning: Result(output: "Error: \(error.localizedDescription)",
                                                  exitCode: -1,
                                                  newDirectory: nil))
                }
            }
        }
    }
}
