//
//  ViewController.swift
//  MetalTryout
//
//  Created by Apollo Zhu on 4/27/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

//  Tutorial: http://metalkit.org/2016/01/04/introducing-the-metal-framework.html

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var label: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // macOS only. Normally use `MTLCreateSystemDefaultDevice()`
        let devices = MTLCopyAllDevices()
        if devices.isEmpty {
            label.stringValue = "Your GPU does not support Metal!"
        } else {
            label.stringValue = devices
                .reduce("Current system has the following GPU\(devices.count > 1 ? "s" : ""):\n")
                { $0 + "\($1.name)\n" }
        }
    }
}
