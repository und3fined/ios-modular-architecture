import ProjectDescription
import ProjectDescriptionHelpers

let configurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Debug.xcconfig")),
    .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Release.xcconfig")),
]

func targets() -> [Target] {
    var targets: [Target] = []
    targets += Target.makeAppTargets(
        name: "App",
        displayName: "Modular",
        dependencies: [],
        testDependencies: ["Testing"]
    )
    targets += Target.makeFrameworkTargets(
        name: "Testing",
        targets: Set([.framework]),
        dependsOnXCTest: true
    )
    targets += Target.makeFrameworkTargets(name: "UI")
    return targets
}

let project = Project(
    name: "Modular-App",
    organizationName: "app.und3fined.com",
    packages: [],
    settings: Settings(configurations: configurations),
    targets: targets()
)
