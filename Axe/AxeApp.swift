//
//  AxeApp.swift
//  Axe
//
//  Created by Linus Skucas on 6/21/22.
//

import SwiftUI
import Carbon.HIToolbox.CarbonEventsCore

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var loggerStatus = LoggerStatus.inactive {
        didSet {
            changeStatus()
        }
    }
    var timer: Timer!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        
        guard let button = statusBarItem.button else { return }
        button.image = NSImage(systemSymbolName: loggerStatus.rawValue, accessibilityDescription: nil)
        button.action = #selector(toggleProtection(_:))
        button.sendAction(on: [.leftMouseDown])
        
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
    
    func checkOtherActivationsBeforeDisabling() {
        if IsSecureEventInputEnabled() {
            loggerStatus = .activeByOtherApp
        } else {
            loggerStatus = .inactive
        }
    }
    
    @objc func toggleProtection(_ sender: NSStatusBarButton) {
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

@main
struct AxeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
