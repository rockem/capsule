//
//  ContentView.swift
//  capsule
//
//  Created by eli segal on 26/02/2026.
//

import AppKit
import SwiftUI

struct ContentView: View {
    @State private var command = ""
    @State private var result: CommandRunner.Result? = nil
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
                            NSApplication.shared.terminate(nil)
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
                // Output panel
                if isOutputExpanded && !result.output.isEmpty {
                    ScrollView {
                        Text(result.output)
                            .font(.system(size: 13, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .textSelection(.enabled)
                    }
                    .frame(maxHeight: 300)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Status strip — green for success, red for error
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        isOutputExpanded.toggle()
                    }
                } label: {
                    Rectangle()
                        .fill(result.success ? Color.green.opacity(0.75) : Color.red.opacity(0.75))
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 640)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear { focused = true }
    }

    private func runCommand() {
        let cmd = command.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty, !isRunning else { return }
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
