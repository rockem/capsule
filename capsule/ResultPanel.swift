//
//  ResultPanel.swift
//  capsule
//

import SwiftUI

struct ResultPanel: View {
    let result: CommandRunner.Result
    let lastCommand: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("$ \(lastCommand)")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .accessibilityIdentifier("lastCommandHeader")

                Divider()

                Text(result.output)
                    .font(.system(size: 13, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .textSelection(.enabled)
            }
        }
        .defaultScrollAnchor(.bottom)
        .frame(maxHeight: 300)
    }
}
