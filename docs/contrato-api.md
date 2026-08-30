# Contrato de API · P8 Estación de campo conectada

Base URL local: `http://localhost:3000/api`. Panel web en
`http://localhost:3000/panel`. WebSocket en la raíz del mismo servidor.

## POST /api/estaciones

Registra (o recupera, es idempotente vía `upsert`) una estación por su
nombre BLE.

**Body** `{ "nombreBle": "ESTACION-CEET-01", "ubicacion": "Patio central" }`

**Respuesta 201**: objeto `Estacion` con `id`.

## GET /api/estaciones/ble/:nombreBle

Resuelve una estación por el identificador que trae la etiqueta NFC
(RF-01: identificación cruzada NFC → BLE).

**Respuesta 200**: objeto `Estacion`. **404** si no está registrada.

## POST /api/estaciones/:id/lecturas/lote

Sube el lote acumulado en la cola local (RF-05). Idempotente por
`claveCliente`, igual que P1.

**Body**
```json
{
  "lecturas": [
    {
      "temperatura": 23.5,
      "humedad": 55,
      "latitud": 4.6486,
      "longitud": -74.0844,
      "enMovimiento": false,
      "medidaEn": "2026-08-29T15:01:03.000Z",
      "claveCliente": "3f1c2b5e-..."
    }
  ]
}
```

**Respuesta 207**: `{ "procesadas": <n> }`. Cada lectura procesada
también se difunde por WebSocket a la sala de la estación.

## GET /api/estaciones/:id/lecturas?desde=&hasta=

Histórico para graficar en el panel (últimas dos horas por defecto en el
front, ver `panel-web/src/index.html`).

## WebSocket

Sin autenticación (panel de solo lectura). El cliente debe emitir
`suscribir` con el `estacionId` para unirse a su sala.

**Evento `lectura:nueva`** (servidor → cliente): la lectura recién
guardada, con un campo adicional `alerta: boolean` calculado con el
umbral del servidor (RF-06).

## GET /salud

Chequeo de disponibilidad. `{ "estado": "ok" }`.
