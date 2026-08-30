import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'node:path';
import rutas from './rutas/index.js';
import { manejadorErrores, rutaNoEncontrada } from './middlewares/errores.js';

const app = express();

app.use(helmet({ contentSecurityPolicy: false })); // el panel web sirve su propio HTML/JS estático
app.use(cors());
app.use(morgan('dev'));
app.use(express.json({ limit: '512kb' }));

app.get('/salud', (req, res) => res.json({ estado: 'ok' }));

app.use('/api', rutas);

// Panel web estático (RF-06): ver panel-web/ en la raíz del monorepo.
app.use('/panel', express.static(path.resolve('../panel-web/src')));

app.use(rutaNoEncontrada);
app.use(manejadorErrores);

export default app;
