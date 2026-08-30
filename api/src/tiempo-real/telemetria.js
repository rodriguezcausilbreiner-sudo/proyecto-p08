import { evaluarAlerta } from '../servicios/alertas.js';

let ioGlobal;

export function montarTiempoReal(io) {
  ioGlobal = io;

  io.on('connection', (socket) => {
    // El panel web se suscribe a una estación concreta emitiendo este evento
    // tras conectarse; no hay autenticación de socket en el panel de solo
    // lectura (a diferencia de P7, donde el cliente también escribe).
    socket.on('suscribir', (estacionId) => {
      socket.join(`estacion:${estacionId}`);
    });
  });
}

export function difundirLectura(estacionId, lectura) {
  if (!ioGlobal) return;
  ioGlobal.to(`estacion:${estacionId}`).emit('lectura:nueva', {
    ...lectura,
    alerta: evaluarAlerta(lectura.temperatura),
  });
}
