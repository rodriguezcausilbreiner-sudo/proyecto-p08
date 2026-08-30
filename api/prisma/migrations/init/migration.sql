-- P8 · Estación de campo conectada (capstone)

CREATE TABLE estacion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre_ble TEXT UNIQUE NOT NULL,
  ubicacion TEXT,
  creada_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE lectura (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  estacion_id UUID NOT NULL REFERENCES estacion(id),
  temperatura REAL NOT NULL,
  humedad REAL,
  latitud DOUBLE PRECISION,
  longitud DOUBLE PRECISION,
  en_movimiento BOOLEAN NOT NULL DEFAULT false,
  medida_en TIMESTAMPTZ NOT NULL,
  recibida_en TIMESTAMPTZ NOT NULL DEFAULT now(),
  clave_cliente TEXT NOT NULL, -- idempotencia: evita duplicados al reenviar la cola
  UNIQUE (estacion_id, clave_cliente)
);

CREATE INDEX idx_lectura_estacion_fecha ON lectura (estacion_id, medida_en DESC);
