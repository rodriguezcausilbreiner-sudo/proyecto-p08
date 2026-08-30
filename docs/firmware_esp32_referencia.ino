/*
 * P8 · Estación de campo conectada - firmware de referencia ESP32
 * Requiere: sensor DHT22 en el pin indicado, librería "DHT sensor library"
 * (Adafruit) y "ESP32 BLE Arduino" (incluida en el core de ESP32).
 *
 * Perfil GATT: debe coincidir EXACTO con app/lib/datos/servicios/pasarela_ble.dart
 *   Servicio:        0000181a-0000-1000-8000-00805f9b34fb (Environmental Sensing)
 *   Característica:  00002a6e-0000-1000-8000-00805f9b34fb (Temperature)
 *
 * Formato del paquete notificado (4 bytes, little-endian):
 *   bytes 0-1: temperatura en centésimas de grado, int16 con signo
 *   bytes 2-3: humedad relativa en centésimas de %, uint16
 */

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <DHT.h>

#define PIN_DHT 4
#define TIPO_DHT DHT22

#define UUID_SERVICIO "0000181a-0000-1000-8000-00805f9b34fb"
#define UUID_CARACTERISTICA "00002a6e-0000-1000-8000-00805f9b34fb"

// Debe coincidir con el nombreBle registrado en la tabla `estacion` y
// con el contenido de la etiqueta NFC (RF-01: identificación cruzada).
#define NOMBRE_BLE "ESTACION-CEET-01"

DHT dht(PIN_DHT, TIPO_DHT);
BLECharacteristic *caracteristica;
bool dispositivoConectado = false;

class CallbacksServidor : public BLEServerCallbacks {
  void onConnect(BLEServer *servidor) override { dispositivoConectado = true; }
  void onDisconnect(BLEServer *servidor) override {
    dispositivoConectado = false;
    servidor->getAdvertising()->start(); // vuelve a anunciarse para que el celular reconecte
  }
};

void setup() {
  Serial.begin(115200);
  dht.begin();

  BLEDevice::init(NOMBRE_BLE);
  BLEServer *servidor = BLEDevice::createServer();
  servidor->setCallbacks(new CallbacksServidor());

  BLEService *servicio = servidor->createService(UUID_SERVICIO);
  caracteristica = servicio->createCharacteristic(
      UUID_CARACTERISTICA,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
  caracteristica->addDescriptor(new BLE2902());

  servicio->start();
  servidor->getAdvertising()->start();
  Serial.println("Estación BLE anunciándose como " NOMBRE_BLE);
}

void loop() {
  float temperatura = dht.readTemperature();
  float humedad = dht.readHumidity();

  if (!isnan(temperatura) && !isnan(humedad) && dispositivoConectado) {
    int16_t tempCentesimas = (int16_t)(temperatura * 100);
    uint16_t humCentesimas = (uint16_t)(humedad * 100);

    uint8_t paquete[4];
    paquete[0] = tempCentesimas & 0xFF;
    paquete[1] = (tempCentesimas >> 8) & 0xFF;
    paquete[2] = humCentesimas & 0xFF;
    paquete[3] = (humCentesimas >> 8) & 0xFF;

    caracteristica->setValue(paquete, 4);
    caracteristica->notify();

    Serial.printf("Temp: %.2f C  Hum: %.2f %%\n", temperatura, humedad);
  }

  delay(5000); // una notificación cada 5 s (ver RF-02 del contrato)
}
