import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../datos/datasources/api_estacion_datasource.dart';
import '../../datos/datasources/cola_local.dart';
import '../../datos/servicios/lector_nfc.dart';
import '../../datos/servicios/pasarela_ble.dart';
import '../../datos/servicios/sincronizador.dart';

const String baseUrlApi = 'http://10.0.2.2:3000'; // ajustar en dispositivo físico

final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(baseUrl: '$baseUrlApi/api')));

final apiEstacionDatasourceProvider = Provider<ApiEstacionDatasource>(
  (ref) => ApiEstacionDatasource(ref.watch(dioProvider)),
);

final colaLocalProvider = Provider<ColaLocal>((ref) => ColaLocal());

final sincronizadorProvider = Provider<Sincronizador>(
  (ref) => Sincronizador(ref.watch(apiEstacionDatasourceProvider), ref.watch(colaLocalProvider)),
);

final lectorNfcProvider = Provider<LectorNfc>((ref) => LectorNfc());

final pasarelaBleProvider = Provider.autoDispose<PasarelaBle>((ref) {
  final pasarela = PasarelaBle();
  ref.onDispose(() {
    pasarela.desconectar();
    pasarela.dispose();
  });
  return pasarela;
});
