import 'package:dio/dio.dart';
import '../../core/errores/excepciones.dart';
import '../../dominio/entidades/lectura.dart';

class ApiEstacionDatasource {
  final Dio dio;
  const ApiEstacionDatasource(this.dio);

  Future<Map<String, dynamic>> resolverEstacionPorNombreBle(String nombreBle) async {
    try {
      final r = await dio.get('/estaciones/ble/$nombreBle');
      return r.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ErrorRed(_mensajeDe(e));
    }
  }

  Future<void> subirLote(String estacionId, List<Lectura> lecturas) async {
    try {
      await dio.post('/estaciones/$estacionId/lecturas/lote', data: {
        'lecturas': lecturas
            .map((l) => {
                  'temperatura': l.temperatura,
                  'humedad': l.humedad,
                  'latitud': l.latitud,
                  'longitud': l.longitud,
                  'enMovimiento': l.enMovimiento,
                  'medidaEn': l.medidaEn.toUtc().toIso8601String(),
                  'claveCliente': l.claveCliente,
                })
            .toList(),
      });
    } on DioException catch (e) {
      throw ErrorRed(_mensajeDe(e));
    }
  }

  String _mensajeDe(DioException e) {
    if (e.response?.data is Map && e.response?.data['error'] != null) {
      return e.response!.data['error'] as String;
    }
    return e.message ?? 'Error de red desconocido';
  }
}
