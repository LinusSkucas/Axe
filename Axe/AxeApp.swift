//
//  AxeApp.swift
//  Axe
//
//  Created by Linus Skucas on 6/21/22.
//

import SwiftUI


@main
struct AxeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
