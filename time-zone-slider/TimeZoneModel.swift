//
//  TimeZoneModel.swift
//  time-zone-slider
//
//  State and conversion logic, ported from the DCLogic component in
//  "Timezone Converter.dc.html".
//

import Foundation

struct City: Identifiable, Equatable {
    let id: String
    let name: String
    let country: String
    /// Offset from UTC in hours (may be fractional, e.g. Delhi +5.5).
    let off: Double
}

enum HourFormat: String {
    case h24, h12
}

struct TimeZoneModel {
    /// Selected moment as a UTC hour-of-day (0..<24, may be fractional).
    var utc: Double = 12
    var cities: [City] = [
        City(id: "bangkok", name: "Bangkok", country: "Thailand", off: 7),
        City(id: "london", name: "London", country: "United Kingdom", off: 1),
        City(id: "tbilisi", name: "Tbilisi", country: "Georgia", off: 4),
    ]
    var hourFormat: HourFormat = .h24
    var showHomeDiff = true

    static let catalog: [City] = [
        City(id: "losangeles", name: "Los Angeles", country: "United States", off: -7),
        City(id: "chicago", name: "Chicago", country: "United States", off: -5),
        City(id: "newyork", name: "New York", country: "United States", off: -4),
        City(id: "saopaulo", name: "São Paulo", country: "Brazil", off: -3),
        City(id: "london", name: "London", country: "United Kingdom", off: 1),
        City(id: "lisbon", name: "Lisbon", country: "Portugal", off: 1),
        City(id: "paris", name: "Paris", country: "France", off: 2),
        City(id: "berlin", name: "Berlin", country: "Germany", off: 2),
        City(id: "moscow", name: "Moscow", country: "Russia", off: 3),
        City(id: "dubai", name: "Dubai", country: "United Arab Emirates", off: 4),
        City(id: "tbilisi", name: "Tbilisi", country: "Georgia", off: 4),
        City(id: "delhi", name: "Delhi", country: "India", off: 5.5),
        City(id: "bangkok", name: "Bangkok", country: "Thailand", off: 7),
        City(id: "singapore", name: "Singapore", country: "Singapore", off: 8),
        City(id: "tokyo", name: "Tokyo", country: "Japan", off: 9),
        City(id: "sydney", name: "Sydney", country: "Australia", off: 10),
        City(id: "auckland", name: "Auckland", country: "New Zealand", off: 12),
    ]

    static func norm(_ h: Double) -> Double {
        (h.truncatingRemainder(dividingBy: 24) + 24).truncatingRemainder(dividingBy: 24)
    }

    static func gmtLabel(_ off: Double) -> String {
        if off == 0 { return "GMT" }
        let sign = off < 0 ? "−" : "+"
        let a = abs(off)
        let h = Int(a)
        let m = Int(((a - Double(h)) * 60).rounded())
        return "GMT\(sign)\(h)" + (m > 0 ? String(format: ":%02d", m) : "")
    }

    func fmt(_ h: Double) -> String {
        let hh = Int(h)
        let mm = Int(((h - Double(hh)) * 60).rounded())
        switch hourFormat {
        case .h12:
            let ap = hh < 12 ? "am" : "pm"
            var h12 = hh % 12
            if h12 == 0 { h12 = 12 }
            return "\(h12)" + (mm > 0 ? String(format: ":%02d", mm) : "") + " " + ap
        case .h24:
            return String(format: "%02d:%02d", hh, mm)
        }
    }

    var homeOff: Double { cities.first?.off ?? 0 }

    func localHour(_ city: City) -> Double { Self.norm(utc + city.off) }

    /// "+1 day" / "−1 day" when the city's date differs from home's.
    func dayBadge(_ city: City) -> String? {
        let homeShift = ((utc + homeOff) / 24).rounded(.down)
        let shift = Int(((utc + city.off) / 24).rounded(.down) - homeShift)
        if shift == 1 { return "+1 day" }
        if shift == -1 { return "−1 day" }
        return nil
    }

    /// Offset relative to the home city, e.g. "+3h home".
    func relBadge(at index: Int) -> String? {
        guard showHomeDiff, index > 0, index < cities.count else { return nil }
        let diff = cities[index].off - homeOff
        guard diff != 0 else { return nil }
        let a = abs(diff)
        let mag = a.truncatingRemainder(dividingBy: 1) != 0
            ? String(format: "%.1f", a)
            : String(Int(a))
        return (diff < 0 ? "−" : "+") + mag + "h home"
    }

    /// A drag at `fraction` (0...1 down the dial) selects that local hour.
    mutating func pick(cityIndex: Int, fraction: Double) {
        guard cities.indices.contains(cityIndex) else { return }
        let h = min(23, max(0, Int(fraction * 24)))
        utc = Self.norm(Double(h) - cities[cityIndex].off)
    }

    struct HourLabel: Identifiable {
        let id: Int
        let label: String
        let bold: Bool
    }

    var hourLabels: [HourLabel] {
        (0..<24).map { h in
            let label: String
            switch hourFormat {
            case .h12:
                label = h == 0 ? "12a" : h == 12 ? "12p" : String(h % 12)
            case .h24:
                label = String(format: "%02d:00", h)
            }
            return HourLabel(id: h, label: label, bold: h % 6 == 0)
        }
    }

    func searchResults(query: String) -> [City] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        let have = Set(cities.map(\.id))
        return Self.catalog.filter { c in
            !have.contains(c.id) && (q.isEmpty || "\(c.name) \(c.country)".lowercased().contains(q))
        }
    }

    mutating func add(_ city: City) {
        cities.append(city)
    }

    mutating func delete(at index: Int) {
        guard cities.count > 1, cities.indices.contains(index) else { return }
        cities.remove(at: index)
    }

    mutating func moveLeft(at index: Int) {
        guard index > 0, cities.indices.contains(index) else { return }
        cities.swapAt(index - 1, index)
    }

    mutating func moveRight(at index: Int) {
        guard cities.indices.contains(index), index < cities.count - 1 else { return }
        cities.swapAt(index, index + 1)
    }
}
