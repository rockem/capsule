import SwiftUI

struct ResultPanel: View {
    let result: CommandRunner.Result
    let lastCommand: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("$ \(lastCommand)")
                    .font(.system(size: Appearence.Font.commandHeader, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Appearence.Padding.output)
                    .accessibilityIdentifier("lastCommandHeader")

                Divider()

                Text(result.output)
                    .font(.system(size: Appearence.Font.commandOutput, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Appearence.Padding.output)
                    .textSelection(.enabled)
            }
        }
        .defaultScrollAnchor(.bottom)
        .frame(maxHeight: Appearence.outputMaxHeight)
    }
}

#Preview {
    ResultPanel(
        result: CommandRunner.Result(output: "Hello, world!", exitCode: 0, newDirectory: nil),
        lastCommand: "echo Hello, world!"
    )
}
