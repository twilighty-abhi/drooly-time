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
    var defaultTime: TimeInterval = 30 * 60  // 30 minutes default
    var player: AVAudioPlayer?
    var isPaused: Bool = false
    
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
        
        // Reset Timer option
        contextMenu.addItem(NSMenuItem(title: "Reset Timer", action: #selector(resetTimer), keyEquivalent: "r"))
        
        // Preset time options
        let presetMenu = NSMenu()
        [2, 15, 30, 45, 60].forEach { minutes in
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
    }
    
    @objc func handleButtonClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            statusItem.menu = contextMenu
            statusItem.button?.performClick(nil)
        } else {
            if timer != nil {
                togglePause()
            } else if remainingTime > 0 {
                startTimer()
            }
        }
    }
    
    func togglePause() {
        if isPaused {
            // Resume timer
            startTimer()
            isPaused = false
        } else {
            // Pause timer
            timer?.invalidate()
            timer = nil
            isPaused = true
            updateStatusBar()
        }
    }
    
    @objc func resetTimer() {
        stopTimer()
        remainingTime = defaultTime
        isPaused = false
        updateStatusBar()
    }
    
    @objc func setPresetTime(_ sender: NSMenuItem) {
        stopTimer()
        defaultTime = TimeInterval(sender.tag * 60)
        remainingTime = defaultTime
        isPaused = false
        startTimer() // Auto-start timer when preset is selected
    }

    func startTimer() {
        if remainingTime == 0 {
            remainingTime = defaultTime
        }
        
        updateStatusBar()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingTime -= 1
            self.updateStatusBar()
            
            if self.remainingTime <= 0 {
                self.stopTimer()
                self.sendNotification()
                self.playSound()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isPaused = false
        updateStatusBar()
    }
    
    func updateStatusBar() {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        
        #if DEBUG
        // Show minutes and seconds in debug mode
        if timer != nil {
            statusItem.button?.title = isPaused ?
                String(format: "⏸%d:%02d", minutes, seconds) :
                String(format: "%d:%02d", minutes, seconds)
        } else if remainingTime > 0 {
            statusItem.button?.title = String(format: "⏳%d:%02d", minutes, seconds)
        } else {
            statusItem.button?.title = "⏳"
        }
        #else
        // Show only minutes in production
        if timer != nil {
            statusItem.button?.title = isPaused ?
                String(format: "⏸%d", minutes) :
                String(format: "%d", minutes)
        } else if remainingTime > 0 {
            statusItem.button?.title = String(format: "⏳%d", minutes)
        } else {
            statusItem.button?.title = "⏳"
        }
        #endif
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
