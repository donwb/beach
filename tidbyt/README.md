# Tidbyt App (Pixlet)

This folder contains the Pixlet app that renders beach ramp status on a Tidbyt display.

## What it does

- Fetches ramp status from the hosted `svc` API.
- Filters to NSB ramps and maps statuses to display colors.
- Renders a compact multi-column panel suitable for Tidbyt.

## Files

- `/Users/donwb/dev/beach/tidbyt/main.star`: primary Pixlet program.
- `/Users/donwb/dev/beach/tidbyt/main.webp`: rendered output image.
- `/Users/donwb/dev/beach/tidbyt/renderpush.sh`: local helper script for render/push.

## API dependencies

Configured in `/Users/donwb/dev/beach/tidbyt/main.star`:

- `https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus`
- `https://sea-lion-app-lif8v.ondigitalocean.app/tides`

## Local development

If Pixlet is installed, render locally:

```bash
cd /Users/donwb/dev/beach/tidbyt
pixlet render main.star
```

Push to a device (example command pattern):

```bash
pixlet push --installation-id <installation_id> --api-token <token> <device_id> main.webp
```

## Security note

Do not commit real Tidbyt API tokens. Use environment variables or local secrets management for push commands/scripts.
