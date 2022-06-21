//
//  AppDelegate.swift
//  Axe
//
//  Created by Linus Skucas on 6/21/22.
//

import Cocoa
import Carbon.HIToolbox.CarbonEventsCore

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var loggerStatus = LoggerStatus.inactive {
        didSet {
            changeStatus()
        }
    }
    var timer: Timer!
    var statusBarMenu: NSMenu!
    
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
        statusBarMenu.addItem(withTitle: "TODO: Launch on Login", action: nil, keyEquivalent: "")
        statusBarMenu.addItem(withTitle: "TODO: Check for Updates...", action: nil, keyEquivalent: "")
        statusBarMenu.addItem(withTitle: "TODO: Axe Help", action: nil, keyEquivalent: "")
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(withTitle: "Quit Axe", action: #selector(quitAxe), keyEquivalent: "q")
        
        return statusBarMenu
    }
    
    func checkOtherActivationsBeforeDisabling() {
        if IsSecureEventInputEnabled() {
            loggerStatus = .activeByOtherApp
        } else {
            loggerStatus = .inactive
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

