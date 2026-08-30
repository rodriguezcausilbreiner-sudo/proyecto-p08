const UMBRAL_TEMPERATURA_ALERTA = Number(process.env.UMBRAL_TEMPERATURA_ALERTA ?? 35);

/// RF-06: el panel web alerta al superarse un umbral. La regla vive aquí
/// (lógica pura, sin Express ni Socket.IO) para poder probarla con
/// `node --test` y para reutilizarla tanto al difundir por WebSocket
/// como al calcular alertas históricas sobre datos ya guardados.
export function evaluarAlerta(temperatura) {
  return temperatura >= UMBRAL_TEMPERATURA_ALERTA;
}

export { UMBRAL_TEMPERATURA_ALERTA };
