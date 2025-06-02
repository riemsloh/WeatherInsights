//
//  SettingsView.swift
//  WeatherInsights
//
//  Created by Olaf Lueg on 01.06.25.
//


import SwiftUI

struct SettingsView: View {
    // Diese @Binding-Variablen werden von der ContentView übergeben.
    // Änderungen hier wirken sich direkt auf die @AppStorage-Variablen in ContentView aus.
    @Binding var meteostatAPIKey: String
    @Binding var meteostatAPIHost: String
    @Binding var wuAPIKey: String
    @Binding var wuStationID: String

    // Dieses Binding wird verwendet, um das Einstellungs-Sheet zu schließen.
    @Binding var showingSettings: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Einstellungen")
                .font(.largeTitle)
                .padding(.bottom)

            VStack(alignment: .leading, spacing: 10) {
                Text("Meteostat API Einstellungen")
                    .font(.headline)
                TextField("Ihr X-RapidAPI-Key für Meteostat", text: $meteostatAPIKey)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)

                TextField("Ihr X-RapidAPI-Host für Meteostat (z.B. meteostat.p.rapidapi.com)", text: $meteostatAPIHost)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Weather Underground API Einstellungen")
                    .font(.headline)
                TextField("Ihr Weather Underground API Key", text: $wuAPIKey)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)

                TextField("Ihre Weather Underground Station ID (z.B. IMELLE143)", text: $wuStationID)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
            }

            Spacer()

            Button("Einstellungen speichern & schließen") {
                // Da wir @Binding verwenden, werden die Änderungen automatisch in
                // den @AppStorage-Variablen der ContentView gespeichert.
                // Hier müssen wir nur noch das Sheet schließen.
                showingSettings = false
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large) // Macht den Button etwas größer
        }
        .padding(30) // Mehr Polsterung um den Inhalt
        .frame(minWidth: 500, idealWidth: 550, maxWidth: .infinity, minHeight: 450, idealHeight: 500, maxHeight: .infinity) // Größe des Dialogs
    }
}

// Vorschau für Xcode Canvas
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Für die Vorschau Dummy-Bindings verwenden
        SettingsView(
            meteostatAPIKey: .constant("dummy-meteostat-key-preview"),
            meteostatAPIHost: .constant("dummy-meteostat-host-preview"),
            wuAPIKey: .constant("dummy-wu-key-preview"),
            wuStationID: .constant("DUMMY123"),
            showingSettings: .constant(true) // Hier auf true, damit das Sheet in der Vorschau angezeigt wird
        )
    }
}
