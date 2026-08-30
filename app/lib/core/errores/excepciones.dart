library;

class NfcNoDisponible implements Exception {
  final String mensaje;
  const NfcNoDisponible([this.mensaje = 'Este equipo no tiene NFC.']);
  @override
  String toString() => mensaje;
}

class BleNoDisponible implements Exception {
  final String mensaje;
  const BleNoDisponible([this.mensaje = 'Este equipo no tiene Bluetooth LE.']);
  @override
  String toString() => mensaje;
}

class EstacionNoEncontrada implements Exception {
  final String mensaje;
  const EstacionNoEncontrada([this.mensaje = 'No se encontró la estación por BLE en 10 segundos.']);
  @override
  String toString() => mensaje;
}

class ErrorRed implements Exception {
  final String mensaje;
  const ErrorRed(this.mensaje);
  @override
  String toString() => mensaje;
}
