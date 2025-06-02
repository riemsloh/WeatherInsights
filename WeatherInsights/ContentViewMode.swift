import SwiftUI
import Foundation
import Charts // Stellen Sie sicher, dass Charts importiert ist


// MARK: - ContentViewMode Enum

enum ContentViewMode: String, CaseIterable, Identifiable {
    case summary = "Übersicht"
    case meteostatChart = "Meteostat Verlauf"
    case wuCurrent = "WU Aktuell"
    case wuHistorical = "WU Verlauf (24h)"

    var id: String { self.rawValue }
}

// --- NEU: Datenmodelle für die Historische Weather Underground API-Antwort (PWS Recent History - 1 Day) ---
// Diese Strukturen bilden die JSON-Antwort der Historical PWS API ab.

struct WUHistoricalAPIResponse: Codable {
    let observations: [WUHistoricalObservation]?
}

struct WUHistoricalObservation: Codable, Identifiable {
    var id: String { obsTimeUtc } // UTC-Zeit als eindeutige ID

    let stationID: String?
    let tz: String? // Time zone of PWS [cite: 1]
    let obsTimeUtc: String // GMT(UTC) time [cite: 1]
    let obsTimeLocal: String? // Time observation is valid in local apparent time by timezone [cite: 1]
    let epoch: Int? // Time in UNIX seconds [cite: 1]
    let lat: Double? // Latitude of PWS [cite: 1]
    let lon: Double? // Longitude of PWS [cite: 1]
    let qcStatus: Int? // Quality control indicator [cite: 1]

    // Durchschnittliche Werte für den Zeitraum
    let humidityAvg: Int? // Average Humidity of the period [cite: 1]
    let humidityHigh: Int? // Highest Humidity of the period [cite: 1]
    let humidityLow: Int? // Lowest Humidity of the period [cite: 1]
    let solarRadiationHigh: Double? // Highest Solar Radiation of the period [cite: 2]
    let uvHigh: Double? // Highest UV Index of the period [cite: 2]
    let winddirAvg: Int? // Wind direction average of the period [cite: 2]


    // Die Einheiten-Objekte (metric, imperial etc.) für historische Daten
    let metric: WUHistoricalMetricUnits? // Object containing fields that use a defined unit of measure. [cite: 2]
    let imperial: WUHistoricalImperialUnits? // Object containing fields that use a defined unit of measure. [cite: 2]
    // Fügen Sie hier uk_hybrid oder metric_si hinzu, falls benötigt [cite: 2]
}

struct WUHistoricalMetricUnits: Codable {
    let tempHigh: Double? // High Temperature of the period [cite: 2]
    let tempLow: Double? // Low Temperature of the period [cite: 2]
    let tempAvg: Double? // Temperature average of the period [cite: 2]
    let windspeedHigh: Double? // Highest Wind speed of the period [cite: 3]
    let windspeedLow: Double? // Lowest Wind speed of the period [cite: 3]
    let windspeedAvg: Double? // Wind speed average of the period [cite: 2]
    let windgustHigh: Double? // Highest Wind gust of the period [cite: 2]
    let windgustLow: Double? // Lowest Wind gust of the period [cite: 2]
    let windgustAvg: Double? // Wind gust average of the period [cite: 2]
    let dewptHigh: Double? // Maximum dew point of the period [cite: 2]
    let dewptLow: Double? // Minimum dew point of the period [cite: 2]
    let dewptAvg: Double? // Average dew point of the period [cite: 2]
    let windchillHigh: Double? // High Windchill temperature of the period [cite: 2]
    let windchillLow: Double? // Low Windchill temperature of the period [cite: 2]
    let windchillAvg: Double? // Windchill average of the period [cite: 2]
    let heatindexHigh: Double? // Heat index high temperature of the period [cite: 2]
    let heatindexLow: Double? // Heat index low temperature of the period [cite: 2]
    let heatindexAvg: Double? // Heat index average of the period [cite: 2]
    let pressureMax: Double? // Highest Barometric pressure in defined unit of measure of the period [cite: 2]
    let pressureMin: Double? // Lowest Barometric pressure in defined unit of measure of the period [cite: 2]
    let pressureTrend: Double? // Pressure tendency over the preceding period [cite: 2]
    let precipRate: Double? // Rate of precipitation - instantaneous precipitation rate. [cite: 2]
    let precipTotal: Double? // Accumulated Rain for the day in defined unit of measure [cite: 2]
}

// Wenn Sie imperiale Einheiten verwenden möchten, definieren Sie auch diese Struktur:
struct WUHistoricalImperialUnits: Codable {
    // Fügen Sie hier die entsprechenden imperialen Felder ein, analog zu WUMetricUnits
    // Beispiel:
    let tempHigh: Double?
    let tempLow: Double?
    let tempAvg: Double?
    // ... und so weiter für alle relevanten Felder
}

// --- Meteostat API Datenmodelle (für historische Daten) ---
// Diese müssen vorhanden sein, da sie in fetchMeteostatData verwendet werden
struct MeteostatAPIResponse: Codable {
    let data: [DailyWeatherData]?
}

struct DailyWeatherData: Codable, Identifiable {
    let date: String
    let tavg: Double? // Durchschnittstemperatur
    let tmin: Double? // Minimum Temperatur
    let tmax: Double? // Maximum Temperatur
    let prcp: Double? // Niederschlag
    let snow: Double? // Schneefall
    let wspd: Double? // Windgeschwindigkeit
    let pres: Double? // Luftdruck
    let tsun: Double? // Sonnenstunden
    
    var id: String { date } // Datum als eindeutige ID
}


// --- Weather Underground API Datenmodelle (für aktuelle Daten) ---
// Diese sind neu und werden für fetchWeatherUndergroundData verwendet
struct WUAPIResponse: Codable {
    let observations: [WUObservation]?
}

struct WUObservation: Codable, Identifiable {
    var id: String { obsTimeUtc } // UTC-Zeit als eindeutige ID
    let stationID: String?
    let obsTimeUtc: String
    let obsTimeLocal: String?
    let neighborhood: String?
    let softwareType: String?
    let country: String?
    let solarRadiation: Double?
    let lon: Double?
    let realtimeFrequency: Int?
    let epoch: Int?
    let lat: Double?
    let uv: Double?
    let winddir: Int?
    let humidity: Int?
    let qcStatus: Int?
    
    let metric: WUMetricUnits?
    let imperial: WUImperialUnits? // Falls Sie imperiale Daten nutzen
}

struct WUMetricUnits: Codable {
    let temp: Double?
    let heatIndex: Double?
    let dewpt: Double?
    let windChill: Double?
    let windSpeed: Double?
    let windGust: Double?
    let pressure: Double?
    let precipRate: Double?
    let precipTotal: Double?
    let elev: Double?
}

struct WUImperialUnits: Codable {
    let temp: Double?
    let heatIndex: Double?
    let dewpt: Double?
    let windChill: Double?
    let windSpeed: Double?
    let windGust: Double?
    let pressure: Double?
    let precipRate: Double?
    let precipTotal: Double?
    let elev: Double?
}


// --- ContentView: Die Hauptansicht Ihrer App ---
struct ContentView: View {
    // Meteostat-Daten
    @State private var meteostatData: [DailyWeatherData] = []
    @State private var isLoadingMeteostat = false
    @State private var errorMessageMeteostat: String?
    
    // Weather Underground Daten
    @State private var wuCurrentObservation: WUObservation?
    @State private var isLoadingWU = false
    @State private var errorMessageWU: String?
    
    // NEU: Weather Underground Historische Daten
        @State private var wuHistoricalObservations: [WUHistoricalObservation] = []
        @State private var isLoadingWUHistorical = false
        @State private var errorMessageWUHistorical: String?
    
    @State private var currentMode: ContentViewMode = .summary
     @State private var showingSettings = false // <-- Stellen Sie sicher, dass diese Zeile vorhanden ist

     // Diese müssen mit @AppStorage definiert sein!
     @AppStorage("meteostatAPIKey") var meteostatAPIKey: String = "DEIN_X_RAPIDAPI_KEY_HIER_EINSETZEN"
     @AppStorage("meteostatAPIHost") var meteostatAPIHost: String = "meteostat.p.rapidapi.com"
     @AppStorage("wuAPIKey") var wuAPIKey: String = "DEIN_WU_API_KEY_HIER_EINSETZEN"
     @AppStorage("wuStationID") var wuStationID: String = "DEINE_WU_STATION_ID_HIER_EINSETZEN"

    // NEU: Timer-Publisher für Weather Underground Daten
    // Sendet alle 60 Sekunden einen Event.
    // 'tolerance' ist optional und gibt an, wie flexibel der Timer sein darf.
    // 'RunLoop.current' stellt sicher, dass der Timer auf dem Haupt-Thread läuft.
    // 'mode: .common' ist gut für UI-Apps.
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text("Wetterdaten-Analyse")
                .font(.largeTitle)
                .padding(.bottom)
            
            // --- Meteostat-Diagramm-Ansicht ---
            if isLoadingMeteostat {
                ProgressView("Lade historische Daten...")
                    .frame(height: 250)
            } else if let errorMessage = errorMessageMeteostat {
                Text("Fehler (Meteostat): \(errorMessage)")
                    .foregroundColor(.red)
                    .frame(height: 250)
            } else if !meteostatData.isEmpty {
                Chart {
                    ForEach(meteostatData) { dayData in
                        if let prcp = dayData.prcp {
                            BarMark(
                                x: .value("Datum", dayData.date),
                                y: .value("Niederschlag (mm)", prcp)
                            )
                            .foregroundStyle(Color.blue)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let dateString = value.as(String.self) {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                if let date = dateFormatter.date(from: dateString) {
                                    let displayFormatter = DateFormatter()
                                    displayFormatter.dateFormat = "MMM dd"
                                    return Text(displayFormatter.string(from: date))
                                        .font(.caption)
                                }
                            }
                            return Text("")
                        }
                    }
                }
                .chartYAxisLabel("Niederschlag (mm)")
                .frame(height: 250)
                .padding()
            }
            
            Divider().padding(.vertical)
            
            // --- Weather Underground Aktuelle Bedingungen Ansicht ---
            Text("Aktuelle Bedingungen (Melle)")
                .font(.title2)
                .padding(.bottom, 5)
            
            if isLoadingWU {
                ProgressView("Lade aktuelle Wetterdaten...")
            } else if let errorMessage = errorMessageWU {
                Text("Fehler (WU): \(errorMessage)")
                    .foregroundColor(.red)
            } else if let observation = wuCurrentObservation {
                VStack(alignment: .leading) {
                    Text("Station ID: \(observation.stationID ?? "N/A")")
                    Text("Letzte Aktualisierung (UTC): \(observation.obsTimeUtc)")
                    if let temp = observation.metric?.temp {
                        Text("Temperatur: \(String(format: "%.1f", temp)) °C")
                    }
                    if let humidity = observation.humidity {
                        Text("Luftfeuchtigkeit: \(humidity)%")
                    }
                    if let precipTotal = observation.metric?.precipTotal {
                        Text("Niederschlag heute: \(String(format: "%.1f", precipTotal)) mm")
                    }
                    if let windSpeed = observation.metric?.windSpeed {
                        Text("Windgeschwindigkeit: \(String(format: "%.1f", windSpeed)) km/h")
                    }
                    if let pressure = observation.metric?.pressure {
                        Text("Druck: \(String(format: "%.1f", pressure)) hPa")
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Keine aktuellen Weather Underground Daten verfügbar.")
            }
            Divider()
                .padding(.vertical) // Eine weitere Trennlinie
            
            // --- NEU: Weather Underground Historisches Diagramm (letzter Tag) ---
            Text("Temperaturverlauf (Letzter Tag)")
                .font(.title2)
                .padding(.bottom, 5)
            
            if isLoadingWUHistorical {
                ProgressView("Lade historischen Temperaturverlauf...")
                    .frame(height: 250)
            } else if let errorMessage = errorMessageWUHistorical {
                Text("Fehler (WU Historie): \(errorMessage)")
                    .foregroundColor(.red)
                    .frame(height: 250)
            } else if !wuHistoricalObservations.isEmpty {
                Chart {
                    ForEach(wuHistoricalObservations) { observation in
                        // Zeitliche Achse: Umwandlung von ISO 8601 String zu Date
                        let dateFormatter = ISO8601DateFormatter()
                        if let date = dateFormatter.date(from: observation.obsTimeUtc) {
                            
                            // Durchschnittstemperatur
                            if let tempAvg = observation.metric?.tempAvg {
                                LineMark(
                                    x: .value("Uhrzeit", date),
                                    y: .value("Temperatur (°C)", tempAvg)
                                )
                                .foregroundStyle(by: .value("Messwert", "Durchschnitt"))
                                .symbol(by: .value("Messwert", "Durchschnitt"))
                                .interpolationMethod(.cardinal)
                            }
                            
                            // Höchsttemperatur
                            if let tempHigh = observation.metric?.tempHigh {
                                LineMark(
                                    x: .value("Uhrzeit", date),
                                    y: .value("Temperatur (°C)", tempHigh)
                                )
                                .foregroundStyle(by: .value("Messwert", "Höchst"))
                                .symbol(by: .value("Messwert", "Höchst"))
                                .interpolationMethod(.cardinal)
                            }
                            
                            // Tiefsttemperatur
                            if let tempLow = observation.metric?.tempLow {
                                LineMark(
                                    x: .value("Uhrzeit", date),
                                    y: .value("Temperatur (°C)", tempLow)
                                )
                                .foregroundStyle(by: .value("Messwert", "Tiefst"))
                                .symbol(by: .value("Messwert", "Tiefst"))
                                .interpolationMethod(.cardinal)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                let displayFormatter = DateFormatter()
                                displayFormatter.dateFormat = "HH:mm" // Stunde:Minute
                                return Text(displayFormatter.string(from: date))
                                    .font(.caption2)
                            }
                            return Text("")
                        }
                    }
                }
                .chartYAxisLabel("Temperatur (°C)")
                .chartLegend(position: .topLeading)
                .frame(height: 250) // Gleiche Höhe wie Meteostat-Diagramm
                .padding()
            } else {
                Text("Keine historischen WU-Daten verfügbar.")
                    .frame(height: 250)
            }
            Spacer()
            
            HStack {
                Button("Meteostat Daten abrufen") {
                    //fetchMeteostatData()
                }
                .padding(.horizontal)
                
                Button("WU Daten abrufen") {
                    fetchWeatherUndergroundData()
                }
                .padding(.horizontal)
                
                Button("WU Historie (1 Tag)") {
                    fetchWeatherUndergroundHistoricalData()
                }
                .padding(.horizontal)
                Divider() // Eine Trennlinie, falls vorhanden. Wenn nicht, fügen Sie sie hinzu oder platzieren Sie den Button entsprechend.

                // Dies ist der Code für den fehlenden "Einstellungen"-Button:
                Button(action: {
                    showingSettings = true // <-- Dieser Button setzt die @State-Variable auf true
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill") // Zahnrad-Symbol
                            .font(.title)
                        Text("Einstellungen")
                        Spacer() // Drückt Text und Symbol nach links
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1)) // Leichter grauer Hintergrund
                    .cornerRadius(10) // Abgerundete Ecken
                }
                .buttonStyle(.plain) // Standard SwiftUI-Button-Style ohne Kanten
            }
            // NEU: App beenden Button
            Button(
                "App beenden"
            ) {
                NSApplication.shared
                    .terminate(
                        nil
                    ) // Beendet die macOS-Anwendung
            }
            .buttonStyle(
                .borderedProminent
            ) // Visuell hervorheben
            .tint(
                .red
            ) // Macht den Button rot (signalisiert "Beenden")
            .padding(
                .bottom
            ) // Abstand zum unteren Rand des Popovers
        } // Ende des äußeren VStack
        .padding()
        .onAppear {
           // fetchMeteostatData()
            fetchWeatherUndergroundData()
        }
        // --- HIER KOMMT DER NEUE onReceive-MODIFIKATOR FÜR DEN TIMER ---
        .onReceive(timer) { _ in
            print("Timer ausgelöst: Lade WU Daten...")
            fetchWeatherUndergroundData() // Wird alle 60 Sekunden aufgerufen
        }
        // NEU: Der Sheet-Modifikator, der die SettingsView anzeigt
        .sheet(isPresented: $showingSettings) { // <-- Stellen Sie sicher, dass dieser Block vorhanden ist
            SettingsView(
                meteostatAPIKey: $meteostatAPIKey,
                meteostatAPIHost: $meteostatAPIHost,
                wuAPIKey: $wuAPIKey,
                wuStationID: $wuStationID,
                showingSettings: $showingSettings
            )
        }
    }
    
    private var summaryView: some View {
           VStack(spacing: 15) {
               // ... (Ihre bestehenden Buttons) ...

               Divider()

               // NEU: Einstellungen-Button in der Summary View
               Button(action: {
                   showingSettings = true // <-- Dieser Button öffnet das Sheet
               }) {
                   HStack {
                       Image(systemName: "gearshape.fill")
                           .font(.title)
                       Text("Einstellungen")
                       Spacer()
                   }
                   .padding()
                   .background(Color.gray.opacity(0.1))
                   .cornerRadius(10)
               }
               .buttonStyle(.plain)
           }
           .padding(.horizontal)
       }
    
    // --- Funktion zum Abrufen der Meteostat-Daten ---
    func fetchMeteostatData() {
        isLoadingMeteostat = true
        errorMessageMeteostat = nil
        meteostatData = []
        
        let latitude = 52.2033 // Melle Breitengrad
        let longitude = 8.3373 // Melle Längengrad
        let startDate = "2024-01-01"
        let endDate = "2024-01-31"
        
        guard let url = URL(string: "https://meteostat.p.rapidapi.com/point/daily?lat=\(latitude)&lon=\(longitude)&start=\(startDate)&end=\(endDate)") else {
            errorMessageMeteostat = "Ungültige Meteostat URL"
            isLoadingMeteostat = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(meteostatAPIKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue(meteostatAPIHost, forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoadingMeteostat = false
                
                if let error = error {
                    errorMessageMeteostat = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    errorMessageMeteostat = "HTTP Fehler (Meteostat): \(statusCode)"
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        errorMessageMeteostat! += "\n\(errorString)"
                    }
                    return
                }
                
                guard let data = data else {
                    errorMessageMeteostat = "Keine Daten von der Meteostat API erhalten."
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(MeteostatAPIResponse.self, from: data)
                    
                    if let fetchedData = decodedResponse.data, !fetchedData.isEmpty {
                        meteostatData = fetchedData.sorted { $0.date < $1.date }
                        print("Meteostat Daten erfolgreich geladen. Anzahl Einträge: \(meteostatData.count)")
                    } else {
                        errorMessageMeteostat = "Meteostat API hat keine Wetterdaten für den Zeitraum zurückgegeben."
                    }
                } catch {
                    errorMessageMeteostat = "Fehler beim Dekodieren der Meteostat Daten: \(error.localizedDescription)"
                    print("Meteostat Dekodierungsfehler: \(error)")
                    print("Meteostat Rohdaten (falls verfügbar): \(String(data: data, encoding: .utf8) ?? "Keine Rohdaten")")
                }
            }
        }.resume()
    }
    
    
    // --- Funktion zum Abrufen der Weather Underground Daten ---
    func fetchWeatherUndergroundData() {
        isLoadingWU = true
        errorMessageWU = nil
        wuCurrentObservation = nil
        
        let apiUrl = "https://api.weather.com/v2/pws/observations/current?stationId=\(wuStationID)&format=json&units=m&apiKey=\(wuAPIKey)"
        
        guard let url = URL(string: apiUrl) else {
            errorMessageWU = "Ungültige Weather Underground URL"
            isLoadingWU = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoadingWU = false
                
                if let error = error {
                    errorMessageWU = error.localizedDescription
                    print("WU Netzwerkfehler: \(error.localizedDescription)") // Zusätzlicher Log
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessageWU = "Ungültige HTTP-Antwort (WU)"
                    print("WU: Ungültige HTTP-Antwort.") // Zusätzlicher Log
                    return
                }
                
                // --- NEUER DEBUG-CODE HIER ---
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("WU HTTP Status Code: \(httpResponse.statusCode)")
                    print("WU Rohdaten (immer): \(responseString)")
                } else {
                    print("WU: Keine Rohdaten empfangen oder Daten konnten nicht in String umgewandelt werden.")
                }
                // --- ENDE NEUER DEBUG-CODE ---
                
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = httpResponse.statusCode
                    errorMessageWU = "HTTP Fehler (WU): \(statusCode)"
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        errorMessageWU! += "\n\(errorString)"
                    }
                    return
                }
                
                guard let data = data else {
                    errorMessageWU = "Keine Daten von der Weather Underground API erhalten."
                    print("WU: 'data' ist nil trotz 2xx Statuscode.") // Zusätzlicher Log
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(WUAPIResponse.self, from: data)
                    
                    if let observation = decodedResponse.observations?.first {
                        self.wuCurrentObservation = observation
                        print("Weather Underground Daten erfolgreich geladen.")
                    } else {
                        errorMessageWU = "WU API hat keine aktuellen Beobachtungen zurückgegeben. (Vielleicht 'Data Expired' oder keine Daten in den letzten 60 Minuten gemeldet?)"
                    }
                } catch {
                    errorMessageWU = "Fehler beim Dekodieren der WU Daten: \(error.localizedDescription)"
                    print("WU Dekodierungsfehler: \(error)")
                    // Der original print() ist hier schon drin, aber jetzt sollte 'data' immer einen Wert haben, wenn wir hier ankommen.
                    // print("WU Rohdaten (falls verfügbar): \(String(data: data, encoding: .utf8) ?? "Keine Rohdaten")")
                }
            }
        }.resume()
    }
    
    // --- NEU: Funktion zum Abrufen der Weather Underground Historischen Daten (1 Tag) ---
        func fetchWeatherUndergroundHistoricalData() {
            isLoadingWUHistorical = true
            errorMessageWUHistorical = nil
            wuHistoricalObservations = [] // Alte Daten leeren

            // Die URL für die historischen Beobachtungen Ihrer Station (letzter Tag)
            // Wir verwenden metrische Einheiten (units=m)
            let apiUrl = "https://api.weather.com/v2/pws/observations/all/1day?stationId=\(wuStationID)&format=json&units=m&apiKey=\(wuAPIKey)"

            guard let url = URL(string: apiUrl) else {
                errorMessageWUHistorical = "Ungültige Weather Underground Historical URL"
                isLoadingWUHistorical = false
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isLoadingWUHistorical = false

                    if let error = error {
                        errorMessageWUHistorical = error.localizedDescription
                        print("WU Historical Netzwerkfehler: \(error.localizedDescription)")
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        errorMessageWUHistorical = "Ungültige HTTP-Antwort (WU Historical)"
                        print("WU Historical: Ungültige HTTP-Antwort.")
                        return
                    }

                    // Debug-Ausgabe für Rohdaten (immer)
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("WU Historical HTTP Status Code: \(httpResponse.statusCode)")
                        print("WU Historical Rohdaten (immer): \(responseString)")
                    } else {
                        print("WU Historical: Keine Rohdaten empfangen oder Daten konnten nicht in String umgewandelt werden.")
                    }

                    guard (200...299).contains(httpResponse.statusCode) else {
                        let statusCode = httpResponse.statusCode
                        errorMessageWUHistorical = "HTTP Fehler (WU Historical): \(statusCode)"
                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
                            errorMessageWUHistorical! += "\n\(errorString)"
                        }
                        return
                    }

                    guard let data = data else {
                        errorMessageWUHistorical = "Keine Daten von der Weather Underground Historical API erhalten."
                        print("WU Historical: 'data' ist nil trotz 2xx Statuscode.")
                        return
                    }

                    do {
                        let decoder = JSONDecoder()
                        // Setzen Sie diese Strategie, wenn Ihre JSON-Schlüssel snake_case sind (z.B. "obs_time_utc")
                        // decoder.keyDecodingStrategy = .convertFromSnakeCase

                        let decodedResponse = try decoder.decode(WUHistoricalAPIResponse.self, from: data)

                        if let observations = decodedResponse.observations, !observations.isEmpty {
                            self.wuHistoricalObservations = observations.sorted { $0.obsTimeUtc < $1.obsTimeUtc }
                            print("Weather Underground Historische Daten erfolgreich geladen. Anzahl Einträge: \(self.wuHistoricalObservations.count)")
                        } else {
                            errorMessageWUHistorical = "WU Historical API hat keine Beobachtungen für den Zeitraum zurückgegeben."
                        }
                    } catch {
                        errorMessageWUHistorical = "Fehler beim Dekodieren der WU Historical Daten: \(error.localizedDescription)"
                        print("WU Historical Dekodierungsfehler: \(error)")
                        print("WU Historical Rohdaten (falls verfügbar): \(String(data: data, encoding: .utf8) ?? "Keine Rohdaten")")
                    }
                }
            }.resume()
        }
}
// --- Vorschau für Xcode Canvas ---
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
