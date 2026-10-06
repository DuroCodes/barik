import AppKit
import Combine
import Foundation

/// An observable manager that periodically updates the system volume.
final class VolumeManager: ObservableObject {
    @Published var volumeLevel: Int = 0
    @Published var isMuted: Bool = false

    private var cancellable: AnyCancellable?

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        // Update every 0.5 seconds to be responsive to volume changes.
        // Use Timer.publish like NowPlayingManager to avoid view update issues
        cancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateVolume()
            }
        updateVolume()
    }

    private func stopMonitoring() {
        cancellable?.cancel()
        cancellable = nil
    }

    /// Updates the current volume level and mute state.
    func updateVolume() {
        // Run AppleScript on background queue to avoid blocking
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Get volume
            let volumeScript = "output volume of (get volume settings)"
            guard let volumeOutput = self.runAppleScript(volumeScript),
                  let volume = Int(volumeOutput.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                return
            }
            
            // Get mute status
            let muteScript = "output muted of (get volume settings)"
            guard let muteOutput = self.runAppleScript(muteScript) else {
                return
            }
            
            let muted = muteOutput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"

            // Update on main thread, but defer to next run loop cycle to avoid view update conflicts
            DispatchQueue.main.async {
                self.volumeLevel = volume
                self.isMuted = muted
            }
        }
    }

    /// Executes the provided AppleScript and returns the trimmed result.
    /// NSAppleScript must run on the main thread.
    @discardableResult
    private func runAppleScript(_ script: String) -> String? {
        var result: String?
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.main.async {
            guard let appleScript = NSAppleScript(source: script) else {
                semaphore.signal()
                return
            }
            var error: NSDictionary?
            let outputDescriptor = appleScript.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript Error: \(error)")
                semaphore.signal()
                return
            }
            result = outputDescriptor.stringValue?.trimmingCharacters(
                in: .whitespacesAndNewlines)
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
}

