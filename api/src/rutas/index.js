import { Router } from 'express';
import { crearEstacion, obtenerEstacion, buscarPorNombreBle } from '../controladores/estaciones.js';
import { subirLoteLecturas, obtenerLecturas } from '../controladores/lecturas.js';

const router = Router();

router.post('/estaciones', crearEstacion);
router.get('/estaciones/:id', obtenerEstacion);
router.get('/estaciones/ble/:nombreBle', buscarPorNombreBle);
router.post('/estaciones/:id/lecturas/lote', subirLoteLecturas);
router.get('/estaciones/:id/lecturas', obtenerLecturas);

export default router;
