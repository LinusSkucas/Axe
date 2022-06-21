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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        
        guard let button = statusBarItem.button else { return }
        button.image = NSImage(systemSymbolName: loggerStatus.rawValue, accessibilityDescription: nil)
        button.action = #selector(toggleProtection(_:))
        button.sendAction(on: [.leftMouseDown])
        
        checkOtherActivations()
    }
    
    func changeStatus() {
        guard let button = statusBarItem.button else { return }
        
        button.image = NSImage(systemSymbolName: loggerStatus.rawValue, accessibilityDescription: nil)
    }
    
    func checkOtherActivations() {
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
            checkOtherActivations()
        case .activeByOtherApp:
            loggerStatus = .active
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
