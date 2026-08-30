import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/errores/excepciones.dart';
import '../../dominio/servicios/reconexion.dart';
import '../../dominio/servicios/decodificador_gatt.dart';

class PasarelaBle {
  static final _servicio = Guid('0000181a-0000-1000-8000-00805f9b34fb');
  static final _caracteristica = Guid('00002a6e-0000-1000-8000-00805f9b34fb');

  BluetoothDevice? _equipo;
  StreamSubscription<BluetoothConnectionState>? _subEstado;
  StreamSubscription<List<int>>? _subValor;
  int _intentos = 0;
  bool _detenidoManualmente = false;

  final _controladorMuestras = StreamController<({double temperatura, double? humedad})>.broadcast();
  Stream<({double temperatura, double? humedad})> get muestras => _controladorMuestras.stream;

  final _controladorConectado = StreamController<bool>.broadcast();
  Stream<bool> get conectado => _controladorConectado.stream;

  Future<void> conectar(String idEstacion) async {
    _detenidoManualmente = false;

    try {
      await FlutterBluePlus.startScan(withServices: [_servicio], timeout: const Duration(seconds: 10));
      final hallazgo = await FlutterBluePlus.scanResults
          .expand((lista) => lista)
          .firstWhere((r) => r.device.platformName == idEstacion)
          .timeout(const Duration(seconds: 12), onTimeout: () => throw const EstacionNoEncontrada());
      await FlutterBluePlus.stopScan();

      _equipo = hallazgo.device;
      await _equipo!.connect(autoConnect: false);

      _subEstado = _equipo!.connectionState.listen((estado) async {
        if (_detenidoManualmente) return;

        if (estado == BluetoothConnectionState.disconnected) {
          _controladorConectado.add(false);
          // RF-03: reconexión con espera exponencial (lógica probada en
          // dominio/servicios/reconexion.dart).
          final espera = calcularEsperaReconexion(_intentos++);
          await Future.delayed(espera);
          if (!_detenidoManualmente) await conectar(idEstacion);
        } else if (estado == BluetoothConnectionState.connected) {
          _intentos = 0;
          _controladorConectado.add(true);
          await _suscribir();
        }
      });
    } on BleNoDisponible {
      rethrow;
    }
  }

  Future<void> _suscribir() async {
    final servicios = await _equipo!.discoverServices();
    final caracteristica = servicios
        .firstWhere((s) => s.uuid == _servicio)
        .characteristics
        .firstWhere((c) => c.uuid == _caracteristica);

    await caracteristica.setNotifyValue(true);
    _subValor = caracteristica.lastValueStream.listen((bytes) {
      try {
        final temperatura = decodificarTemperatura(bytes);
        final humedad = decodificarHumedad(bytes);
        _controladorMuestras.add((temperatura: temperatura, humedad: humedad));
      } catch (_) {
        // Paquete corrupto: se descarta esta muestra, no se cierra la conexión.
      }
    });
  }

  Future<void> desconectar() async {
    _detenidoManualmente = true;
    await _subValor?.cancel();
    await _subEstado?.cancel();
    await _equipo?.disconnect();
  }

  void dispose() {
    _controladorMuestras.close();
    _controladorConectado.close();
  }
}
