import ArgumentParser
import Foundation

@main
struct StackPRs: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "stack-prs",
        abstract: "Restack branches using Graphite (`gt restack`).",
        subcommands: [Restack.self],
        defaultSubcommand: Restack.self
    )

    struct Restack: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Restack a Graphite stack starting from a base branch."
        )

        @Argument(help: "Base branch to restack from.")
        var base: String

        enum Scope: String, ExpressibleByArgument, CaseIterable {
            case upstack
            case downstack
            case only

            var flag: String {
                switch self {
                case .upstack: return "--upstack"
                case .downstack: return "--downstack"
                case .only: return "--only"
                }
            }
        }

        @Option(name: .customLong("scope"), help: "Scope to restack: \(Scope.allCases.map { $0.rawValue }.joined(separator: ", ")). Default: upstack.")
        var scope: Scope = .upstack

        @Flag(name: .customLong("no-interactive"), help: "Disable interactive prompts for `gt restack`.")
        var noInteractive: Bool = false

        @Flag(name: .customLong("no-verify"), help: "Disable git hooks during restack.")
        var noVerify: Bool = false

        func run() throws {
            let runner = CommandRunner()
            try runner.requireCommand("git")
            try runner.requireCommand("gt")
            try runner.ensureInRepo()
            try runner.ensureCleanTree()
            try runner.ensureBranchExists(base)

            var args = ["restack", "--branch", base, scope.flag]
            if noInteractive { args.append("--no-interactive") }
            if noVerify { args.append("--no-verify") }

            print("Running: gt \(args.joined(separator: " "))")
            try runner.run("gt", arguments: args)
        }
    }

    // MARK: - Helpers

    struct CommandRunner {
        func run(_ executable: String, arguments: [String]) throws {
            let resolved = try executablePath(for: executable)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: resolved)
            process.arguments = arguments

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            try process.run()
            process.waitUntilExit()

            if process.terminationStatus != 0 {
                let output = pipe.fileHandleForReading.readDataToEndOfFile()
                let message = String(data: output, encoding: .utf8) ?? ""
                throw CleanError.commandFailed("\(executable) \(arguments.joined(separator: " "))", message)
            }
        }

        func requireCommand(_ command: String) throws {
            do {
                _ = try executablePath(for: command)
            } catch {
                throw CleanError.missingCommand(command)
            }
        }

        func ensureInRepo() throws {
            guard succeeds("git", arguments: ["rev-parse", "--is-inside-work-tree"]) else {
                throw CleanError.notInRepo
            }
        }

        func ensureCleanTree() throws {
            let clean = succeeds("git", arguments: ["diff", "--quiet"]) &&
                succeeds("git", arguments: ["diff", "--cached", "--quiet"])
            guard clean else { throw CleanError.dirtyTree }
        }

        func ensureBranchExists(_ branch: String) throws {
            guard succeeds("git", arguments: ["rev-parse", "--verify", "\(branch)^{commit}"]) else {
                throw CleanError.missingBranch(branch)
            }
        }

        private func succeeds(_ executable: String, arguments: [String]) -> Bool {
            (try? runStatus(executable, arguments: arguments)) == 0
        }

        private func runStatus(_ executable: String, arguments: [String]) throws -> Int32 {
            let resolved = try executablePath(for: executable)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: resolved)
            process.arguments = arguments
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus
        }

        private func executablePath(for command: String) throws -> String {
            if command.contains("/") {
                guard FileManager.default.isExecutableFile(atPath: command) else {
                    throw CleanError.missingCommand(command)
                }
                return command
            }

            guard let pathEnv = ProcessInfo.processInfo.environment["PATH"] else {
                throw CleanError.missingCommand(command)
            }

            for dir in pathEnv.split(separator: ":") {
                let candidate = URL(fileURLWithPath: String(dir)).appendingPathComponent(command).path
                if FileManager.default.isExecutableFile(atPath: candidate) {
                    return candidate
                }
            }

            throw CleanError.missingCommand(command)
        }
    }

    enum CleanError: LocalizedError {
        case missingCommand(String)
        case notInRepo
        case dirtyTree
        case missingBranch(String)
        case commandFailed(String, String)

        var errorDescription: String? {
            switch self {
            case .missingCommand(let cmd):
                return "Required command '\(cmd)' not found in PATH."
            case .notInRepo:
                return "Run inside a git repository."
            case .dirtyTree:
                return "Working tree not clean; commit or stash first."
            case .missingBranch(let branch):
                return "Branch '\(branch)' does not exist."
            case .commandFailed(let cmd, let output):
                let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? "Command failed: \(cmd)" : "Command failed: \(cmd)\n\(trimmed)"
            }
        }
    }
}
