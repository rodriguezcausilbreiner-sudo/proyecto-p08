class Lectura {
  final String claveCliente; // UUID generado en el cliente: idempotencia
  final double temperatura;
  final double? humedad;
  final double? latitud;
  final double? longitud;
  final bool enMovimiento;
  final DateTime medidaEn;

  const Lectura({
    required this.claveCliente,
    required this.temperatura,
    this.humedad,
    this.latitud,
    this.longitud,
    required this.enMovimiento,
    required this.medidaEn,
  });
}
