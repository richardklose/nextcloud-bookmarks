//
//  PreferencesWindoe.swift
//  Nextcloud Bookmarks
//
//  Created by Richard Klose on 28.07.18.
//  Copyright © 2018 Richard Klose. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var serverTextField: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    var delegate: PreferencesWindowDelegate?
    
    override var windowNibName : NSNib.Name! {
        return NSNib.Name("PreferencesWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        defaults.setValue(serverTextField.stringValue, forKey: "server")
        defaults.setValue(usernameTextField.stringValue, forKey: "username")
        defaults.setValue(passwordTextField.stringValue, forKey: "password")
        delegate?.preferencesDidUpdate()
    }
    
}
