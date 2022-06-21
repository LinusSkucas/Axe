//
//  AppDelegate.swift
//  Axe
//
//  Created by Linus Skucas on 6/21/22.
//

import Cocoa
import Carbon.HIToolbox.CarbonEventsCore
import LaunchAtLogin

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var loggerStatus = LoggerStatus.inactive {
        didSet {
            changeStatus()
        }
    }
    var timer: Timer!
    var statusBarMenu: NSMenu!
    
    let defaults = UserDefaults.standard
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        
        guard let button = statusBarItem.button else { return }
        button.image = NSImage(systemSymbolName: loggerStatus.rawValue, accessibilityDescription: nil)
        button.action = #selector(toggleProtection(_:))
        button.sendAction(on: [.leftMouseDown, .rightMouseDown])
        
        checkOtherActivationsBeforeDisabling()
        
        
        // Setup Timer
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(checkOtherActiviations), userInfo: nil, repeats: true)
        timer.tolerance = 7.0
        RunLoop.current.add(timer, forMode: .common)
    }
    
    
    func changeStatus() {
        guard let button = statusBarItem.button else { return }
        
        button.image = NSImage(systemSymbolName: loggerStatus.rawValue, accessibilityDescription: nil)
    }
    
    func createMenu() -> NSMenu {
        statusBarMenu = NSMenu(title: "Axe")
        
        let statusItem = NSMenuItem()
        switch loggerStatus {
        case .inactive:
            statusItem.title = "Secure Input Inactive"
        case .active:
            statusItem.title = "Secure Input Active"
        case .activeByOtherApp:
            statusItem.title = "Secure Input Active by Another App"
        }
        statusItem.isEnabled = false
        
        statusBarMenu.addItem(statusItem)
        statusBarMenu.addItem(NSMenuItem.separator())
        
        let launchOnLoginItem = NSMenuItem()
        launchOnLoginItem.title = "Launch Axe on Login"
        launchOnLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        launchOnLoginItem.action = #selector(toggleLaunchOnLogin)
        statusBarMenu.addItem(launchOnLoginItem)
        
        statusBarMenu.addItem(withTitle: "TODO: Check for Updates...", action: nil, keyEquivalent: "")
        statusBarMenu.addItem(withTitle: "TODO: Axe Help", action: nil, keyEquivalent: "")
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(withTitle: "Quit Axe\(mustQuitWithAlert() ? "..." : "")", action: #selector(quitAxe), keyEquivalent: "q")
        
        return statusBarMenu
    }
    
    func checkOtherActivationsBeforeDisabling() {
        if IsSecureEventInputEnabled() {
            loggerStatus = .activeByOtherApp
        } else {
            loggerStatus = .inactive
        }
    }
    
    private func mustQuitWithAlert() -> Bool {
        return loggerStatus == .active && (defaults.bool(forKey: AxeDefaultKeys.quitAlertSuppression.rawValue) == false)
    }
    
    @objc func toggleLaunchOnLogin() {
        LaunchAtLogin.isEnabled.toggle()
    }
    
    }
    
    @objc func quitAxe() {
        if mustQuitWithAlert() {
            let quitAlert = NSAlert()
            quitAlert.alertStyle = .critical
            quitAlert.icon = NSImage(named: "NXUpdate")!
            
            quitAlert.messageText = "Secure Input is Still Enabled"
            quitAlert.informativeText = "Quitting Axe will disable Secure Input."
            
            quitAlert.showsSuppressionButton = true
            quitAlert.suppressionButton?.title = "Do not show this warning again"
            
            quitAlert.showsHelp = true
            
            quitAlert.addButton(withTitle: "Cancel")
            quitAlert.addButton(withTitle: "Quit Axe")
            
            let response = quitAlert.runModal()
            
            if let suppressionButton = quitAlert.suppressionButton,
               suppressionButton.state == .on {
                defaults.set(true, forKey: AxeDefaultKeys.quitAlertSuppression.rawValue)
            }
            
            guard response == .alertSecondButtonReturn else { return }
        }
        NSApp.terminate(nil)
    }
    
    @objc func toggleProtection(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == NSEvent.EventType.leftMouseDown {
            switch loggerStatus {
            case .inactive:
                EnableSecureEventInput()
                loggerStatus = .active
            case .active:
                DisableSecureEventInput()
                checkOtherActivationsBeforeDisabling()
            case .activeByOtherApp:
                loggerStatus = .active
            }
        } else if event.type == NSEvent.EventType.rightMouseDown {
            statusBarItem.menu = createMenu()
            statusBarItem.button?.performClick(nil)
            statusBarItem.menu = nil
        }
    }
    
    @objc func checkOtherActiviations(timer: Timer) {
        guard loggerStatus != .active else { return }
        
        if IsSecureEventInputEnabled() {
            loggerStatus = .activeByOtherApp
        } else {
            loggerStatus = .inactive
        }
    }
}

