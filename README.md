# P8 · Estación de campo conectada (capstone)

Actividad No. 5 — SENA ADSO, ficha 3278641. Cierre del ciclo: sensor
externo por BLE, identificación por NFC y telemetría en tiempo real.

## Arquitectura

```
[ESP32 + DHT22]
   | BLE GATT · notificación cada 5 s
   v
[App Flutter] -- enriquece con GPS + estado de movimiento
   | -- si no hay red: cola en SQLite (idempotente, mismo patrón que P1)
   | HTTP en lote al reconectar
   v
[API Express] -- valida, persiste en PostgreSQL, difunde por Socket.IO
   v
[Panel web] -- gráfica en vivo + alertas por umbral
```

## Estructura

```
proyecto-p08/
├── app/         # Flutter + flutter_blue_plus + nfc_manager + sqflite
├── api/         # Node.js + Express + Socket.IO + Prisma + PostgreSQL
├── panel-web/   # HTML/JS estático servido por la propia API en /panel
└── docs/        # decisiones.md, contrato-api.md, firmware ESP32 de referencia
```

## Backend (`api/`)

```bash
cd api
cp .env.example .env
npm install
npx prisma migrate dev
npm run dev
```

Registra una estación de prueba (o usa `POST /api/estaciones`):
```sql
INSERT INTO estacion (nombre_ble, ubicacion) VALUES ('ESTACION-CEET-01', 'Patio central');
```

Abre el panel en `http://localhost:3000/panel` y pega el UUID de la
estación para suscribirte.

Pruebas (sin base de datos):
```bash
npm test
```

## Firmware ESP32

`docs/firmware_esp32_referencia.ino` implementa el mismo perfil GATT que
espera la app (servicio `0000181a-...`, característica `00002a6e-...`,
paquete de 4 bytes: temperatura + humedad). Si no hay ESP32 disponible,
ver la sección "Verificación previa" de `docs/decisiones.md` para el
sustituto autorizado por la guía (segundo celular emulando el
periférico).

## Frontend (`app/`)

```bash
cd app
flutter pub get
flutter run
```

Ajusta `baseUrlApi` en `lib/presentacion/providers/proveedores_nucleo.dart`.

Pruebas sin dispositivo (las dos piezas de lógica pura del proyecto):
```bash
flutter test
```

## Requisitos funcionales cubiertos

| RF | Descripción | Dónde |
|---|---|---|
| RF-01 | Identificar estación por NFC | `datos/servicios/lector_nfc.dart` + `GET /api/estaciones/ble/:nombreBle` |
| RF-02 | Descubrir, conectar y suscribirse al ESP32 por BLE | `datos/servicios/pasarela_ble.dart` |
| RF-03 | Reconexión automática con espera exponencial | `dominio/servicios/reconexion.dart` (probado) |
| RF-04 | Enriquecer con GPS + estado de movimiento | `datos/servicios/vigia_estacion.dart` |
| RF-05 | Retransmitir por WebSocket + cola local sin red | `tiempo-real/telemetria.js` + `datos/datasources/cola_local.dart` |
| RF-06 | Panel web con gráfica de 2h + alertas por umbral | `panel-web/src/index.html` + `servicios/alertas.js` |

## Criterios bloqueantes — checklist antes de sustentar

- [ ] Apagar el ESP32 y volverlo a encender produce reconexión automática sin tocar la app.
- [ ] Con el celular en modo avión, las lecturas se acumulan en la cola local y se envían completas al reconectar.
- [ ] El panel web refleja la lectura en menos de dos segundos desde que el sensor la emite.
- [ ] La app informa con claridad cuando el equipo no tiene NFC o BLE, sin cerrarse (`NfcNoDisponible`, `BleNoDisponible`).

## Pendiente por completar (equipo)

1. `npx prisma migrate dev` contra su base de datos real.
2. Cargar el firmware de referencia (o adaptarlo) al ESP32 real, o preparar el sustituto de segundo celular.
3. Probar apagar/encender el ESP32 a mitad de sesión y documentar el tiempo real de reconexión en `docs/decisiones.md`.
4. Probar con al menos dos equipos físicos, confirmando disponibilidad real de NFC/BLE antes.
5. Mínimo 8 commits descriptivos repartidos en el tiempo de desarrollo.
