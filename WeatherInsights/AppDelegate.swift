import Cocoa // Wichtig: Für NSStatusItem und NSApplication
import SwiftUI // Für die SwiftUI-View im Popover
import AppKit // Enthält NSStatusItem

// Dies ist der App-Delegate, der die Lebenszyklen der App verwaltet
// und den NSStatusItem (das Menüleisten-Symbol) einrichtet.
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. NSStatusItem erstellen (das Menüleisten-Symbol)
        // .variableLength bedeutet, dass die Breite des Symbols an den Inhalt angepasst wird.
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // 2. Das Symbol für die Menüleiste festlegen
        if let button = statusBarItem?.button {
            // Sie können ein System-Image (SF Symbol) verwenden
            button.image = NSImage(systemSymbolName: "cloud.rain.fill", accessibilityDescription: "Wetter")
            // Optional: Titel hinzufügen (Text neben dem Symbol)
            // button.title = "Wetter"
            // Optional: Farbe des Symbols setzen
            // button.contentTintColor = .systemBlue
        }

        // 3. Das Popover erstellen, das angezeigt wird, wenn auf das Symbol geklickt wird
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 600) // Größe des Popovers festlegen
        popover.behavior = .transient // Schließt, wenn außerhalb geklickt wird

        // Setzen Sie den Inhalt des Popovers auf Ihre ContentView
        // Hostet die SwiftUI-View innerhalb eines NSHostingController
        popover.contentViewController = NSHostingController(rootView: ContentView())

        // 4. Aktion definieren, wenn auf das Menüleisten-Symbol geklickt wird
        statusBarItem?.button?.action = #selector(togglePopover)
        statusBarItem?.button?.target = self // Wichtig, damit die Aktion hier ausgeführt wird
    }

    // Funktion zum Anzeigen/Verbergen des Popovers
    @objc func togglePopover() {
        if let button = statusBarItem?.button {
            if popover.isShown {
                popover.performClose(nil) // Popover schließen
            } else {
                // Popover anzeigen relativ zum Menüleisten-Button
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Optional: Fokus auf das Popover legen, damit Eingaben direkt gehen
                // NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }

    // Optional: App komplett beenden über das Menüleisten-Item (wird später hinzugefügt)
    // func applicationWillTerminate(_ notification: Notification) {
    //    print("App wird beendet")
    // }
}
