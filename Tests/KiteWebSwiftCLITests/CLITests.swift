import Testing
import Foundation
@testable import KiteWebSwiftCLI

@Suite("KiteWebSwiftCLI Tests")
struct CLITests {
    @Test("ReactToSwiftMigrator converts JSX tags and classNames to Swift DSL")
    func testJSXMigration() {
        let migrator = ReactToSwiftMigrator()
        let jsx = """
        <div className="container mx-auto">
            <h1 className="text-2xl font-bold">Hello World</h1>
            <p>Welcome to migration</p>
        </div>
        """
        let swift = migrator.convertJSXToSwift(jsx: jsx)

        #expect(swift.contains("Div {"))
        #expect(swift.contains(".class(\"container mx-auto\")"))
        #expect(swift.contains("H1 {"))
        #expect(swift.contains(".class(\"text-2xl font-bold\")"))
        #expect(swift.contains("P {"))
    }

    @Test("ProjectScaffolder creates template directory structure")
    func testProjectScaffolder() throws {
        let tempDir = NSTemporaryDirectory().appending("kite_test_\(UUID().uuidString)")
        let scaffolder = ProjectScaffolder()

        try scaffolder.scaffold(projectName: "MyTestApp", template: "starter", targetDirectory: tempDir)

        let appDir = URL(fileURLWithPath: tempDir).appendingPathComponent("MyTestApp")
        let packageFile = appDir.appendingPathComponent("Package.swift")
        let mainFile = appDir.appendingPathComponent("Sources/MyTestApp/main.swift")

        #expect(FileManager.default.fileExists(atPath: packageFile.path))
        #expect(FileManager.default.fileExists(atPath: mainFile.path))

        try? FileManager.default.removeItem(atPath: tempDir)
    }
}
