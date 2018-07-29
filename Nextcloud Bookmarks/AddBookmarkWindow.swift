//
//  AddBookmarkWindow.swift
//  Nextcloud Bookmarks
//
//  Created by Richard Klose on 28.07.18.
//  Copyright © 2018 Richard Klose. All rights reserved.
//

import Cocoa

protocol AddBookmarkWindowDelegate {
    func addedBookmark()
}

class AddBookmarkWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var errorLabel: NSTextField!
    
    @IBAction func addButtonClicked(_ sender: NSButton) {
        errorLabel.isHidden = true
        bookmarksApi.addBookmark(
            url: urlTextField.stringValue,
            success: done,
            failed: displayError
        )
    }
    
    let bookmarksApi = BookmarksAPI()
    
    var delegate: AddBookmarkWindowDelegate?
    
    override var windowNibName : NSNib.Name! {
        return NSNib.Name("AddBookmarkWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        errorLabel.isHidden = true
        // addButton.isEnabled = false
    }
    
    func done() {
        delegate?.addedBookmark()
    }
    
    func displayError(error: NSError) {
        DispatchQueue.main.async {
            self.errorLabel.isHidden = false
            // TODO: add better error messages
            self.errorLabel.setValue(error.domain, forKey: "stringValue")
        }
    }
    
}
