//
//  Setup.swift
//  Modular-AppManifests
//
//  Created by und3fined on 10/21/20.
//

import ProjectDescription

let bundleIdentifier = "com.und3fined.app"
let projectName = "Modular"

public enum modularTarget {
    case example
    case framework
    case tests
    case testing
}

func depensName(_ targetName: String) -> TargetDependency {
    return .target(name: "\(projectName)-\(targetName)")
}

extension Target {
    public static func makeAppTargets(
        name: String,
        displayName: String,
        dependencies: [String] = [],
        testDependencies: [String] = []
    ) -> [Target] {
        let appConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
        ]
        let testsConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
        ]
        let targetDependencies: [TargetDependency] = dependencies.map({ .target(name: $0) })
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "0.0.1",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "LSRequiresIPhoneOS": true,
            "UIApplicationSceneManifest": [
                "UIApplicationSupportsMultipleScenes": true
            ],
            "UILaunchScreen": [],
            "UIApplicationSupportsIndirectInputEvents": true,
            "UIRequiredDeviceCapabilities": ["armv7"],
            "UISupportedInterfaceOrientations": [
                "UIInterfaceOrientationPortrait",
                "UIInterfaceOrientationLandscapeLeft",
                "UIInterfaceOrientationLandscapeRight"
            ],
            "UISupportedInterfaceOrientations~ipad": [
                "UIInterfaceOrientationPortrait",
                "UIInterfaceOrientationPortraitUpsideDown",
                "UIInterfaceOrientationLandscapeLeft",
                "UIInterfaceOrientationLandscapeRight"
            ]
        ]
        
        let targetName = "\(projectName)-\(name)"
        
        return [
            Target(
                name: targetName,
                platform: .iOS,
                product: .app,
                productName: displayName,
                bundleId: "\(bundleIdentifier).\(name)",
                deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Projects/App/Sources/**/*.swift"],
                resources: ["Projects/App/Resources/**/*"],
                dependencies: targetDependencies,
                settings: Settings(configurations: appConfigurations)
            ),
            Target(
                name: "\(targetName)-Tests",
                platform: .iOS,
                product: .unitTests,
                bundleId: "\(bundleIdentifier).\(name).Tests",
                infoPlist: .default,
                sources: ["Projects/App/Tests/**/*.swift"],
                dependencies: [
                    .target(name: targetName),
                    .xctest,
                ] + testDependencies.map({ .target(name: $0) }),
                settings: Settings(configurations: testsConfigurations)
            ),
            Target(
                name: "\(targetName)-UITests",
                platform: .iOS,
                product: .unitTests,
                bundleId: "\(bundleIdentifier).\(name).UITests",
                infoPlist: .default,
                sources: ["Projects/App/UITests/**/*.swift"],
                dependencies: [
                    .target(name: targetName),
                    .xctest,
                ] + testDependencies.map({ .target(name: $0) }),
                settings: Settings(configurations: testsConfigurations)
            ),
        ]
    }
    
    public static func makeFrameworkTargets(
        name: String,
        dependencies: [String] = [],
        testDependencies: [String] = [],
        thirdPartyDependencies: [String] = [],
        thirdPartyTestDependencies: [String] = [],
        targets: Set<modularTarget> = Set([.framework, .tests, .example, .testing]),
        sdks: [String] = [],
        dependsOnXCTest: Bool = false
    ) -> [Target] {
        // Configurations
        let frameworkConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")),
        ]
        let testsConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
        ]
        let appConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
        ]
        
        // Test dependencies
        var targetTestDependencies: [TargetDependency] = [
            .target(name: "\(name)"),
            .xctest,
        ] + testDependencies.map({ .target(name: $0) })
        targetTestDependencies.append(contentsOf: thirdPartyTestDependencies.map  { .package(product: $0) })
        dependencies.forEach { targetTestDependencies.append(.target(name: "\($0)-Testing")) }

        // Target dependencies
        var targetDependencies: [TargetDependency] = dependencies.map { .target(name: $0) }
        targetDependencies.append(contentsOf: thirdPartyDependencies.map { .package(product: $0) })
        targetDependencies.append(contentsOf: sdks.map { .sdk(name: $0) })
        if dependsOnXCTest {
            targetDependencies.append(.xctest)
        }

        // Targets
        var projectTargets: [Target] = []
        if targets.contains(.framework) {
            projectTargets.append(
                Target(
                    name: name,
                    platform: .iOS,
                    product: .framework,
                    bundleId: "\(bundleIdentifier).\(name)",
                    deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                    infoPlist: .default,
                    sources: ["Projects/Modular/\(name)/Sources/**/*.swift"],
                    dependencies: targetDependencies,
                    settings: Settings(configurations: frameworkConfigurations)
                )
            )
        }

        if targets.contains(.testing) {
            projectTargets.append(
                Target(
                    name: "\(name)-Testing",
                    platform: .iOS,
                    product: .framework,
                    bundleId: "\(bundleIdentifier).\(name).Testing",
                    deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                    infoPlist: .default,
                    sources: ["Projects/Modular/\(name)/Testing/**/*.swift"],
                    dependencies: [.target(name: "\(name)"), .xctest],
                    settings: Settings(configurations: frameworkConfigurations)
                )
            )
        }

        if targets.contains(.tests) {
            projectTargets.append(
                Target(
                    name: "\(name)-Tests",
                    platform: .iOS,
                    product: .unitTests,
                    bundleId: "\(bundleIdentifier).\(name).Tests",
                    infoPlist: .default,
                    sources: ["Projects/Modular/\(name)/Tests/**/*.swift"],
                    dependencies: targetTestDependencies,
                    settings: Settings(configurations: testsConfigurations)
                )
            )
        }

        if targets.contains(.example) {
            projectTargets.append(
                Target(
                    name: "\(name)-Example",
                    platform: .iOS,
                    product: .app,
                    bundleId: "\(bundleIdentifier).\(name).Example",
                    deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                    infoPlist: .default,
                    sources: ["Projects/Modular/\(name)/Example/Sources/**/*.swift"],
                    resources: ["Projects/Modular/\(name)/Example/Resources/**"],
                    dependencies: [.target(name: "\(name)")],
                    settings: Settings(configurations: appConfigurations)
                )
            )
        }
        return projectTargets
    }
}
