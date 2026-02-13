# svc (Go API + Web Service)

`svc` is the Go service that exposes ramp status and tide/water data from Postgres/NOAA, and serves simple HTML pages.

## Stack

- Go `1.21.4`
- [Echo](https://echo.labstack.com/) web framework
- Postgres driver: `github.com/lib/pq`

## What it serves

The service starts on port `1323` by default.

### API routes

- `GET /rampstatus`
  - Returns all ramps from Postgres as JSON.
- `GET /ramps`
  - Returns plain-text ramp summary.
- `GET /tides`
  - Returns JSON with:
    - current tide direction (`currentTideHighOrLow`)
    - tide level percentage (`tideLevelPercentage`)
    - water temperature data (`waterTemp`, `waterTemps`)
    - upcoming tide events (`tideInfo`)

### Web routes

- `GET /` renders `view/new.html`
- `GET /old` renders `view/home.html`
- `GET /trmnl` renders `view/trmnl.html`
- Static assets are served at `/static` from `view/`

## Environment variables

Read in `main.go`:

- `DATABASE`
- `DBUSER`
- `HOST`
- `PASSWORD`
- `DBPORT`

These are used to build the Postgres connection string:

```text
host=<HOST> port=<DBPORT> user=<DBUSER> password=<PASSWORD> dbname=<DATABASE> sslmode=disable
```

## Local run

From `/Users/donwb/dev/beach/svc`:

```bash
make
```

Equivalent direct command:

```bash
go run *.go
```

## Build

```bash
make build
```

## Docker

Build and run using included Makefile targets:

```bash
make docker-build
make docker-run
```

- Dockerfile path: `/Users/donwb/dev/beach/svc/dockerfile`
- Container exposes `1323`
- `docker-run` expects env vars in `docker-env`

## Release flow

Release automation is in `/Users/donwb/dev/beach/svc/release.sh`.

Example:

```bash
./release.sh --bump patch
```

What it does:

1. Bumps `VERSION` (unless pinned with `--version`).
2. Builds and tags Docker image (`<repo>:<version>` and `latest`).
3. Pushes images.
4. Optionally triggers DigitalOcean App Platform deploy.

Supported options include:

- `--bump patch|minor|major|none`
- `--version X.Y.Z`
- `--no-deploy`

## Code map

- `/Users/donwb/dev/beach/svc/main.go`: server boot, route registration, env setup
- `/Users/donwb/dev/beach/svc/handlers.go`: Echo handlers/routes
- `/Users/donwb/dev/beach/svc/ramps.go`: Postgres ramp reads
- `/Users/donwb/dev/beach/svc/tides.go`: NOAA calls and tide/water processing
- `/Users/donwb/dev/beach/svc/types.go`: JSON/data model types
- `/Users/donwb/dev/beach/svc/view/`: HTML/CSS/JS templates and assets
