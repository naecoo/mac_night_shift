import SwiftUI

@main
struct NightShiftApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var nightShift: NightShiftController!
    private var displayManager: DisplayManager!
    private var hotkeyManager: HotkeyManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        nightShift = NightShiftController()
        displayManager = DisplayManager()
        hotkeyManager = HotkeyManager(nightShift: nightShift, displayManager: displayManager)
        
        setupStatusBar()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let menu = NSMenu()
        let menuItem = NSMenuItem()
        menuItem.view = NSHostingView(rootView: NightShiftMenuView().environmentObject(nightShift).environmentObject(displayManager))
        menuItem.view?.frame = NSRect(x: 0, y: 0, width: 280, height: 200)
        
        menu.addItem(menuItem)
        menu.addItem(.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        updateStatusBarIcon()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatusBarIcon()
        }
    }
    
    private func updateStatusBarIcon() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: nightShift.isEnabled ? "moon.fill" : "moon", accessibilityDescription: "Night Shift")
        }
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
