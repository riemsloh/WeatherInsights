
import Foundation // Oder import SwiftUI, wenn Sie es für id brauchen, aber Foundation reicht für String/CaseIterable

enum ContentViewMode: String, CaseIterable, Identifiable {
    case summary = "Übersicht"
    case meteostatChart = "Meteostat Verlauf"
    case wuCurrent = "WU Aktuell"
    case wuHistorical = "WU Verlauf (24h)"

    var id: String { self.rawValue }
}
