import prisma from '../prisma/cliente.js';
import { loteLecturasSchema } from '../servicios/validacion.js';
import { difundirLectura } from '../tiempo-real/telemetria.js';

export async function subirLoteLecturas(req, res, next) {
  try {
    const estacionId = req.params.id;
    const { lecturas } = loteLecturasSchema.parse(req.body);

    const resultados = [];
    for (const l of lecturas) {
      // upsert = idempotencia (mismo patrón que P1): reenviar la cola
      // tras recuperar conexión nunca duplica una lectura ya recibida.
      const lectura = await prisma.lectura.upsert({
        where: { estacionId_claveCliente: { estacionId, claveCliente: l.claveCliente } },
        update: {},
        create: {
          estacionId,
          temperatura: l.temperatura,
          humedad: l.humedad ?? null,
          latitud: l.latitud ?? null,
          longitud: l.longitud ?? null,
          enMovimiento: l.enMovimiento,
          medidaEn: new Date(l.medidaEn),
          claveCliente: l.claveCliente,
        },
      });
      resultados.push(lectura);
      difundirLectura(estacionId, lectura);
    }

    res.status(207).json({ procesadas: resultados.length });
  } catch (err) {
    next(err);
  }
}

export async function obtenerLecturas(req, res, next) {
  try {
    const { desde, hasta } = req.query;
    const lecturas = await prisma.lectura.findMany({
      where: {
        estacionId: req.params.id,
        medidaEn: {
          gte: desde ? new Date(desde) : undefined,
          lte: hasta ? new Date(hasta) : undefined,
        },
      },
      orderBy: { medidaEn: 'asc' },
    });
    res.status(200).json({ lecturas, total: lecturas.length });
  } catch (err) {
    next(err);
  }
}
