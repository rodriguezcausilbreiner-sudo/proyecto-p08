import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/errores/excepciones.dart';
import '../datasources/api_estacion_datasource.dart';
import '../datasources/cola_local.dart';

class Sincronizador {
  final ApiEstacionDatasource api;
  final ColaLocal cola;
  const Sincronizador(this.api, this.cola);

  Future<int> sincronizarPendientes(String estacionId) async {
    final conectividad = await Connectivity().checkConnectivity();
    if (conectividad.contains(ConnectivityResult.none)) return 0;

    final pendientes = await cola.pendientes();
    if (pendientes.isEmpty) return 0;

    try {
      await api.subirLote(estacionId, pendientes);
      await cola.marcarEnviadas(pendientes.map((l) => l.claveCliente).toList());
      return pendientes.length;
    } on ErrorRed {
      return 0; // se reintentará en el próximo ciclo de conectividad
    }
  }
}
