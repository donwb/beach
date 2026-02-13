# ramps (Python Ingestion Job)

`ramps` is the ingestion component that fetches beach ramp status data from Volusia County GIS and upserts it into Postgres.

## What it does

1. Reads DB and GIS configuration from environment variables.
2. Queries the ArcGIS endpoint by known access-status values.
3. Extracts ramp attributes from each GIS response.
4. Upserts rows into `rampstatus` using `access_id` conflict handling.

Primary script: `/Users/donwb/dev/beach/ramps/main.py`

## Data source

`main.py` builds requests to:

- `https://<GISHOST>/arcgis/rest/services/Beaches/MapServer/7/query`

Status buckets currently queried include values like:

- `open`
- `closed for high tide`
- `closed`
- `4x4 only`
- `closing in progress`
- `closed - cleared for turtles`
- `closed - at capacity`
- `open - entrance only`

## Environment variables

Used by `main.py`:

- `DATABASE`
- `DBUSER`
- `HOST`
- `PASSWORD`
- `PORT`
- `GISHOST`

The Makefile expects these via an included `env` file in this directory.

## Local run

From `/Users/donwb/dev/beach/ramps`:

```bash
make
```

Equivalent command:

```bash
python3 main.py
```

Optional helper target:

```bash
make data
```

`make data` runs `/Users/donwb/dev/beach/ramps/data.py`, which inserts test data.

## Database

Schema/migration SQL: `/Users/donwb/dev/beach/ramps/migration.sql`

Table used by the ingester:

- `rampstatus(id, ramp_name, access_status, o_id, city, access_id, location)`

Important constraints:

- unique `o_id`
- unique `access_id`

## Production scheduling

Existing note in `/Users/donwb/dev/beach/ramps/readme.md` indicates cron usage similar to:

```cron
* * * * * make -C /root/dev/beach/ramps >> /var/log/ramps.log
```

## Code map

- `/Users/donwb/dev/beach/ramps/main.py`: production ingester
- `/Users/donwb/dev/beach/ramps/data.py`: test/stub data loader
- `/Users/donwb/dev/beach/ramps/migration.sql`: schema and helper SQL
- `/Users/donwb/dev/beach/ramps/makefile`: local run targets
