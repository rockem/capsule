//
//  ShellSession.swift
//  capsule
//
//  Created by eli segal on 26/02/2026.
//

import Foundation

class ShellSession: ObservableObject {
    @Published var currentDirectory: String

    private let process = Process()
    private let inputPipe = Pipe()
    private let outputPipe = Pipe()
    private let sentinel: String
    private var buffer = ""
    private let queue = DispatchQueue(label: "capsule.shell")
    private var completionHandler: ((String) -> Void)?

    init() {
        currentDirectory = FileManager.default.currentDirectoryPath
        sentinel = "CAPSULE_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"

        let userShell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/sh"
        process.executableURL = URL(fileURLWithPath: userShell)
        process.arguments = ["-l"]   // login shell → user's PATH, aliases, etc.
        process.environment = ProcessInfo.processInfo.environment
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let str = String(data: data, encoding: .utf8) else { return }
            self?.queue.async { self?.receive(str) }
        }

        try? process.run()

        // Drain any shell startup output and capture the initial directory
        write("printf '\(sentinel):%s\\n' \"$PWD\"\n")
    }

    // MARK: - Private

    private func write(_ cmd: String) {
        guard let data = cmd.data(using: .utf8) else { return }
        inputPipe.fileHandleForWriting.write(data)
    }

    private func receive(_ str: String) {
        buffer += str
        let marker = sentinel + ":"
        guard buffer.contains(marker),
              let sentinelRange = buffer.range(of: marker) else { return }
        let rest = String(buffer[sentinelRange.upperBound...])
        guard let newlineIdx = rest.firstIndex(of: "\n") else { return }

        let output = String(buffer[..<sentinelRange.lowerBound])
        let pwd    = String(rest[..<newlineIdx])
        buffer     = String(rest[rest.index(after: newlineIdx)...])

        let handler = completionHandler
        completionHandler = nil

        DispatchQueue.main.async { [weak self] in
            if !pwd.isEmpty { self?.currentDirectory = pwd }
            handler?(output)
        }
    }

    // MARK: - Public

    func run(_ command: String) async -> String {
        await withCheckedContinuation { cont in
            queue.async { [weak self] in
                guard let self else { cont.resume(returning: ""); return }
                completionHandler = { cont.resume(returning: $0) }
                write("\(command)\nprintf '\(sentinel):%s\\n' \"$PWD\"\n")
            }
        }
    }

    deinit {
        try? inputPipe.fileHandleForWriting.close()
        process.terminate()
    }
}
