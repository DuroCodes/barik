#!/usr/bin/env swift

import AppKit
import Foundation

print("🔍 Checking running applications...\n")

let runningApps = NSWorkspace.shared.runningApplications.compactMap {
    $0.localizedName?.lowercased()
}

print("All running apps (lowercased):")
print(runningApps.sorted().joined(separator: "\n"))
print("\n" + String(repeating: "=", count: 50) + "\n")

print("Looking for: yabai, aerospace, hyprspace\n")
print("Contains 'yabai': \(runningApps.contains("yabai"))")
print("Contains 'aerospace': \(runningApps.contains("aerospace"))")
print("Contains 'hyprspace': \(runningApps.contains("hyprspace"))")

print("\n" + String(repeating: "=", count: 50) + "\n")

print("Checking bundle identifiers:")
let bundleIds = NSWorkspace.shared.runningApplications.compactMap {
    ($0.bundleIdentifier?.lowercased(), $0.localizedName)
}
let relevantBundles = bundleIds.filter { 
    $0.0?.contains("yabai") == true || 
    $0.0?.contains("aerospace") == true || 
    $0.0?.contains("hyprspace") == true 
}

if relevantBundles.isEmpty {
    print("No matching bundle identifiers found")
} else {
    for (bundleId, name) in relevantBundles {
        print("Bundle ID: \(bundleId ?? "nil"), Name: \(name ?? "nil")")
    }
}

print("\n" + String(repeating: "=", count: 50) + "\n")

print("Full details of potentially matching apps:")
for app in NSWorkspace.shared.runningApplications {
    let name = app.localizedName?.lowercased() ?? ""
    let bundleId = app.bundleIdentifier?.lowercased() ?? ""
    
    if name.contains("yabai") || name.contains("aerospace") || name.contains("hyprspace") ||
       bundleId.contains("yabai") || bundleId.contains("aerospace") || bundleId.contains("hyprspace") {
        print("Name: \(app.localizedName ?? "nil")")
        print("Bundle ID: \(app.bundleIdentifier ?? "nil")")
        print("Bundle URL: \(app.bundleURL?.path ?? "nil")")
        print("---")
    }
}




