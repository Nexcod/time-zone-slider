//
//  TimeZoneModel.swift
//  time-zone-slider
//
//  State and conversion logic. The selected moment is a real Date and every
//  city carries an IANA time-zone identifier, so offsets (and the GMT badges)
//  follow DST automatically.
//

import Foundation

struct City: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let country: String
    /// IANA time-zone identifier, e.g. "Europe/London".
    let tz: String

    var timeZone: TimeZone { TimeZone(identifier: tz) ?? .gmt }
}

enum HourFormat: String {
    case h24, h12
}

struct TimeZoneModel {
    /// The moment being converted; dials move it around.
    var moment: Date = .now
    var cities: [City] = TimeZoneModel.loadCities() {
        didSet { Self.saveCities(cities) }
    }
    var hourFormat: HourFormat = TimeZoneModel.loadHourFormat() {
        didSet { UserDefaults.standard.set(hourFormat.rawValue, forKey: Self.hourFormatKey) }
    }
    var showHomeDiff = true

    static let defaultCities = ["Asia/Bangkok", "Europe/London", "Asia/Tbilisi"]
    private static let citiesKey = "cities.v1"
    private static let hourFormatKey = "hourFormat.v1"

    /// Every city-style zone in the system IANA database, named with the
    /// locale's exemplar city (ICU "VVV" — the same names the Clock app
    /// shows). The identifier's region path becomes the subtitle.
    static let catalog: [City] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "VVV"
        let now = Date()
        return TimeZone.knownTimeZoneIdentifiers
            .compactMap { id -> City? in
                let parts = id.split(separator: "/")
                guard parts.count > 1, parts[0] != "Etc",
                      let tz = TimeZone(identifier: id) else { return nil }
                formatter.timeZone = tz
                let exemplar = formatter.string(from: now)
                let name = exemplar.isEmpty
                    ? parts.last!.replacingOccurrences(of: "_", with: " ")
                    : exemplar
                let region = parts.dropLast().joined(separator: " · ")
                    .replacingOccurrences(of: "_", with: " ")
                return City(id: id, name: name, country: region, tz: id)
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }()

    // MARK: Persistence

    static func loadCities() -> [City] {
        if let data = UserDefaults.standard.data(forKey: citiesKey),
           let saved = try? JSONDecoder().decode([City].self, from: data) {
            let valid = saved.filter { TimeZone(identifier: $0.tz) != nil }
            if !valid.isEmpty { return valid }
        }
        return defaultCities.compactMap { id in catalog.first { $0.id == id } }
    }

    static func loadHourFormat() -> HourFormat {
        HourFormat(rawValue: UserDefaults.standard.string(forKey: hourFormatKey) ?? "") ?? .h24
    }

    static func saveCities(_ cities: [City]) {
        if let data = try? JSONEncoder().encode(cities) {
            UserDefaults.standard.set(data, forKey: citiesKey)
        }
    }

    // MARK: Time math

    private func calendar(for city: City) -> Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = city.timeZone
        return cal
    }

    func localTime(_ city: City) -> (hour: Int, minute: Int) {
        let comps = calendar(for: city).dateComponents([.hour, .minute], from: moment)
        return (comps.hour ?? 0, comps.minute ?? 0)
    }

    /// Local time as a fractional hour 0..<24, for positioning the knob.
    func localFraction(_ city: City) -> Double {
        let t = localTime(city)
        return Double(t.hour) + Double(t.minute) / 60
    }

    /// Offset from UTC in hours at the current moment (DST-aware).
    func offsetHours(_ city: City) -> Double {
        Double(city.timeZone.secondsFromGMT(for: moment)) / 3600
    }

    func gmtLabel(_ city: City) -> String {
        let off = offsetHours(city)
        if off == 0 { return "GMT" }
        let sign = off < 0 ? "−" : "+"
        let a = abs(off)
        let h = Int(a)
        let m = Int(((a - Double(h)) * 60).rounded())
        return "GMT\(sign)\(h)" + (m > 0 ? String(format: ":%02d", m) : "")
    }

    func timeLabel(_ city: City) -> String {
        let t = localTime(city)
        switch hourFormat {
        case .h12:
            let ap = t.hour < 12 ? "am" : "pm"
            var h12 = t.hour % 12
            if h12 == 0 { h12 = 12 }
            return "\(h12)" + (t.minute > 0 ? String(format: ":%02d", t.minute) : "") + " " + ap
        case .h24:
            return String(format: "%02d:%02d", t.hour, t.minute)
        }
    }

    /// "+1 day" / "−1 day" when the city's local date differs from home's.
    func dayBadge(_ city: City) -> String? {
        guard let home = cities.first else { return nil }
        let cityDay = calendar(for: city).dateComponents([.year, .month, .day], from: moment)
        let homeDay = calendar(for: home).dateComponents([.year, .month, .day], from: moment)
        guard cityDay != homeDay else { return nil }
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = .gmt
        guard let c = utcCal.date(from: cityDay), let h = utcCal.date(from: homeDay),
              let shift = utcCal.dateComponents([.day], from: h, to: c).day else { return nil }
        if shift == 1 { return "+1 day" }
        if shift == -1 { return "−1 day" }
        return nil
    }

    /// Offset relative to the home city, e.g. "+3h home".
    func relBadge(at index: Int) -> String? {
        guard showHomeDiff, index > 0, index < cities.count, let home = cities.first else { return nil }
        let diff = offsetHours(cities[index]) - offsetHours(home)
        guard diff != 0 else { return nil }
        let a = abs(diff)
        let mag = a.truncatingRemainder(dividingBy: 1) != 0
            ? String(format: "%g", a)
            : String(Int(a))
        return (diff < 0 ? "−" : "+") + mag + "h home"
    }

    /// A drag at `fraction` (0...1 down the dial) selects that local hour,
    /// keeping the city's local date.
    mutating func pick(cityIndex: Int, fraction: Double) {
        guard cities.indices.contains(cityIndex) else { return }
        let h = min(23, max(0, Int(fraction * 24)))
        let cal = calendar(for: cities[cityIndex])
        var comps = cal.dateComponents([.year, .month, .day], from: moment)
        comps.hour = h
        comps.minute = 0
        if let picked = cal.date(from: comps) {
            moment = picked
        }
    }

    mutating func resetToNow() {
        moment = .now
    }

    /// Shifts the shared moment by whole hours (VoiceOver adjustable dials).
    mutating func adjustHour(by delta: Int) {
        moment = moment.addingTimeInterval(TimeInterval(delta) * 3600)
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

    // MARK: City list

    func searchResults(query: String) -> [City] {
        let q = query.trimmingCharacters(in: .whitespaces)
        // Cities saved before the generated catalog have short ids
        // ("bangkok"), so dedupe by zone rather than id.
        let have = Set(cities.map(\.tz))
        return Self.catalog.filter { c in
            guard !have.contains(c.tz) else { return false }
            if q.isEmpty { return true }
            // The identifier keeps English names searchable in other locales.
            let haystack = "\(c.name) \(c.country) \(c.tz.replacingOccurrences(of: "_", with: " "))"
            return haystack.localizedStandardContains(q)
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
