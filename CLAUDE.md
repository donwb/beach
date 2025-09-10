# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a beach access ramp monitoring system for Volusia County, Florida. The system consists of three main components:

- **ramps/**: Python data collector that fetches beach ramp status from Volusia County GIS endpoint and stores it in PostgreSQL
- **svc/**: Go web service that serves cached ramp information with REST API endpoints
- **BeachInfo/**, **BeachLife/**, **tidbyt/**: Additional frontend/display components

## Architecture

The system follows a data pipeline architecture:
1. Python script (`ramps/`) runs on cron schedule to collect real-time data from Volusia County GIS API
2. Data is stored in PostgreSQL database with upsert operations based on `access_id`
3. Go service (`svc/`) provides web API and HTML views using Echo framework
4. Service connects to same PostgreSQL database to serve cached data

### Key Components

- **Data Collection**: `ramps/main.py` queries GIS API for ramp statuses: open, closed, 4x4 only, at capacity, etc.
- **Web Service**: `svc/main.go` provides endpoints `/rampstatus`, `/ramps`, `/tides` with HTML templating
- **Database**: PostgreSQL with `rampstatus` table containing ramp metadata and current status

## Development Commands

### Python Data Collector (ramps/)
```bash
cd ramps
make          # Run data collection: python3 main.py
make data     # Run data processing: python3 data.py
```

### Go Web Service (svc/)
```bash
cd svc
make          # Run service: go run *.go
make build    # Build binary: go build *.go
make test     # Development with auto-reload: gow -e=go,mod,html,js,css run .
```

### Docker (svc/)
```bash
cd svc
make docker-build    # Build for linux/amd64: docker build --platform linux/amd64 -t donwb/beachsrv:0.8 .
make docker-run      # Run container with env file on port 80
```

## Environment Configuration

Both services require environment files (`env`) with database credentials:
- DATABASE, DBUSER, HOST, PASSWORD, PORT/DBPORT
- GISHOST (for ramps service to connect to Volusia County GIS)

## Database Schema

Main table `rampstatus` with fields:
- `access_id` (unique identifier)
- `ramp_name`, `access_status`, `city`, `location`
- `o_id` (GIS object ID)

## Deployment Notes

- **ramps/** runs as crontab: `* * * * * make -C /root/dev/beach/ramps >> /var/log/ramps.log`
- **svc/** runs as containerized web service on port 1323 (mapped to 80)
- Uses PostgreSQL for persistent storage
- Go service serves static files from `view/` directory