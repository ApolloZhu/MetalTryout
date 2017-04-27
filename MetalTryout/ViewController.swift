//
//  ViewController.swift
//  MetalTryout
//
//  Created by Apollo Zhu on 4/27/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let devices = MTLCopyAllDevices()
        guard devices.count > 0 else {
            fatalError("Your GPU does not support Metal!")
        }
        label.stringValue =
        devices.reduce("Your system has the following GPU\(devices.count>1 ? "s" : ""):\n") { $0 + "\($1.name!)\n" }
    }

}

