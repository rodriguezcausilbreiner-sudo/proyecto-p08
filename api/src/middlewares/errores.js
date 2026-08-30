export function manejadorErrores(err, req, res, next) {
  console.error(`[error] ${req.method} ${req.originalUrl} ->`, err.message);

  if (err.name === 'ZodError') {
    return res.status(400).json({
      error: 'Datos de entrada inválidos',
      detalles: err.issues.map((i) => ({ campo: i.path.join('.'), mensaje: i.message })),
    });
  }

  if (err.code === 'P2002') {
    return res.status(409).json({ error: 'Registro duplicado' });
  }
  if (err.code === 'P2025') {
    return res.status(404).json({ error: 'Recurso no encontrado' });
  }

  res.status(err.status || 500).json({ error: err.mensajePublico || 'Error interno del servidor' });
}

export function rutaNoEncontrada(req, res) {
  res.status(404).json({ error: `Ruta no encontrada: ${req.method} ${req.originalUrl}` });
}
