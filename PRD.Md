# **PRD – Vertical Farming IoT Backend Server**

**Version:** 1.0
**Date:** 2025-09-24
**Prepared by:** Rakibul

---

## 1. **Objective**

A backend server to collect, process, and manage real-time IoT data from ESP-based devices (DHT22, water flow sensor, water level sensor, relay, motor, and light controllers). The system will provide a secure interface for mobile apps to monitor and control devices in real-time using MQTT and REST APIs.

---

## 2. **Scope**

* IoT devices (ESP32/ESP8266) will publish sensor data to the server via **MQTT broker**.
* The server will:

  * Store incoming data into **MySQL** database.
  * Provide **REST + WebSocket APIs** (FastAPI) for mobile app.
  * Handle **device control commands** (e.g., motor on/off, light schedule) via MQTT.
* Admin panel / dashboard (future scope) to visualize data.

---

## 3. **Core Features**

### 3.1 IoT Data Ingestion

* Collect data from sensors:

  * Temperature & Humidity (**DHT22**)
  * Water Flow Rate
  * Water Level
* Device status data (relay on/off, motor state, light state).
* Use **MQTT Topics** (e.g., `farm/{device_id}/sensor` , `farm/{device_id}/control`).

### 3.2 Device Control

* Send control commands to IoT devices:

  * Motor: ON/OFF
  * Light: ON/OFF (future: scheduling)
  * Relay: ON/OFF
* Commands will be published to **MQTT topics** and devices will act accordingly.

### 3.3 Database Management (MySQL + Prisma ORM style in Python)

* Tables:

  * **Users** (mobile app users, admin)
  * **Devices** (device\_id, type, location, status)
  * **Sensors** (sensor\_id, type, device\_id)
  * **SensorData** (timestamp, sensor\_id, value)
  * **ControlLogs** (command, device\_id, user\_id, timestamp)

### 3.4 API Endpoints (FastAPI)

* **Auth**: JWT-based login/signup
* **Devices**: register/list devices
* **Sensors**: list sensors per device
* **Data**: get latest or historical data
* **Control**: send control commands (motor, light, relay)
* **Realtime**: WebSocket endpoints for live data

### 3.5 Security

* **JWT Authentication** for all API requests
* **MQTT authentication** (username/password for devices)
* Role-based access: Admin vs User

---

## 4. **Non-Functional Requirements**

* **Scalability**: Support 100+ devices publishing data concurrently.
* **Low latency**: Realtime updates <1 sec delay.
* **Reliability**: Auto reconnect MQTT + database persistence.
* **Extensibility**: Future AI integration (disease detection service).

---

## 5. **Tech Stack**

* **Backend Framework**: Python (FastAPI)
* **Message Broker**: MQTT (Eclipse Mosquitto or EMQX)
* **Database**: MySQL
* **ORM**: SQLAlchemy + Alembic (for migrations)
* **Auth**: JWT (PyJWT or FastAPI-JWT-Auth)
* **Deployment**: Docker + Nginx + Uvicorn/Gunicorn
* **Mobile Client Communication**: REST + WebSocket

---

## 5.1 **Development Setup & Workflow**

* **Python Version**: 3.11 (recommended)
* **Virtual Environment (venv)**:

  1. `python -m venv .venv`
  2. Activate: `source .venv/bin/activate` (Linux/Mac) or `.venv\\Scripts\\activate` (Windows PowerShell)
  3. Upgrade pip: `python -m pip install --upgrade pip`
  4. Install deps: `pip install -r requirements.txt`
* **Environment Variables**: Use a `.env` file; do not commit to VCS.
* **Run Dev Server**: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
* **Code Style**: `ruff` + `black` for lint/format; `mypy` for typing (strict on `app/`).
* **Pre-commit**: Configure hooks for format, lint, and security scan (`bandit`).

---

## 6. **MQTT Topic Structure**

* **Data Publish (ESP → Server)**

  * `farm/{device_id}/sensor/temperature`
  * `farm/{device_id}/sensor/humidity`
  * `farm/{device_id}/sensor/waterflow`
  * `farm/{device_id}/sensor/waterlevel`
* **Control Commands (Server → ESP)**

  * `farm/{device_id}/control/motor`
  * `farm/{device_id}/control/light`
  * `farm/{device_id}/control/relay`

---

## 6.1 **MQTT Messaging Policy**

* **QoS**: Sensor publishes at QoS 1; control commands at QoS 1 or 2 (TBD based on latency tests).
* **Retained Messages**:

  * Do not retain high-frequency sensor messages.
  * Retain latest desired device state on `farm/{device_id}/control/*` to enable late joiners.
* **Last Will & Testament (LWT)**:

  * Topic: `farm/{device_id}/status`
  * Payload: `{ "status": "offline", "ts": <unix_ms> }`
  * On connect, devices publish `{ "status": "online", "ts": <unix_ms> }`.
* **Payload Format**: Strict JSON, UTF-8, Unix epoch milliseconds (`ts`), SI units.
* **Time**: Devices send timestamps sourced from NTP; server reconciles skew.
* **Idempotency**: Messages include `msg_id` (UUIDv4) to deduplicate at the server.

---

## 6.2 **Payload Schemas (Examples)**

* Temperature: `{ "device_id": "esp32-001", "sensor": "temperature", "value_c": 26.4, "ts": 1732462345123, "msg_id": "..." }`
* Humidity: `{ "device_id": "esp32-001", "sensor": "humidity", "value_pct": 61.2, "ts": 1732462345123, "msg_id": "..." }`
* Waterflow: `{ "device_id": "esp32-001", "sensor": "waterflow", "l_per_min": 3.5, "ts": 1732462345123, "msg_id": "..." }`
* Waterlevel: `{ "device_id": "esp32-001", "sensor": "waterlevel", "cm": 14.2, "ts": 1732462345123, "msg_id": "..." }`
* Control command: `{ "command": "motor", "desired_state": "on", "ts": 1732462345123, "issued_by": "user:123", "msg_id": "..." }`

---

## 7. **Configuration**

Use `.env` for secrets and environment-specific settings:

* `APP_ENV=development|staging|production`
* `SECRET_KEY=<jwt_secret>`
* `ACCESS_TOKEN_EXPIRE_MINUTES=43200`  (example: 30 days for mobile)
* `DB_URL=mysql+pymysql://user:pass@host:3306/vertical_farm`
* `MQTT_BROKER_HOST=localhost`
* `MQTT_BROKER_PORT=1883`
* `MQTT_USERNAME=server`
* `MQTT_PASSWORD=<broker_password>`
* `WEBSOCKET_ALLOWED_ORIGINS=https://app.example.com`
* `LOG_LEVEL=INFO`

---

## 8. **Data Modeling Details**

Tables and key columns:

* **Users**: `id`, `email` (unique), `password_hash`, `role` (admin|user), `created_at`
* **Devices**: `id`, `device_id` (unique), `type`, `location`, `status`, `last_seen_at`, `owner_user_id`
* **Sensors**: `id`, `sensor_id` (unique), `type`, `device_id` (FK), `unit`
* **SensorData**: `id`, `sensor_id` (FK), `ts`, `value_numeric`, `value_text`
* **ControlLogs**: `id`, `command`, `device_id` (FK), `user_id` (FK), `desired_state`, `ts`, `result`

Indexes:

* `SensorData(sensor_id, ts DESC)`
* `Devices(device_id)`
* `ControlLogs(device_id, ts)`

Retention:

* Raw sensor data retained 12 months; rollups (1m, 15m, 1h) stored for long-term analytics.

---

## 9. **API Standards (FastAPI)**

* **Auth**: Bearer JWT; refresh token optional for mobile.
* **Versioning**: Prefix all endpoints with `/api/v1`.
* **Errors**: RFC 7807-style JSON problem details.
* **Rate Limits**: 60 req/min per user; 600 req/min per IP for unauthenticated.
* **Pagination**: Cursor-based (`next_cursor`, `limit` default 50, max 200).
* **WebSocket**: Auth via query token; disconnect on token expiry.

---

## 10. **Security**

* **Transport**: Enforce TLS for REST/WebSocket. Use TLS or secure network for MQTT.
* **JWT**: HS256 with strong `SECRET_KEY`; rotation policy every 90 days.
* **RBAC**: Admin can manage any device; users only their devices.
* **Device Provisioning**: Devices register with one-time claim token; server issues `mqtt_username/password` scoped to `device_id` topics.
* **Secrets**: Use `.env` locally, secrets manager in production.
* **Input Validation**: Pydantic models for all payloads; reject unknown fields.
* **Audit**: Log admin actions and control commands; immutable storage optional.

---

## 11. **Reliability & Performance**

* **Targets**: p95 API latency < 200 ms; ingestion pipeline end-to-end < 1 s.
* **Backpressure**: Use bounded queues for MQTT → DB; drop oldest on overflow with metrics.
* **Reconnect Strategy**: Exponential backoff for MQTT and DB.
* **Batching**: Optional batch inserts for high-throughput sensor streams.

---

## 12. **Logging & Observability**

* **Structured Logs**: JSON logs with `trace_id`, `device_id`, `msg_id`.
* **Metrics**: Prometheus endpoints (`/metrics`), track MQTT lag, insert rate, errors.
* **Tracing**: OpenTelemetry instrumentation for FastAPI and DB calls.
* **Dashboards**: Grafana for latency, error rate, device online/offline.

---

## 13. **Testing Strategy**

* **Unit Tests**: Pydantic models, services, MQTT handlers.
* **Integration Tests**: Spin up Mosquitto and MySQL with Docker Compose; test end-to-end ingestion.
* **Contract Tests**: Validate payload schemas from devices.
* **Load Tests**: Simulate 100+ devices publishing at target rates.

---

## 14. **Deployment & Operations**

* **Containerization**: Docker image with non-root user; healthchecks.
* **Process Manager**: Uvicorn behind Gunicorn; graceful shutdown.
* **Reverse Proxy**: Nginx with HTTP/2, gzip, CORS.
* **Migrations**: Alembic on startup in controlled mode; CI gate for migrations.
* **Backups**: Daily MySQL backups; PITR if using managed MySQL.
* **Disaster Recovery**: RPO 24h, RTO 4h (initial targets).

---

## 15. **Directory Structure (Proposed)**

```
app/
  main.py
  api/
  core/        # config, security, deps
  models/      # SQLAlchemy models
  schemas/     # Pydantic schemas
  services/    # mqtt, control, devices
  db/          # session, migrations
tests/
.env.example
alembic/
docker/
```

---

## 16. **Edge Cases & Considerations**

* Device clock drift → reconcile using server receive time when delta > 10 s.
* Duplicate messages → dedup by `(device_id, msg_id)` unique constraint.
* Offline buffering on device → allow late-arriving data with original timestamps.
* Timezone → store UTC only.
* Units → enforce SI; reject unknown or inconsistent units.

---

## 17. **Acceptance Criteria (MVP)**

* Devices publish sensor data; server stores in MySQL with correct schema.
* Mobile app retrieves latest metrics and historical ranges with pagination.
* Server issues and logs control commands; devices act and acknowledge.
* WebSocket pushes realtime updates within 1 second p95.
* Full project runs locally via venv + Docker for broker and DB.

---

## 7. **Future Enhancements**

* AI Microservice (disease detection API).
* Admin dashboard (React/Next.js).
* Notification system (water shortage, temp/humidity alert).
* Role-based device groups (multiple farms, multiple users).


