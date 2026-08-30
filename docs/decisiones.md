# Decisiones técnicas · P8 Estación de campo conectada (capstone)

> Completen los `[POR COMPLETAR]` con datos reales de su prueba de campo
> antes de entregar (semana 5). Este es el archivo que más pesa en la
> nota de todo el banco de proyectos.

## 1. Verificación previa obligatoria (antes de asignar/ejecutar)

Según la guía, deben confirmar el inventario real de equipos: NFC y
Bluetooth LE no están disponibles en todos los celulares de los
aprendices. Si no hay ESP32 disponible por articulación con Electrónica,
la guía permite sustituirlo por un segundo celular emulando el
periférico BLE, declarando el cambio aquí.

`[POR COMPLETAR]`: ¿el equipo usó un ESP32 real o el sustituto de
segundo celular? Si fue el sustituto, describir cómo se simuló el
perfil GATT.

## 2. Perfil GATT y formato del paquete

Se definió un paquete de 4 bytes (temperatura + humedad, ver
`docs/firmware_esp32_referencia.ino` y
`dominio/servicios/decodificador_gatt.dart`) en vez de dos
características GATT separadas, para minimizar el número de
notificaciones BLE por ciclo de lectura (cada notificación tiene
overhead de radio). Ambos extremos (firmware y app) deben mantenerse
sincronizados si cambia el formato — están cubiertos por pruebas
(`test/decodificador_gatt_test.dart`) para detectar esa clase de
desajuste temprano.

## 3. Espera exponencial de reconexión (1s → 30s techo)

Implementada en `dominio/servicios/reconexion.dart` y probada sin
dispositivo. El techo de 30 s evita que la app reintente agresivamente
(y gaste batería) si el ESP32 quedó apagado por un rato largo, pero
sigue intentando indefinidamente sin intervención manual (RF-03).

`[POR COMPLETAR]`: al apagar y volver a encender el ESP32 en la prueba
real, ¿cuántos segundos tardó la app en reconectar? ¿Coincide con la
progresión esperada (1, 2, 4, 8, 16, 30, 30...)?

## 4. Umbral de "en movimiento" (desviación > 1.2 m/s² respecto a 9.8)

Definido en `datos/servicios/vigia_estacion.dart` a partir de la suma de
desviaciones de los tres ejes del acelerómetro respecto al vector de
gravedad en reposo. Es una heurística simple, no un clasificador de
actividad: sirve para anotar la lectura de telemetría, no para tomar
decisiones críticas.

`[POR COMPLETAR]`: ¿qué valor de umbral funcionó mejor en la prueba
real? ¿Hubo falsos positivos al caminar despacio con el celular en el
bolsillo?

## 5. Umbral de alerta del panel web (35°C por defecto)

Aplicado en el servidor (`api/src/servicios/alertas.js`), no en el
panel: así, si se conectan varios paneles o se agrega un canal de
notificación adicional en el futuro, todos ven el mismo criterio de
alerta sin duplicar la lógica.

`[POR COMPLETAR]`: ¿el equipo ajustó el umbral según el ambiente real
donde se hizo la prueba (interior vs. campo abierto)?

## 6. Idempotencia de la cola offline (mismo patrón que P1)

`ColaLocal` genera un UUID por lectura (`claveCliente`) antes de
guardarla, y el servidor usa `upsert` sobre `(estacionId, claveCliente)`.
Esto significa que reenviar la cola completa tras recuperar señal —
incluso si algunas lecturas ya se habían sincronizado antes de perder la
conexión — nunca duplica filas en la base de datos.

## 7. Qué se probó en un equipo de gama baja

`[POR COMPLETAR]`: equipo usado, disponibilidad real de NFC/BLE, y
comportamiento observado (la guía advierte explícitamente que estas
capacidades faltan en equipos de gama baja).
