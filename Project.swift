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
        dependencies: ["M1"]
    )

    targets += Target.makeFrameworkTargets(
        name: "M1",
        targets: Set([.framework])
    )

    return targets
}

let project = Project(
    name: "Modular-App",
    organizationName: "app.und3fined.com",
    packages: [
//        .package(
//            url: "https://github.com/Alamofire/Alamofire",
//            .upToNextMajor(from: "5.3.0")
//        ),
//        .package(
//            url: "https://github.com/Quick/Quick",
//            .upToNextMajor(from: "3.0.0")
//        ),
//        .package(
//            url: "https://github.com/Quick/Nimble",
//            .upToNextMajor(from: "9.0.0")
//        )
    ],
    settings: Settings(configurations: configurations),
    targets: targets(),
    additionalFiles: ["Project.swift"]
)
