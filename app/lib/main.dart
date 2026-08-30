import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentacion/paginas/pagina_identificar_estacion.dart';

void main() {
  runApp(const ProviderScope(child: AppEstacionCampo()));
}

class AppEstacionCampo extends StatelessWidget {
  const AppEstacionCampo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P8 · Estación de campo conectada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const PaginaIdentificarEstacion(),
    );
  }
}
