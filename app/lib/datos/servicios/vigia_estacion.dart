import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:uuid/uuid.dart';
import '../../dominio/entidades/lectura.dart';
import '../datasources/cola_local.dart';
import 'pasarela_ble.dart';
import 'sincronizador.dart';

const _uuid = Uuid();
const double _umbralMovimientoMs2 = 1.2; // desviación respecto a 9.8 m/s² que se considera "en movimiento"

enum TipoEstadoVigia { muestraCapturada, loteSincronizado }

class EstadoVigia {
  final TipoEstadoVigia tipo;
  final Lectura? lectura;
  final int? cantidad;
  const EstadoVigia._(this.tipo, {this.lectura, this.cantidad});
  const EstadoVigia.muestraCapturada(Lectura l) : this._(TipoEstadoVigia.muestraCapturada, lectura: l);
  const EstadoVigia.loteSincronizado(int cantidad) : this._(TipoEstadoVigia.loteSincronizado, cantidad: cantidad);
}

class VigiaEstacion {
  final PasarelaBle pasarela;
  final ColaLocal cola;
  final Sincronizador sincronizador;
  final String estacionId;

  StreamSubscription? _subMuestras;
  StreamSubscription<AccelerometerEvent>? _subAccel;
  Timer? _timerSincronizacion;
  Position? _ultimaPosicion;
  bool _enMovimiento = false;

  final _controladorEstado = StreamController<EstadoVigia>.broadcast();
  Stream<EstadoVigia> get estado => _controladorEstado.stream;

  VigiaEstacion({
    required this.pasarela,
    required this.cola,
    required this.sincronizador,
    required this.estacionId,
  });

  Future<void> iniciar(String nombreBle) async {
    await pasarela.conectar(nombreBle);

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((p) => _ultimaPosicion = p);

    _subAccel = accelerometerEventStream().listen((e) {
      final desviacion = (e.x.abs() + e.y.abs() + (e.z - 9.8).abs());
      _enMovimiento = desviacion > _umbralMovimientoMs2;
    });

    _subMuestras = pasarela.muestras.listen((m) async {
      final lectura = Lectura(
        claveCliente: _uuid.v4(),
        temperatura: m.temperatura,
        humedad: m.humedad,
        latitud: _ultimaPosicion?.latitude,
        longitud: _ultimaPosicion?.longitude,
        enMovimiento: _enMovimiento,
        medidaEn: DateTime.now().toUtc(),
      );
      await cola.encolar(lectura); // primero local: nunca se pierde (regla del banco)
      _controladorEstado.add(EstadoVigia.muestraCapturada(lectura));
    });

    // Cada 10 s intenta drenar la cola si hay red, en vez de reintentar
    // por cada muestra individual.
    _timerSincronizacion = Timer.periodic(const Duration(seconds: 10), (_) async {
      final enviadas = await sincronizador.sincronizarPendientes(estacionId);
      if (enviadas > 0) _controladorEstado.add(EstadoVigia.loteSincronizado(enviadas));
    });
  }

  Future<void> detener() async {
    await _subMuestras?.cancel();
    await _subAccel?.cancel();
    _timerSincronizacion?.cancel();
    await pasarela.desconectar();
  }

  void dispose() {
    _controladorEstado.close();
    pasarela.dispose();
  }
}
