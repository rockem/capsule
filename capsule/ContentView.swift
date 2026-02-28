import AppKit
import SwiftUI

struct ContentView: View {
    @State private var command = ""
    @State private var lastCommand = ""
    @State private var result: CommandRunner.Result?
    @State private var isRunning = false
    @State private var isOutputExpanded = false
    @State private var currentDirectory = FileManager.default.homeDirectoryForCurrentUser.path
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Input row
            VStack(alignment: .leading, spacing: 4) {
                Text(currentDirectory)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .accessibilityIdentifier("currentDirectoryLabel")

                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))

                    TextField("Enter command…", text: $command)
                        .font(.system(size: 20, design: .monospaced))
                        .textFieldStyle(.plain)
                        .focused($focused)
                        .onSubmit(runCommand)
                        .onKeyPress(.escape) {
                            NSApp.keyWindow?.orderOut(nil)
                            return .handled
                        }
                        .accessibilityIdentifier("commandInputField")

                    if isRunning {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            if let result {
                if isOutputExpanded, !result.output.isEmpty {
                    ResultPanel(result: result, lastCommand: lastCommand)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .frame(width: 640)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear { DispatchQueue.main.async { focused = true } }
    }

    private func runCommand() {
        let cmd = command.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty, !isRunning else { return }
        lastCommand = cmd
        command = ""
        isRunning = true
        result = nil
        isOutputExpanded = false

        let dir = currentDirectory
        Task.detached {
            let r = await CommandRunner.run(cmd, in: dir)
            await MainActor.run {
                result = r
                isRunning = false
                if let newDir = r.newDirectory { currentDirectory = newDir }
                isOutputExpanded = !r.output.isEmpty
            }
        }
    }
}

#Preview {
    ContentView()
}
