import Foundation
import SwiftUI // Für Identifiable

// --- NEU: Datenmodelle für die Historische Weather Underground API-Antwort (PWS Recent History - 1 Day) ---
// Diese Strukturen bilden die JSON-Antwort der Historical PWS API ab.

struct WUHistoricalAPIResponse: Codable {
    let observations: [WUHistoricalObservation]?
}

struct WUHistoricalObservation: Codable, Identifiable {
    // Wenn 'obsTimeUtc' immer eindeutig ist, ist das eine gute Wahl.
    // Wenn es duplikate geben könnte (selten, aber möglich bei sehr schnellen Ops),
    // wäre ein UUID-ID wie in HourlyAggregatedWUData robuster.
    var id: String { obsTimeUtc }

    let stationID: String?
    let tz: String? // Time zone of PWS
    let obsTimeUtc: String // GMT(UTC) time
    let obsTimeLocal: String? // Time observation is valid in local apparent time by timezone
    let epoch: Int? // Time in UNIX seconds
    let lat: Double? // Latitude of PWS
    let lon: Double? // Longitude of PWS
    let qcStatus: Int? // Quality control indicator

    // Durchschnittliche Werte für den Zeitraum
    let humidityAvg: Int? // Average Humidity of the period
    let humidityHigh: Int? // Highest Humidity of the period
    let humidityLow: Int? // Lowest Humidity of the period
    let solarRadiationHigh: Double? // Highest Solar Radiation of the period
    let uvHigh: Double? // Highest UV Index of the period
    let winddirAvg: Int? // Wind direction average of the period


    // Die Einheiten-Objekte (metric, imperial etc.) für historische Daten
    let metric: WUHistoricalMetricUnits? // Object containing fields that use a defined unit of measure.
    let imperial: WUHistoricalImperialUnits? // Object containing fields that use a defined unit of measure.
    // Fügen Sie hier uk_hybrid oder metric_si hinzu, falls benötigt

    // Hilfsvariable, um das Datum als Date-Objekt zu erhalten
    var date: Date {
        // Nutzen wir den epoch-Timestamp, da er am zuverlässigsten ist
        if let epochValue = epoch {
            return Date(timeIntervalSince1970: TimeInterval(epochValue))
        }
        // Fallback, falls epoch nicht vorhanden, verwenden Sie obsTimeUtc
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: obsTimeUtc) ?? Date() // Fallback auf aktuelles Datum, sollte aber nie passieren
    }


    private enum CodingKeys: String, CodingKey {
        case stationID, tz, obsTimeUtc, obsTimeLocal, epoch, lat, lon, qcStatus, metric, imperial, humidityAvg, humidityHigh, humidityLow, solarRadiationHigh, uvHigh, winddirAvg
    }
}

struct WUHistoricalMetricUnits: Codable {
    let tempHigh: Double? // High Temperature of the period
    let tempLow: Double? // Low Temperature of the period
    let tempAvg: Double? // Temperature average of the period
    let windspeedHigh: Double? // Highest Wind speed of the period
    let windspeedLow: Double? // Lowest Wind speed of the period
    let windspeedAvg: Double? // Wind speed average of the period
    let windgustHigh: Double? // Highest Wind gust of the period
    let windgustLow: Double? // Lowest Wind gust of the period
    let windgustAvg: Double? // Wind gust average of the period
    let dewptHigh: Double? // Maximum dew point of the period
    let dewptLow: Double? // Minimum dew point of the period
    let dewptAvg: Double? // Average dew point of the period
    let windchillHigh: Double? // High Windchill temperature of the period
    let windchillLow: Double? // Low Windchill temperature of the period
    let windchillAvg: Double? // Windchill average of the period
    let heatindexHigh: Double? // Heat index high temperature of the period
    let heatindexLow: Double? // Heat index low temperature of the period
    let heatindexAvg: Double? // Heat index average of the period
    let pressureMax: Double? // Highest Barometric pressure in defined unit of measure of the period
    let pressureMin: Double? // Lowest Barometric pressure in defined unit of measure of the period
    let pressureTrend: Double? // Pressure tendency over the preceding period
    let precipRate: Double? // Rate of precipitation - instantaneous precipitation rate.
    let precipTotal: Double? // Accumulated Rain for the day in defined unit of measure
}

// Wenn Sie imperiale Einheiten verwenden möchten, definieren Sie auch diese Struktur:
struct WUHistoricalImperialUnits: Codable {
    // Fügen Sie hier die entsprechenden imperialen Felder ein, analog zu WUMetricUnits
    let tempHigh: Double?
    let tempLow: Double?
    let tempAvg: Double?
    // ... und so weiter für alle relevanten Felder
}

// --- Meteostat API Datenmodelle (für historische Daten) ---
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

// MARK: - HourlyAggregatedWUData (NEU)
struct HourlyAggregatedWUData: Identifiable {
    let id = UUID() // Für SwiftUI List/Chart Identifizierung
    let date: Date // Stellt die Stunde dar (z.B. 10:00 Uhr am 2. Juni)
    let maxTemp: Double
    let avgTemp: Double
    let minTemp: Double
}
