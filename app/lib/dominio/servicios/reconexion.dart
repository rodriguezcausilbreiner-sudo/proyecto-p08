import 'dart:math';

/// Calcula la espera antes del próximo intento de reconexión BLE:
/// 1 s, 2 s, 4 s, 8 s, 16 s, 30 s (techo), 30 s, 30 s...
///
/// Lógica pura -sin flutter_blue_plus, sin Timer- para poder probarla
/// con `flutter test` sin dispositivo físico (RF-03: "reconectar
/// automáticamente al perder el enlace, con espera exponencial").
Duration calcularEsperaReconexion(int intentoNumero, {int techoSegundos = 30}) {
  if (intentoNumero < 0) intentoNumero = 0;
  final segundos = min(techoSegundos, pow(2, intentoNumero).toInt());
  return Duration(seconds: segundos);
}
