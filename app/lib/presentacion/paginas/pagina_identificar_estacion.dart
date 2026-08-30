import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/proveedores_nucleo.dart';
import 'pagina_telemetria.dart';

class PaginaIdentificarEstacion extends ConsumerStatefulWidget {
  const PaginaIdentificarEstacion({super.key});

  @override
  ConsumerState<PaginaIdentificarEstacion> createState() => _PaginaIdentificarEstacionState();
}

class _PaginaIdentificarEstacionState extends ConsumerState<PaginaIdentificarEstacion> {
  bool _leyendo = false;
  String? _mensaje;

  Future<void> _leerYContinuar() async {
    setState(() {
      _leyendo = true;
      _mensaje = null;
    });
    try {
      final nombreBle = await ref.read(lectorNfcProvider).leerIdentificadorEstacion();
      if (nombreBle == null) {
        setState(() => _mensaje = 'No se pudo leer la etiqueta. Intenta de nuevo.');
        return;
      }
      final estacion = await ref.read(apiEstacionDatasourceProvider).resolverEstacionPorNombreBle(nombreBle);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PaginaTelemetria(estacionId: estacion['id'] as String, nombreBle: nombreBle),
      ));
    } catch (e) {
      setState(() => _mensaje = e.toString());
    } finally {
      if (mounted) setState(() => _leyendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('P8 · Estación de campo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.nfc, size: 96, color: _leyendo ? Colors.teal : Colors.grey),
              const SizedBox(height: 16),
              const Text('Acerca el celular a la etiqueta NFC de la estación', textAlign: TextAlign.center),
              if (_mensaje != null) ...[
                const SizedBox(height: 12),
                Text(_mensaje!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _leyendo ? null : _leerYContinuar,
                icon: _leyendo
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.nfc),
                label: Text(_leyendo ? 'Leyendo…' : 'Leer etiqueta NFC'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
