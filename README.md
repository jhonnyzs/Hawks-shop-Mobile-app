# Hawkstronix Shop — Staff Mobile App

A Flutter app for shop staff to track **inventory and orders** from their phone,
talking to the desktop Hawks Shop app over the shop Wi-Fi. Hawkstronix dark + gold
theme to match the desktop and the Cal-Station.

## What it does

- **Pair** with the shop PC (enter the address + sign in with a shop account —
  the desktop shows the address under **Admin → Mobile**).
- **Dashboard** — open jobs, new orders, low-stock count, product count.
- **Inventory** — search parts/ECUs, see stock levels (colour-coded), and adjust
  stock on the spot (restock / count fixes).
- **Orders** — view product sales and change their status.
- **Jobs** — view harness/tuning work and move it along the pipeline.

It talks to the desktop **mobile bridge** (`PC app/src/mobile_bridge.py`), a small
token-protected HTTP API on `http://<shop-pc>:9830`.

## Run / build

```bash
flutter pub get
flutter run                 # on a connected phone/emulator
flutter build apk --release # -> build/app/outputs/flutter-apk/app-release.apk
```

## Structure

```
lib/
  main.dart                 entry; routes to Connect or Home based on pairing
  theme.dart                Hawkstronix colours + theme + HAWKS wordmark
  api.dart                  ApiService — talks to the desktop bridge
  screens/
    connect_screen.dart     pair with the shop PC (address + login)
    home_screen.dart        dashboard KPIs + navigation
    inventory_screen.dart   search + stock adjust
    orders_screen.dart      orders + status
    jobs_screen.dart        jobs + status
```

## API (desktop bridge) it uses

| Method | Path                     | Purpose                         |
| ------ | ------------------------ | ------------------------------- |
| GET    | `/api/ping`              | discover / verify (open)        |
| POST   | `/api/pair`              | sign in → returns the token     |
| GET    | `/api/summary`           | dashboard KPIs                  |
| GET    | `/api/inventory?q=`      | stock list                      |
| POST   | `/api/inventory/adjust`  | change a product's quantity     |
| GET    | `/api/orders?status=`    | orders                          |
| POST   | `/api/order/status`      | set an order's status           |
| GET    | `/api/jobs?status=`      | jobs                            |
| POST   | `/api/job/status`        | set a job's status              |

All except `/api/ping` require the `X-Hawks-Token` header.
