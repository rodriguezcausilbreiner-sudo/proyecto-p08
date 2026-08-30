import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../dominio/entidades/lectura.dart';

/// Igual patrón que P1 (Bitácora sísmica) y P3 (Inventario sin conexión)
/// del banco: primero se guarda local, la red es un detalle que se
/// resuelve después. Ninguna lectura se pierde por falta de señal.
class ColaLocal {
  Database? _db;

  Future<Database> _abrir() async {
    if (_db != null) return _db!;
    final ruta = join(await getDatabasesPath(), 'p8_cola_lecturas.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE lectura_pendiente (
          clave_cliente TEXT PRIMARY KEY,
          temperatura REAL NOT NULL,
          humedad REAL,
          latitud REAL,
          longitud REAL,
          en_movimiento INTEGER NOT NULL,
          medida_en TEXT NOT NULL,
          enviada INTEGER NOT NULL DEFAULT 0
        )
      '''),
    );
    return _db!;
  }

  Future<void> encolar(Lectura l) async {
    final db = await _abrir();
    await db.insert(
      'lectura_pendiente',
      {
        'clave_cliente': l.claveCliente,
        'temperatura': l.temperatura,
        'humedad': l.humedad,
        'latitud': l.latitud,
        'longitud': l.longitud,
        'en_movimiento': l.enMovimiento ? 1 : 0,
        'medida_en': l.medidaEn.toIso8601String(),
        'enviada': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Lectura>> pendientes({int limite = 200}) async {
    final db = await _abrir();
    final filas = await db.query('lectura_pendiente', where: 'enviada = 0', limit: limite, orderBy: 'medida_en ASC');
    return filas
        .map((f) => Lectura(
              claveCliente: f['clave_cliente'] as String,
              temperatura: f['temperatura'] as double,
              humedad: f['humedad'] as double?,
              latitud: f['latitud'] as double?,
              longitud: f['longitud'] as double?,
              enMovimiento: (f['en_movimiento'] as int) == 1,
              medidaEn: DateTime.parse(f['medida_en'] as String),
            ))
        .toList();
  }

  Future<void> marcarEnviadas(List<String> clavesCliente) async {
    if (clavesCliente.isEmpty) return;
    final db = await _abrir();
    final marcadores = List.filled(clavesCliente.length, '?').join(',');
    await db.update(
      'lectura_pendiente',
      {'enviada': 1},
      where: 'clave_cliente IN ($marcadores)',
      whereArgs: clavesCliente,
    );
  }

  Future<int> contarPendientes() async {
    final db = await _abrir();
    final r = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM lectura_pendiente WHERE enviada = 0'));
    return r ?? 0;
  }
}
