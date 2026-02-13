# BeachInfo (UIKit iOS App)

`BeachInfo` is the storyboard-based iOS client for ramp status, tides, and water temperature.

## What it does

- Fetches ramp status JSON from the `svc` API.
- Fetches tide/water data JSON from the `svc` API.
- Shows status lights for key NSB ramps.
- Shows upcoming tide entries in a table.
- Loads a tower cam image and supports full-screen tap-to-zoom.

## API dependencies

Configured in `/Users/donwb/dev/beach/BeachInfo/BeachInfo/ViewController.swift`:

- `https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus`
- `https://sea-lion-app-lif8v.ondigitalocean.app/tides`

Localhost alternatives are already present as commented lines in the same file.

## Open and run

1. Open `/Users/donwb/dev/beach/BeachInfo/BeachInfo.xcodeproj` in Xcode.
2. Select an iOS simulator or device.
3. Build and run the `BeachInfo` scheme.

## Key files

- `/Users/donwb/dev/beach/BeachInfo/BeachInfo/ViewController.swift`
- `/Users/donwb/dev/beach/BeachInfo/BeachInfo/TideStatus.swift`
- `/Users/donwb/dev/beach/BeachInfo/RampStatus.swift`
- `/Users/donwb/dev/beach/BeachInfo/BeachInfo/Base.lproj/Main.storyboard`
