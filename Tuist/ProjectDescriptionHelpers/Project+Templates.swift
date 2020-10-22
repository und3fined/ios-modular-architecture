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
    case framework
    case tests
    case examples
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
        let targetDependencies: [TargetDependency] = dependencies.map({ depensName($0) })
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
                sources: ["App/Application/**/*.swift"],
                resources: ["App/Resources/**/*"],
                dependencies: targetDependencies,
                settings: Settings(configurations: appConfigurations)
            ),
            Target(
                name: "\(targetName)-Tests",
                platform: .iOS,
                product: .unitTests,
                bundleId: "\(bundleIdentifier).\(name).Tests",
                infoPlist: .default,
                sources: ["App/Tests/**/*.swift"],
                dependencies: [
                    depensName(name),
                    .xctest,
                ] + testDependencies.map({ depensName($0) }),
                settings: Settings(configurations: testsConfigurations)
            ),
            Target(
                name: "\(targetName)-UITests",
                platform: .iOS,
                product: .unitTests,
                bundleId: "\(bundleIdentifier).\(name).UITests",
                infoPlist: .default,
                sources: ["App/UITests/**/*.swift"],
                dependencies: [
                    depensName(name),
                    .xctest,
                ] + testDependencies.map({ depensName($0) }),
                settings: Settings(configurations: testsConfigurations)
            ),
        ]
    }
    
    public static func makeFrameworkTargets(
        name: String,
        dependencies: [String] = [],
        testDependencies: [String] = [],
        targets: Set<modularTarget> = Set([.framework, .tests, .examples, .testing]),
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
            depensName(name),
            .xctest,
        ] + testDependencies.map({ .target(name: $0) })
        dependencies.forEach { targetTestDependencies.append(depensName("\($0)-Testing")) }
        
        // Target dependencies
        var targetDependencies: [TargetDependency] = dependencies.map { depensName($0) }
        targetDependencies.append(contentsOf: sdks.map { .sdk(name: $0) })
        if dependsOnXCTest {
            targetDependencies.append(.xctest)
        }
        
        // Targets
        var projectTargets: [Target] = []
        if targets.contains(.framework) {
            projectTargets.append(
                Target(
                    name: "\(projectName)-\(name)",
                    platform: .iOS,
                    product: .framework,
                    bundleId: "\(bundleIdentifier).\(name)",
                    deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                    infoPlist: .default,
                    sources: ["Modular/\(name)/Sources/**/*.swift"],
                    dependencies: targetDependencies,
                    settings: Settings(configurations: frameworkConfigurations)
                )
            )
        }
        if targets.contains(.testing) {
            projectTargets.append(
                Target(
                    name: "\(projectName)-\(name)-Testing",
                    platform: .iOS,
                    product: .framework,
                    bundleId: "\(bundleIdentifier).\(name).Testing",
                    deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                    infoPlist: .default,
                    sources: ["Modular/\(name)/Testing/**/*.swift"],
                    dependencies: [depensName(name), .xctest],
                    settings: Settings(configurations: frameworkConfigurations)
                )
            )
        }
        if targets.contains(.tests) {
            projectTargets.append(
                Target(
                    name: "\(projectName)-\(name)-Tests",
                    platform: .iOS,
                    product: .unitTests,
                    bundleId: "\(bundleIdentifier).\(name).Tests",
                    infoPlist: .default,
                    sources: ["Modular/\(name)/Tests/**/*.swift"],
                    dependencies: targetTestDependencies,
                    settings: Settings(configurations: testsConfigurations)
                )
            )
        }
        if targets.contains(.examples) {
            projectTargets.append(
                Target(
                    name: "\(projectName)-\(name)-Example",
                    platform: .iOS,
                    product: .app,
                    bundleId: "\(bundleIdentifier).\(name).Example",
                    deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
                    infoPlist: .default,
                    sources: ["Modular/\(name)/Example/Sources/**/*.swift"],
                    resources: ["Modular/\(name)/Example/Resources/**"],
                    dependencies: [depensName(name)],
                    settings: Settings(configurations: appConfigurations)
                )
            )
        }
        return projectTargets
    }
}
