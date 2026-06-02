import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject {
    @Published var extractURL: URL?

    private let locale: LocaleManager
    private var aboutWindow: NSWindow?
    private var prefWindow: NSWindow?
    private var aboutMenuItem: NSMenuItem?
    private var prefsMenuItem: NSMenuItem?
    private var quitMenuItem: NSMenuItem?

    init(locale: LocaleManager) {
        self.locale = locale
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenu()
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshMenu),
            name: .languageChanged, object: nil
        )
    }

    // MARK: - Menu

    private func setupMenu() {
        let mainMenu = NSMenu()
        let appMenu = NSMenu()

        let aboutItem = NSMenuItem(title: locale.t("menu.about"), action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self
        appMenu.addItem(aboutItem)
        aboutMenuItem = aboutItem

        appMenu.addItem(.separator())

        let prefsItem = NSMenuItem(title: locale.t("menu.preferences"), action: #selector(openPreferences), keyEquivalent: ",")
        prefsItem.target = self
        appMenu.addItem(prefsItem)
        prefsMenuItem = prefsItem

        appMenu.addItem(.separator())

        let quitItem = NSMenuItem(title: locale.t("menu.quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(quitItem)
        quitMenuItem = quitItem

        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
    }

    @objc private func refreshMenu() {
        aboutMenuItem?.title = locale.t("menu.about")
        prefsMenuItem?.title = locale.t("menu.preferences")
        quitMenuItem?.title = locale.t("menu.quit")
    }

    @objc private func openAbout() {
        if aboutWindow == nil {
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 280, height: 240),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            w.title = locale.t("about.title")
            w.contentView = NSHostingView(rootView: AboutView().environment(locale))
            w.center()
            w.isReleasedWhenClosed = false
            w.delegate = self
            aboutWindow = w
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func openPreferences() {
        if prefWindow == nil {
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 230),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            w.title = locale.t("pref.title")
            w.contentView = NSHostingView(rootView: PreferencesView().environment(locale))
            w.center()
            w.isReleasedWhenClosed = false
            w.delegate = self
            prefWindow = w
        }
        prefWindow?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        if (notification.object as? NSWindow) == aboutWindow { aboutWindow = nil }
        if (notification.object as? NSWindow) == prefWindow { prefWindow = nil }
    }

    // MARK: - File open

    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first { extractURL = url }
    }

    func application(_ application: NSApplication, openFile filename: String) -> Bool {
        extractURL = URL(fileURLWithPath: filename)
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
