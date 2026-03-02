import Foundation
import Observation

@Observable final class CommandViewModel {
    var command = ""
    var lastCommand = ""
    var result: CommandRunner.Result?
    var isRunning = false
    var isOutputExpanded = false
    var currentDirectory = FileManager.default.homeDirectoryForCurrentUser.path

    func runCommand() {
        let cmd = command.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty, !isRunning else { return }
        lastCommand = cmd
        command = ""
        isRunning = true
        result = nil
        isOutputExpanded = false

        let dir = currentDirectory
        Task {
            let r = await CommandRunner.run(cmd, in: dir)
            result = r
            isRunning = false
            if let newDir = r.newDirectory { currentDirectory = newDir }
            isOutputExpanded = !r.output.isEmpty
        }
    }
}
