# time-zone-slider

SwiftUI iOS app: a timezone converter with draggable 24-hour dials
("Time Zones" screen). Implements the Claude Design mockup below.

## Design source

- Claude Design project: https://claude.ai/design/p/09cb13ee-a28c-4e0c-b518-35ae20fe536f?file=Timezone+Converter.dc.html
  - projectId: `09cb13ee-a28c-4e0c-b518-35ae20fe536f`
  - Main mockup: `Timezone Converter.dc.html` (DCLogic component — state,
    conversion math, catalog of cities)
  - Design tokens: `_ds/organic-a0233916-de1d-4b3b-b7de-56125cb24ab9/styles.css`
    ("Organic" design system)
- Access via the claude_design MCP (DesignSync tool; authenticate with
  `/design-login` if needed): `list_files` / `get_file` with the projectId above.

## Design → code mapping

- `Theme.swift` — color/radius tokens ported from the Organic `styles.css`,
  made adaptive: dark-mode values are not in the source system, they mirror
  the light tonal ramps around the same ink/cream anchors. Text uses
  Dynamic Type semantic styles; headings approximate Caprasimo with system
  serif bold (fonts are not bundled).
- `TimeZoneModel.swift` — logic ported from the DC script, then upgraded:
  the shared `moment` is a real `Date` and cities carry IANA time-zone
  identifiers, so offsets/GMT badges are DST-aware. Dragging a city's dial
  picks that city's local hour (keeping its local date) and back-solves
  `moment`. The city list persists to `UserDefaults` (key `cities.v1`).
- `TimeZonesView.swift` / `CityCardView.swift` / `AddCityView.swift` — the
  screen, city card with dial, and add-city overlay.

## Build

Xcode project uses filesystem-synchronized groups — new files under
`time-zone-slider/` are picked up without editing project.pbxproj.

CLI builds need the full Xcode toolchain (xcode-select points at
CommandLineTools on this machine):

```sh
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project time-zone-slider.xcodeproj -scheme time-zone-slider \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```
