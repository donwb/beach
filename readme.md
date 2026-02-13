# Beach Ramp Status Monorepo

This repository contains the data pipeline and clients used to track beach ramp access status (plus tide/water data) for Volusia County/New Smyrna Beach.

## Repository layout

- `ramps/`: Python ingester that polls the Volusia GIS endpoint and upserts ramp status into Postgres.
- `svc/`: Go web service (Echo) that serves ramp and tide APIs plus simple web views.
- `BeachInfo/`: UIKit iOS app that calls the hosted `svc` APIs.
- `BeachLife/`: SwiftUI iOS app (newer prototype) that calls the hosted `svc` ramp API.
- `tidbyt/`: Tidbyt/Pixlet app that renders ramp status for a Tidbyt display.
- `rampfunc/`: Archived DigitalOcean Functions experiment (not the active path).

Project-level documentation:

- `ramps`: see `ramps/README.md`
- `svc`: see `svc/README.md`
- `BeachInfo`: see `BeachInfo/README.md`
- `BeachLife`: see `BeachLife/README.md`
- `tidbyt`: see `tidbyt/README.md`

## Current architecture

1. `ramps/main.py` fetches ramp statuses by known status buckets from Volusia GIS.
2. `ramps/main.py` upserts into `rampstatus` in Postgres.
3. `svc` reads from Postgres and exposes JSON + HTML endpoints.
4. iOS apps and Tidbyt display consume the `svc` endpoints.

## Database

Schema lives in `ramps/migration.sql`.

Primary table:

- `rampstatus(id, ramp_name, access_status, o_id, city, access_id, location)`
- Unique constraints on `o_id` and `access_id`

Apply with your preferred Postgres workflow (for example, `psql -f ramps/migration.sql`).

## Environment variables

Both `ramps` and `svc` rely on environment variables.

- `DATABASE`
- `DBUSER`
- `HOST`
- `PASSWORD`
- `PORT` (used by Python ingester)
- `DBPORT` (used by Go service)
- `GISHOST` (used by `ramps`, for Volusia ArcGIS host)

The existing Makefiles expect an `env` file in each project directory (`ramps/env`, `svc/env`) that exports variables.

## Running locally

### 1) Run the ingester (`ramps`)

```bash
cd /Users/donwb/dev/beach/ramps
make
```

Notes:

- `make` runs `python3 main.py`
- Intended production usage is cron-driven (see `ramps/readme.md`)

### 2) Run the API/web service (`svc`)

```bash
cd /Users/donwb/dev/beach/svc
make
```

This starts Echo on `:1323`.

Useful endpoints:

- `GET /rampstatus` JSON ramp payload
- `GET /tides` JSON tide + water temperature payload
- `GET /ramps` plain text ramp summary
- `GET /` current HTML page (`new.html`)
- `GET /old` legacy HTML page (`home.html`)
- `GET /trmnl` TRMNL-specific HTML page

### 3) Optional Docker flow (`svc`)

```bash
cd /Users/donwb/dev/beach/svc
make docker-build
make docker-run
```

Release automation is in `svc/release.sh` and versions are tracked in `svc/VERSION`.

## iOS clients

### `BeachInfo/` (UIKit)

- Storyboard-based iOS app.
- Calls:
  - `https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus`
  - `https://sea-lion-app-lif8v.ondigitalocean.app/tides`
- Displays ramp lights, tide direction/percentage, water temperatures, and a tower cam image.
- Details: `BeachInfo/README.md`

### `BeachLife/` (SwiftUI)

- SwiftUI prototype app.
- Calls:
  - `https://sea-lion-app-lif8v.ondigitalocean.app/rampstatus`
- Displays ramp statuses with color indicators and manual refresh.
- Details: `BeachLife/README.md`

## Tidbyt display (`tidbyt/`)

- `main.star` is the Pixlet program.
- Fetches `rampstatus` (and currently also requests `tides`) from the hosted service.
- Maps ramp states to display colors for a compact dashboard view.
- Details: `tidbyt/README.md`

## Archived project (`rampfunc/`)

`rampfunc/` is an older DigitalOcean Functions implementation of the ingester logic. Keep as historical reference; active ingestion is in `ramps/`.

## Known cleanup opportunities

- Standardize DB port naming (`PORT` vs `DBPORT`).
- Move hard-coded hosted API URLs in iOS/Tidbyt to configuration.
- Add a project README for archived `rampfunc/` if it needs to be kept long term.
