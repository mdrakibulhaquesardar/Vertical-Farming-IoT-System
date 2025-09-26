# ফিচার সারাংশ (এ পর্যন্ত সম্পন্ন)

## সার্ভার (FastAPI + MySQL + MQTT)
- ডিভাইস রেজিস্ট্রেশন: `POST /api/v1/devices/register`, `GET /api/v1/devices/`
- সেন্সর তালিকা সহ ডিভাইস রেসপন্স (embedded sensors)
- ডাটা ইনজেশন (MQTT):
  - টপিক: `farm/{device_id}/sensor/{temperature|humidity|waterflow|waterlevel}`
  - ইনকামিং JSON থেকে ভ্যালু ম্যাপিং ও MySQL-এ সংরক্ষণ
- ডাটা API:
  - সর্বশেষ রিডিং (প্রতি ডিভাইস): `GET /api/v1/data/latest/{device_id}`
  - হিস্ট্রি (প্রতি সেন্সর): `GET /api/v1/data/history/{sensor_id}`
- কন্ট্রোল API (Server → ESP32):
  - `POST /api/v1/control/{device_id}` → MQTT publish `farm/{device_id}/control/{motor|light|relay}` (QoS1, retain)
- রিয়েলটাইম স্ট্রিমিং (WebSocket):
  - `ws://localhost:8000/api/v1/realtime/{device_id}` → ইনজেস্টেড সেন্সর ইভেন্ট লাইভ স্ট্রিম
- থ্রেশহোল্ড ও অ্যালার্টস:
  - মডেল/মাইগ্রেশন: `thresholds`
  - সেট/তালিকা: `PUT/GET /api/v1/thresholds/{device_id}`
  - ব্রিচ হলে: WebSocket-এ `{"alert": {...}}` এবং MQTT `farm/{device_id}/alert/{sensor_type}`
- অবকাঠামো:
  - Docker Compose: `mysql`, `mosquitto`, `app`
  - Mosquitto কনফিগ (0.0.0.0:1883, anonymous=true) – লোকাল টেস্টের জন্য
  - Alembic মাইগ্রেশন (স্কিমা জেনারেট/আপগ্রেড)
  - ডেভেলপমেন্ট শর্টকাট স্ক্রিপ্ট: `scripts/dev.ps1`, `scripts/dev.bat`

## মোবাইল অ্যাপের জন্য (REST + WebSocket)
- হেলথ: `GET /api/v1/health`
- ডিভাইস: রেজিস্টার/লিস্ট + সেন্সর এমবেডেড
- ডাটা: সর্বশেষ ও হিস্ট্রি API
- কন্ট্রোল: মোটর/লাইট/রিলে ON/OFF কমান্ড
- রিয়েলটাইম: WebSocket সাবস্ক্রাইব করে লাইভ সেন্সর আপডেট/অ্যালার্ট

## ESP32 (ডিভাইস) ইন্টিগ্রেশন
- সেন্সর পাবলিশ টপিক (উদাহরণ):
  - `farm/esp32-001/sensor/temperature` → `{ "value_c": 25.4 }`
  - `farm/esp32-001/sensor/humidity` → `{ "value_pct": 60.2 }`
  - `farm/esp32-001/sensor/waterflow` → `{ "l_per_min": 3.5 }`
  - `farm/esp32-001/sensor/waterlevel` → `{ "cm": 14.2 }`
- কন্ট্রোল সাবস্ক্রাইব:
  - `farm/esp32-001/control/motor|light|relay` (retained state)
- অ্যালার্ট টপিক (Server → ESP):
  - `farm/esp32-001/alert/{sensor_type}` (threshold breach)

## দ্রুত টেস্ট (লোকাল)
- MQTT (Explorer/Postman):
  - Host: `localhost`, Port: `1883`, MQTT v5/3.1.1, no auth
  - Subscribe: `farm/#`
  - Publish: `farm/esp32-001/sensor/temperature` → `{ "value_c": 31.2 }`
- REST:
  - ডিভাইস: `GET http://localhost:8000/api/v1/devices/`
  - ডাটা: `GET http://localhost:8000/api/v1/data/latest/esp32-001`
  - কন্ট্রোল: `POST http://localhost:8000/api/v1/control/esp32-001` → `{ "target": "motor", "desired_state": "on" }`
- WebSocket:
  - `ws://localhost:8000/api/v1/realtime/esp32-001` (ইভেন্ট/অ্যালার্ট লাইভ)

## নেক্সট স্টেপ (প্রস্তাব)
- CORS সক্ষমকরণ (ফ্রন্টএন্ড ডোমেইনের জন্য)
- Auth/JWT (পরবর্তীতে)
- Rate limiting, logging/metrics polish
- README/ডকস (Quickstart + এন্ডপয়েন্ট ম্যাপ)
