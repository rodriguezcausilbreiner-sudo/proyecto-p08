import 'dart:async';
import 'dart:convert';
import 'package:nfc_manager/nfc_manager.dart';
import '../../core/errores/excepciones.dart';

class LectorNfc {
  Future<String?> leerIdentificadorEstacion() async {
    if (!await NfcManager.instance.isAvailable()) {
      throw const NfcNoDisponible();
    }

    final completador = Completer<String?>();

    await NfcManager.instance.startSession(
      onDiscovered: (etiqueta) async {
        final ndef = Ndef.from(etiqueta);
        final registro = ndef?.cachedMessage?.records.firstOrNull;
        // El payload NDEF de texto trae 3 bytes de cabecera (código de
        // idioma) antes del texto real.
        final texto = registro == null ? null : utf8.decode(registro.payload.sublist(3));
        await NfcManager.instance.stopSession();
        if (!completador.isCompleted) completador.complete(texto);
      },
      onError: (error) async {
        if (!completador.isCompleted) completador.complete(null);
      },
    );

    return completador.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () async {
        await NfcManager.instance.stopSession();
        return null;
      },
    );
  }
}
