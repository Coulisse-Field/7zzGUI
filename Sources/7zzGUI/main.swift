import AppKit
import SwiftUI

let locale = LocaleManager()
let delegate = AppDelegate(locale: locale)
let app = NSApplication.shared
app.delegate = delegate
app.setActivationPolicy(.regular)

let contentView = ContentView()
    .environmentObject(delegate)
    .environment(locale)

let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 340, height: 230),
    styleMask: [.titled, .closable, .miniaturizable],
    backing: .buffered,
    defer: false
)
window.title = "7zzGUI"
window.contentView = NSHostingView(rootView: contentView)
window.isReleasedWhenClosed = false

app.activate(ignoringOtherApps: true)

DispatchQueue.main.async {
    window.setContentSize(NSSize(width: 575, height: 675))
    window.center()
    window.makeKeyAndOrderFront(nil)
}

app.run()
