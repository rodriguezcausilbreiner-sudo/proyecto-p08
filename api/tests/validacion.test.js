import { test } from 'node:test';
import assert from 'node:assert/strict';
import { evaluarAlerta } from '../src/servicios/alertas.js';
import { loteLecturasSchema } from '../src/servicios/validacion.js';

test('no alerta por debajo del umbral (35°C por defecto)', () => {
  assert.equal(evaluarAlerta(30), false);
});

test('alerta justo en el umbral', () => {
  assert.equal(evaluarAlerta(35), true);
});

test('alerta por encima del umbral', () => {
  assert.equal(evaluarAlerta(40), true);
});

test('loteLecturasSchema exige claveCliente UUID para idempotencia', () => {
  assert.throws(() =>
    loteLecturasSchema.parse({
      lecturas: [{ temperatura: 25, medidaEn: new Date().toISOString(), claveCliente: 'no-es-uuid' }],
    }),
  );
});

test('loteLecturasSchema rechaza temperatura fuera del rango del DHT22', () => {
  assert.throws(() =>
    loteLecturasSchema.parse({
      lecturas: [{ temperatura: 200, medidaEn: new Date().toISOString(), claveCliente: crypto.randomUUID() }],
    }),
  );
});

test('loteLecturasSchema acepta un lote válido con humedad y ubicación', () => {
  const lote = {
    lecturas: [
      {
        temperatura: 22.5,
        humedad: 55,
        latitud: 4.6486,
        longitud: -74.0844,
        enMovimiento: false,
        medidaEn: new Date().toISOString(),
        claveCliente: crypto.randomUUID(),
      },
    ],
  };
  assert.doesNotThrow(() => loteLecturasSchema.parse(lote));
});

test('loteLecturasSchema rechaza lotes vacíos', () => {
  assert.throws(() => loteLecturasSchema.parse({ lecturas: [] }));
});
