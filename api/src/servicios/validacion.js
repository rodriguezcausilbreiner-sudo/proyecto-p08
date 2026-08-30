import { z } from 'zod';

export const crearEstacionSchema = z.object({
  nombreBle: z.string().min(1),
  ubicacion: z.string().optional(),
});

const lecturaSchema = z.object({
  temperatura: z.number().min(-40).max(85), // rango típico de un DHT22
  humedad: z.number().min(0).max(100).nullable().optional(),
  latitud: z.number().min(-90).max(90).nullable().optional(),
  longitud: z.number().min(-180).max(180).nullable().optional(),
  enMovimiento: z.boolean().default(false),
  medidaEn: z.string().datetime({ offset: true }),
  claveCliente: z.string().uuid('claveCliente debe ser un UUID (idempotencia)'),
});

export const loteLecturasSchema = z.object({
  lecturas: z.array(lecturaSchema).min(1).max(200),
});
