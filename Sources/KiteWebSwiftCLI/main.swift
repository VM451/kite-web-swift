import Foundation

@main
struct CLIMain {
    static func main() async {
        await KiteCLI.run(arguments: CommandLine.arguments)
    }
}
