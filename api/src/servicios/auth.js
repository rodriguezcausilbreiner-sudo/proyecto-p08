import jwt from 'jsonwebtoken';

const SECRETO = process.env.JWT_SECRET || 'secreto-dev-inseguro';

export function generarJwt(payload) {
  return jwt.sign(payload, SECRETO, { expiresIn: '12h' });
}

export function verificarJwt(token) {
  return jwt.verify(token, SECRETO);
}
