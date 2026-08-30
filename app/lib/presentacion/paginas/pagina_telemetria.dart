import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../datos/servicios/vigia_estacion.dart';
import '../providers/proveedores_nucleo.dart';

class PaginaTelemetria extends ConsumerStatefulWidget {
  final String estacionId;
  final String nombreBle;
  const PaginaTelemetria({super.key, required this.estacionId, required this.nombreBle});

  @override
  ConsumerState<PaginaTelemetria> createState() => _PaginaTelemetriaState();
}

class _PaginaTelemetriaState extends ConsumerState<PaginaTelemetria> {
  VigiaEstacion? _vigia;
  bool _conectado = false;
  double? _ultimaTemperatura;
  double? _ultimaHumedad;
  int _muestrasCapturadas = 0;
  int _muestrasSincronizadas = 0;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final vigia = VigiaEstacion(
      pasarela: ref.read(pasarelaBleProvider),
      cola: ref.read(colaLocalProvider),
      sincronizador: ref.read(sincronizadorProvider),
      estacionId: widget.estacionId,
    );
    _vigia = vigia;

    vigia.pasarela.conectado.listen((c) {
      if (mounted) setState(() => _conectado = c);
    });

    vigia.estado.listen((evento) {
      if (!mounted) return;
      setState(() {
        switch (evento.tipo) {
          case TipoEstadoVigia.muestraCapturada:
            _ultimaTemperatura = evento.lectura!.temperatura;
            _ultimaHumedad = evento.lectura!.humedad;
            _muestrasCapturadas++;
          case TipoEstadoVigia.loteSincronizado:
            _muestrasSincronizadas += evento.cantidad!;
        }
      });
    });

    try {
      await vigia.iniciar(widget.nombreBle);
    } catch (e) {
      setState(() => _mensaje = 'No se pudo conectar por BLE: $e');
    }
  }

  @override
  void dispose() {
    _vigia?.detener();
    _vigia?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estación ${widget.nombreBle}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bluetooth_connected, color: _conectado ? Colors.blue : Colors.grey),
                const SizedBox(width: 8),
                Text(_conectado ? 'Conectado por BLE' : 'Reconectando…'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metrica('Temperatura', _ultimaTemperatura != null ? '${_ultimaTemperatura!.toStringAsFixed(1)}°C' : '--'),
                _metrica('Humedad', _ultimaHumedad != null ? '${_ultimaHumedad!.toStringAsFixed(0)}%' : '--'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Muestras capturadas: $_muestrasCapturadas'),
            Text('Muestras sincronizadas: $_muestrasSincronizadas'),
            if (_muestrasCapturadas > _muestrasSincronizadas)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_muestrasCapturadas - _muestrasSincronizadas} en cola local (RF-05: no se pierden sin red)',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            if (_mensaje != null) ...[
              const SizedBox(height: 16),
              Text(_mensaje!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metrica(String etiqueta, String valor) => Column(
        children: [
          Text(valor, style: Theme.of(context).textTheme.displaySmall),
          Text(etiqueta),
        ],
      );
}
