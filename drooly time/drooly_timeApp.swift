import SwiftUI
import AppKit
import UserNotifications
import AVFoundation

@main
struct GestimerCloneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timer: Timer?
    var remainingTime: TimeInterval = 0
    var defaultTime: TimeInterval = 25 * 60  // 25 minutes default
    var player: AVAudioPlayer?
    var isPaused: Bool = false
    var playPauseMenuItem: NSMenuItem!
    var blinkTimer: Timer?
    var showPausedText: Bool = true
    
    // Menu items
    var contextMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "⏳"
            button.target = self
            button.action = #selector(handleButtonClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        setupContextMenu()
        requestNotificationPermission()
    }
    
    func setupContextMenu() {
        contextMenu = NSMenu()
        
        // Play/Pause Timer option
        playPauseMenuItem = NSMenuItem(title: "Play", action: #selector(togglePlayPause), keyEquivalent: "p")
        contextMenu.addItem(playPauseMenuItem)
        
        // Reset Timer option
        contextMenu.addItem(NSMenuItem(title: "Reset Timer", action: #selector(resetTimer), keyEquivalent: "r"))
        
        // Custom Timer option
        contextMenu.addItem(NSMenuItem(title: "Custom Timer...", action: #selector(showCustomTimerDialog), keyEquivalent: "t"))
        
        // Separator
        contextMenu.addItem(NSMenuItem.separator())
        
        // Preset time options
        let presetMenu = NSMenu()
        [5, 15, 25, 50, 90].forEach { minutes in
            let item = NSMenuItem(title: "\(minutes) minutes", action: #selector(setPresetTime(_:)), keyEquivalent: "")
            item.tag = minutes
            presetMenu.addItem(item)
        }
        
        let presetsItem = NSMenuItem(title: "Presets", action: nil, keyEquivalent: "")
        presetsItem.submenu = presetMenu
        contextMenu.addItem(presetsItem)
        
        // Separator
        contextMenu.addItem(NSMenuItem.separator())
        
        // Quit option
        contextMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        updatePlayPauseMenuItem()
    }
    
    @objc func showCustomTimerDialog() {
        let alert = NSAlert()
        alert.messageText = "Set Custom Timer"
        alert.informativeText = "Enter time in minutes:"
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 24))
        input.stringValue = "\(Int(defaultTime / 60))"
        alert.accessoryView = input
        
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let minutes = Double(input.stringValue), minutes > 0 {
                stopTimer()
                defaultTime = minutes * 60
                remainingTime = defaultTime
                startTimer()
            }
        }
    }
    
    @objc func togglePlayPause() {
        if timer != nil || isPaused {
            togglePause()
        } else if remainingTime > 0 {
            startTimer()
        }
        updatePlayPauseMenuItem()
    }
    
    func updatePlayPauseMenuItem() {
        if timer != nil {
            playPauseMenuItem.title = "Pause"
        } else if isPaused {
            playPauseMenuItem.title = "Resume"
        } else {
            playPauseMenuItem.title = "Play"
        }
    }
    
    @objc func handleButtonClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            updatePlayPauseMenuItem()
            statusItem.menu = contextMenu
            statusItem.button?.performClick(nil)
        } else if event.type == .leftMouseUp {
            if timer == nil && !isPaused {
                // Start a 25-minute timer on left click when no timer is running
                defaultTime = 25 * 60
                remainingTime = defaultTime
                startTimer()
            } else if timer != nil {
                togglePause()
            } else if isPaused {
                startTimer()
            }
        }
    }
    
    func togglePause() {
        if isPaused {
            startTimer()
            isPaused = false
            blinkTimer?.invalidate()
            blinkTimer = nil
        } else {
            timer?.invalidate()
            timer = nil
            isPaused = true
            startBlinkingPausedText()
        }
        updatePlayPauseMenuItem()
        updateStatusBar()
    }
    
    func startBlinkingPausedText() {
        showPausedText = true
        updateStatusBar()
        
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.showPausedText.toggle()
            self.updateStatusBar()
        }
    }
    
    @objc func resetTimer() {
        stopTimer()
        remainingTime = defaultTime
        updateStatusBar()
        updatePlayPauseMenuItem()
    }
    
    @objc func setPresetTime(_ sender: NSMenuItem) {
        stopTimer()
        defaultTime = TimeInterval(sender.tag * 60)
        remainingTime = defaultTime
        startTimer()
        updatePlayPauseMenuItem()
    }
    
    func startTimer() {
        if remainingTime == 0 {
            remainingTime = defaultTime
        }
        
        blinkTimer?.invalidate()
        blinkTimer = nil
        
        updateStatusBar()
        updatePlayPauseMenuItem()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingTime -= 1
            self.updateStatusBar()
            
            if self.remainingTime <= 0 {
                self.stopTimer()
                self.sendNotification()
                self.playSound()
                self.updatePlayPauseMenuItem()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        blinkTimer?.invalidate()
        blinkTimer = nil
        isPaused = false
        updateStatusBar()
        updatePlayPauseMenuItem()
    }
    
    func updateStatusBar() {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        
        if timer != nil {
            // Timer is running
            #if DEBUG
            statusItem.button?.title = String(format: "⏳%d:%02d", minutes, seconds)
            #else
            statusItem.button?.title = String(format: "⏳%d", minutes)
            #endif
        } else if isPaused {
            // Timer is paused - alternate between "PAUSED" and remaining time
            #if DEBUG
            let timeString = String(format: "%d:%02d", minutes, seconds)
            statusItem.button?.title = showPausedText ? "⏸ PAUSED" : "⏸ \(timeString)"
            #else
            statusItem.button?.title = showPausedText ? "⏸ PAUSED" : "⏸ \(minutes)"
            #endif
        } else if remainingTime > 0 {
            // Timer is stopped but has time set
            #if DEBUG
            statusItem.button?.title = String(format: "⏳%d:%02d", minutes, seconds)
            #else
            statusItem.button?.title = String(format: "⏳%d", minutes)
            #endif
        } else {
            // No timer running
            statusItem.button?.title = "⏳"
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time's up!"
        content.body = "Your timer has ended."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}
