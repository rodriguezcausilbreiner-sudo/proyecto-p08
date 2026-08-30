import 'package:flutter_test/flutter_test.dart';
import 'package:p8_estacion_campo/dominio/servicios/decodificador_gatt.dart';

void main() {
  group('decodificarTemperatura', () {
    test('decodifica 2350 (little-endian) como 23.50°C', () {
      // 2350 en little-endian de 16 bits: byte bajo 0x2E (46), byte alto 0x09 (9)
      // 2350 = 0x092E -> bytes LE: [0x2E, 0x09] = [46, 9]
      expect(decodificarTemperatura([46, 9]), closeTo(23.50, 0.001));
    });

    test('decodifica correctamente un valor negativo (bajo cero)', () {
      // -500 centésimas = -5.00°C, en complemento a dos de 16 bits little-endian
      const valor = -500;
      final bytes = _int16LeBytes(valor);
      expect(decodificarTemperatura(bytes), closeTo(-5.0, 0.001));
    });

    test('lanza ArgumentError si llegan menos de 2 bytes', () {
      expect(() => decodificarTemperatura([1]), throwsArgumentError);
    });
  });

  group('decodificarHumedad', () {
    test('decodifica los bytes 2-3 como porcentaje en centésimas', () {
      // Temperatura irrelevante aquí (bytes 0-1), humedad = 5500 -> 55.00%
      final bytes = [0, 0, ..._uint16LeBytes(5500)];
      expect(decodificarHumedad(bytes), closeTo(55.0, 0.001));
    });

    test('devuelve null si el paquete no trae humedad (menos de 4 bytes)', () {
      expect(decodificarHumedad([46, 9]), isNull);
    });
  });
}

List<int> _int16LeBytes(int valor) {
  final v = valor < 0 ? valor + 0x10000 : valor;
  return [v & 0xFF, (v >> 8) & 0xFF];
}

List<int> _uint16LeBytes(int valor) => [valor & 0xFF, (valor >> 8) & 0xFF];
