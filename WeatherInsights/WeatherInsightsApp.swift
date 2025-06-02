import SwiftUI

@main
struct WeatherInsightsApp: App {
    // Erstelle eine Instanz deines AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Dies ist eine leere WindowGroup.
        // Wenn Sie KEIN separates App-Fenster möchten (nur das Menüleisten-Icon),
        // lassen Sie diese WindowGroup leer und entfernen Sie ContentView hier.
        // Sie können sie auch komplett entfernen, aber es ist gut, eine minimale
        // WindowGroup zu haben, falls macOS sie erwartet.
        WindowGroup {
            // Optional: Wenn Sie ein normales App-Fenster haben möchten, das über ein Menü-Item
            // oder aus dem Dock gestartet werden kann, lassen Sie ContentView hier.
            // Ansonsten können Sie diesen Inhalt leeren.
            // Text("Dieses Fenster kann geschlossen werden.")
            //     .padding()
        }
        .windowResizability(.contentSize) // Passt die Fenstergröße an Inhalt an
        // .windowStyle(.hiddenTitleBar) // Versteckt die Titelleiste

        // Da wir den NSStatusItem verwenden, brauchen wir kein StatusBar-Scene hier.
        // Wir brauchen auch keine Settings-Scene für die reine Menüleisten-Funktionalität.
        // Falls Sie ein "About"-Fenster oder ein Einstellungsfenster möchten,
        // könnten Sie hier eine Settings-Scene oder weitere WindowGroups hinzufügen.
    }
}
