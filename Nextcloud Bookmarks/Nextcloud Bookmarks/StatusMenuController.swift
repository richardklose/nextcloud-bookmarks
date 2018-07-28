//
//  StatusMenuController.swift
//  Nextcloud Bookmarks
//
//  Created by Richard Klose on 27.07.18.
//  Copyright © 2018 Richard Klose. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var prefNote: NSMenuItem!
    @IBOutlet weak var bookmarksMenu: NSMenu!
    @IBOutlet weak var bookmarksMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let bookmarksAPI = BookmarksAPI()
    var preferencesWindow: PreferencesWindow!
    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        updateBookmarks()
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: NSImage.Name(rawValue: "icon"))
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        updateBookmarks()
    }
    
    func updateBookmarks() {
        bookmarksAPI.fetchBookmarks(success: displayBookmarks, failed: displayError)
    }
    
    func preferencesDidUpdate() {
        updateBookmarks()
    }
    
    func displayBookmarks(bookmarks: Array<Bookmark>) {
        prefNote.isHidden = true
        bookmarksMenuItem.isHidden = false
        bookmarksMenu.removeAllItems()
        for bookmark in bookmarks {
            let bookmarkItem = NSMenuItem()
            bookmarkItem.title = bookmark.title
            bookmarkItem.representedObject = bookmark
            bookmarkItem.action = #selector(openBookmark)
            bookmarkItem.target = self
            bookmarkItem.isEnabled = true
            bookmarksMenu.addItem(bookmarkItem)
        }
    }
    
    @objc func openBookmark(sender: NSMenuItem) {
        let bookmark = sender.representedObject as! Bookmark
        NSWorkspace.shared.open(URL(string: bookmark.url)!)
    }
    
    func displayError(error: NSError) {
        prefNote.isHidden = false
        bookmarksMenuItem.isHidden = true
        prefNote.title = "Could not load bookmarks: " + error.domain + ". Please check your preferences!"
    }
}
