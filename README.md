### Vertical Farming IoT Backend
<img width="1600" height="903" alt="Cover (1)" src="https://github.com/user-attachments/assets/649a3ff3-21c5-4281-8255-511a7de2bb61" />

A production-ready FastAPI backend for a vertical farming system. It ingests sensor and status data from MQTT, persists it to MySQL, streams realtime updates via WebSockets, and exposes a typed REST API with OpenAPI docs.

The repository also contains a Flutter app in `verta_farm/` and an ESP32 sketch `Vframe.ino` for device-side publishing.

<img width="1600" height="903" alt="MOBILE POS APPLICATION" src="https://github.com/user-attachments/assets/ceadb0c6-af81-46af-ae03-52ece54182e7" />

<div style="display: flex; gap: 10px; flex-wrap: wrap;">
  <img src="https://github.com/user-attachments/assets/76bc341c-a115-4931-a6bc-92a4196edc4b" width="24%" />
  <img src="https://github.com/user-attachments/assets/2f9f1178-6a54-4411-ac25-f85990cbeda7" width="24%" />
  <img src="https://github.com/user-attachments/assets/eb969565-0072-4703-a1a8-b78b1d13547a" width="24%" />
  <img src="https://github.com/user-attachments/assets/a734739d-0b78-4de4-a230-7d7dfc6277a0" width="24%" />
</div>




---

### Features
- **FastAPI service** with interactive docs at `/docs` and `/redoc`.
- **MQTT ingestion** (Eclipse Mosquitto) for temperature, humidity, waterflow, waterlevel, and TDS.
- **MySQL persistence** via SQLAlchemy; schema managed with Alembic migrations.
- **Realtime updates** to clients via an in-process event bus and WebSockets.
- **Threshold alerts**: emits alerts when values breach configured min/max.
- **Containerized** with `Dockerfile` and `docker-compose.yml` for local/dev deployment.

---

### Architecture (high level)
- `app/main.py`: FastAPI app startup, health checks, router wiring.
- `app/api/`: Modular API routers (devices, data, control, realtime, thresholds).
- `app/services/mqtt_service.py`: MQTT client, topic subscriptions, ingestion, alerting.
- `app/db/session.py`: SQLAlchemy engine/session creation and DB URL resolution.
- `app/models/`: ORM models for devices, sensors, readings, thresholds.
- `alembic/`: Database migrations.

---

### Quickstart (Local, without Docker)
Requirements: Python 3.11+ and a running MySQL and MQTT broker (adjust env vars as needed).

```bash
python -m venv .venv
. .venv/bin/activate  # Windows PowerShell: .venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt

# Create a .env file (see below) or export env vars in your shell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Then visit `http://localhost:8000/docs` for interactive API docs.

---

### Run with Docker (recommended for dev)

```bash
docker compose up -d --build
```

Services:
- API: `http://localhost:8000`
- MySQL: `localhost:3306`
- Mosquitto MQTT: `localhost:1883` (WebSocket: `localhost:9001`)

To view logs:
```bash
docker compose logs -f app
```

Bring everything down:
```bash
docker compose down -v
```

---

### Environment variables
The app uses `pydantic-settings` and reads from both the environment and an optional `.env` file at the repo root.

Common variables (defaults shown):
- `APP_ENV` (default: `development`)
- `SECRET_KEY` (required for auth-related features when enabled)
- `DB_URL` (optional full SQLAlchemy URL; overrides individual MYSQL_*)
- `MYSQL_HOST` (default: `127.0.0.1`)
- `MYSQL_PORT` (default: `3306`)
- `MYSQL_DATABASE` (default: `vertical_farm`)
- `MYSQL_USER` (default: `vfarm`)
- `MYSQL_PASSWORD` (default: `vfarm_pass`)
- `MQTT_BROKER_HOST` (default: `localhost`)
- `MQTT_BROKER_PORT` (default: `1883`)
- `LOG_LEVEL` (default: `INFO`)

Example `.env`:
```bash
APP_ENV=development
SECRET_KEY=dev_secret
# Use either DB_URL or MYSQL_* variables
# DB_URL=mysql+pymysql://vfarm:vfarm_pass@127.0.0.1:3306/vertical_farm
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_DATABASE=vertical_farm
MYSQL_USER=vfarm
MYSQL_PASSWORD=vfarm_pass

MQTT_BROKER_HOST=localhost
MQTT_BROKER_PORT=1883
LOG_LEVEL=INFO
```

---

### Database migrations
Alembic is configured under `alembic/`.

Apply latest migrations:
```bash
alembic upgrade head
Or in Live Docker Server
docker exec -it vfarm-app alembic upgrade head
```

Create a new migration (after model changes):
```bash
alembic revision -m "your message"
alembic upgrade head
```

---

### MQTT topics (ingestion)
The service subscribes to patterns of the form:

```
farm/{device_id}/sensor/temperature
farm/{device_id}/sensor/humidity
farm/{device_id}/sensor/waterflow
farm/{device_id}/sensor/waterlevel
farm/{device_id}/sensor/tds
farm/{device_id}/status
```

Payloads are JSON. Minimal examples:
```json
// temperature
{ "value_c": 23.4 }

// humidity
{ "value_pct": 58.2 }

// waterflow (additional fields optionally forwarded to WebSocket)
{ "l_per_min": 1.25, "total_liters": 10.2, "avg_l_per_min": 1.1, "pulses": 1234 }

// device status
{ "online": true, "battery": 92 }
```

Alerts are published back on `farm/{device_id}/alert/{sensor_type}` when thresholds are configured and breached.

---

### API usage
Interactive documentation is available at:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

Note: This README intentionally avoids listing specific endpoints or response schemas; use the interactive docs during development.

---

### Developer notes
- Dev helper scripts on Windows: `scripts/dev.ps1` and `scripts/dev.bat`.
- Default app entrypoint is `app.main:app`. Uvicorn is used for development and production.
- The container image installs build tools and `default-libmysqlclient-dev` for compatibility.

---

### Troubleshooting
- If MQTT ingestion appears idle, verify broker reachability and credentials, and confirm topics are being published.
- If DB connections fail, ensure `DB_URL` or the `MYSQL_*` variables point to a reachable MySQL instance.
- On Windows file change detection issues, set `WATCHFILES_FORCE_POLLING=true` (already set in `docker-compose.yml`).

---

### License
Choose a license (e.g., MIT, Apache-2.0) and add a `LICENSE` file.


