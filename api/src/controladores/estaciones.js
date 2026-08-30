import prisma from '../prisma/cliente.js';
import { crearEstacionSchema } from '../servicios/validacion.js';

export async function crearEstacion(req, res, next) {
  try {
    const datos = crearEstacionSchema.parse(req.body);
    const estacion = await prisma.estacion.upsert({
      where: { nombreBle: datos.nombreBle },
      update: {},
      create: datos,
    });
    res.status(201).json(estacion);
  } catch (err) {
    next(err);
  }
}

export async function obtenerEstacion(req, res, next) {
  try {
    const estacion = await prisma.estacion.findUniqueOrThrow({ where: { id: req.params.id } });
    res.status(200).json(estacion);
  } catch (err) {
    next(err);
  }
}

/// Identificación por NFC (RF-01): la etiqueta guarda el mismo
/// nombreBle que anuncia el ESP32 por Bluetooth, así el celular puede
/// resolver primero la estación por NFC y luego buscarla por BLE con
/// ese identificador exacto.
export async function buscarPorNombreBle(req, res, next) {
  try {
    const estacion = await prisma.estacion.findUnique({ where: { nombreBle: req.params.nombreBle } });
    if (!estacion) return res.status(404).json({ error: 'Estación no registrada' });
    res.status(200).json(estacion);
  } catch (err) {
    next(err);
  }
}
