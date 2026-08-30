import 'dart:typed_data';

/// El ESP32 publica la temperatura como entero con signo de 16 bits en
/// centésimas de grado (little-endian): 2350 -> 23.50 °C. Es lógica pura
/// sobre bytes, sin flutter_blue_plus, así que se prueba sin dispositivo.
double decodificarTemperatura(List<int> bytes) {
  if (bytes.length < 2) {
    throw ArgumentError('Se esperaban al menos 2 bytes para decodificar la temperatura');
  }
  final crudo = ByteData.sublistView(Uint8List.fromList(bytes)).getInt16(0, Endian.little);
  return crudo / 100.0;
}

/// Humedad relativa como entero sin signo de 16 bits en centésimas de
/// porcentaje, en los bytes 2-3 del mismo paquete de notificación.
double? decodificarHumedad(List<int> bytes) {
  if (bytes.length < 4) return null; // el ESP32 puede no reportar humedad
  final crudo = ByteData.sublistView(Uint8List.fromList(bytes)).getUint16(2, Endian.little);
  return crudo / 100.0;
}
