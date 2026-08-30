import 'dotenv/config';
import { createServer } from 'node:http';
import { Server } from 'socket.io';
import app from './app.js';
import { montarTiempoReal } from './tiempo-real/telemetria.js';

const PUERTO = process.env.PORT || 3000;

const servidorHttp = createServer(app);
const io = new Server(servidorHttp, { cors: { origin: '*' } });
montarTiempoReal(io);

servidorHttp.listen(PUERTO, () => {
  console.log(`API P8 · Estación de campo escuchando en http://localhost:${PUERTO}`);
  console.log(`Panel web en http://localhost:${PUERTO}/panel`);
});
