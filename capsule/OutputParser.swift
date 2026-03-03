import Foundation

enum OutputParser {
    static let pwdSentinel = "__CAPSULE_PWD__"

    struct ParsedOutput {
        let output: String
        let newDirectory: String?
    }

    static func parse(_ raw: String) -> ParsedOutput {
        let marker = "\n\(pwdSentinel):"
        guard let range = raw.range(of: marker) else {
            return ParsedOutput(output: raw.trimmingCharacters(in: .newlines), newDirectory: nil)
        }
        let output = String(raw[..<range.lowerBound]).trimmingCharacters(in: .newlines)
        let newDir = String(raw[range.upperBound...]).trimmingCharacters(in: .newlines)
        return ParsedOutput(output: output, newDirectory: newDir.isEmpty ? nil : newDir)
    }
}
