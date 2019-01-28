//
//  AppDelegate.swift
//  MetalTryout
//
//  Created by Apollo Zhu on 4/27/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
