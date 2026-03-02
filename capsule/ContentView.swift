import AppKit
import SwiftUI

struct ContentView: View {
    @State private var vm = CommandViewModel()
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Input row
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.currentDirectory)
                    .font(.system(size: Appearence.Font.directory, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .accessibilityIdentifier("currentDirectoryLabel")

                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .font(.system(size: Appearence.Font.prompt, weight: .medium, design: .monospaced))

                    TextField("Enter command…", text: $vm.command)
                        .font(.system(size: Appearence.Font.commandInput, design: .monospaced))
                        .textFieldStyle(.plain)
                        .focused($focused)
                        .onSubmit(vm.runCommand)
                        .onKeyPress(.escape) {
                            NSApp.keyWindow?.orderOut(nil)
                            return .handled
                        }
                        .accessibilityIdentifier("commandInputField")

                    if vm.isRunning {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            .padding(.horizontal, Appearence.Padding.input)
            .padding(.vertical, Appearence.Padding.input)

            if let result = vm.result {
                if vm.isOutputExpanded, !result.output.isEmpty {
                    ResultPanel(result: result, lastCommand: vm.lastCommand)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .frame(width: Appearence.panelWidth)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Appearence.cornerRadius))
        .onAppear { DispatchQueue.main.async { focused = true } }
    }
}

#Preview {
    ContentView()
}
