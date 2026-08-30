import 'package:flutter_test/flutter_test.dart';
import 'package:p8_estacion_campo/dominio/servicios/reconexion.dart';

void main() {
  group('calcularEsperaReconexion', () {
    test('crece exponencialmente: 1s, 2s, 4s, 8s, 16s', () {
      expect(calcularEsperaReconexion(0), const Duration(seconds: 1));
      expect(calcularEsperaReconexion(1), const Duration(seconds: 2));
      expect(calcularEsperaReconexion(2), const Duration(seconds: 4));
      expect(calcularEsperaReconexion(3), const Duration(seconds: 8));
      expect(calcularEsperaReconexion(4), const Duration(seconds: 16));
    });

    test('se limita al techo de 30 segundos', () {
      expect(calcularEsperaReconexion(5), const Duration(seconds: 30));
      expect(calcularEsperaReconexion(10), const Duration(seconds: 30));
      expect(calcularEsperaReconexion(100), const Duration(seconds: 30));
    });

    test('un intento negativo se trata como el intento 0', () {
      expect(calcularEsperaReconexion(-1), const Duration(seconds: 1));
    });

    test('respeta un techo personalizado', () {
      expect(calcularEsperaReconexion(10, techoSegundos: 60), const Duration(seconds: 60));
    });
  });
}
