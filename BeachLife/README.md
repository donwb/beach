# BeachLife (SwiftUI iOS App)

`BeachLife` is a SwiftUI-based iOS client/prototype focused on live ramp access status.

## What it does

- Fetches ramp status JSON from the `svc` API.
- Renders ramp rows with color-coded indicators.
- Provides manual refresh and last-refresh time display.

## API dependency

Configured in `/Users/donwb/dev/beach/BeachLife/BeachLife/ContentView.swift`:

- `https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus`

## Open and run

1. Open `/Users/donwb/dev/beach/BeachLife/BeachLife.xcodeproj` in Xcode.
2. Select an iOS simulator or device.
3. Build and run the `BeachLife` scheme.

## Key files

- `/Users/donwb/dev/beach/BeachLife/BeachLife/ContentView.swift`
- `/Users/donwb/dev/beach/BeachLife/BeachLife/RampStatus.swift`
- `/Users/donwb/dev/beach/BeachLife/BeachLife/BeachLifeApp.swift`
