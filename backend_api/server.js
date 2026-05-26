require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const { CognitoJwtVerifier } = require("aws-jwt-verify");
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// 1. Configurar Cognito
const verifier = CognitoJwtVerifier.create({
  userPoolId: process.env.AWS_COGNITO_USER_POOL_ID,
  tokenUse: "id",
  clientId: process.env.AWS_COGNITO_CLIENT_ID,
});

// 2. Pool de conexión a RDS
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Middleware de verificación
async function verificarToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ error: "No enviaste token" });
    
    const token = authHeader.split(" ")[1];
    const payload = await verifier.verify(token);
    
    req.idUsuarioValidado = payload.sub; 
    next();
  } catch (error) {
    return res.status(403).json({ error: "Token inválido" });
  }
}

// ==========================================
//   RUTAS DE CATEGORÍAS

app.get('/api/categorias', verificarToken, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT id, nombre, color FROM categorias WHERE id_usuario = ?',
      [req.idUsuarioValidado]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: "Error al obtener categorías" });
  }
});

app.post('/api/categorias', verificarToken, async (req, res) => {
  try {
    const { nombre, color } = req.body;
    await pool.execute(
      'INSERT INTO categorias (nombre, id_usuario, color) VALUES (?, ?, ?)',
      [nombre, req.idUsuarioValidado, color]
    );
    res.status(201).json({ message: "Categoría creada" });
  } catch (error) {
    res.status(500).json({ error: "Error al crear categoría" });
  }
});

app.put('/api/categorias/:id', verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, color } = req.body;
    await pool.execute(
      'UPDATE categorias SET nombre = ?, color = ? WHERE id = ? AND id_usuario = ?',
      [nombre, color, id, req.idUsuarioValidado]
    );
    res.json({ message: "Categoría actualizada" });
  } catch (error) {
    res.status(500).json({ error: "Error al actualizar categoría" });
  }
});

app.delete('/api/categorias/:id', verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    await pool.execute(
      'DELETE FROM categorias WHERE id = ? AND id_usuario = ?', 
      [id, req.idUsuarioValidado]
    );
    res.json({ message: "Categoría eliminada" });
  } catch (error) {
    res.status(500).json({ error: "Error al eliminar categoría (puede tener gastos asociados)" });
  }
});

// ==========================================
//   RUTAS DE GASTOS / HISTORIAL

app.get('/api/gastos', verificarToken, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT h.id, h.fecha_registro, h.monto, h.tipo, 
              c.nombre AS categoria_nombre, c.color AS categoria_color
       FROM historial h
       JOIN categorias c ON h.categoria = c.id
       WHERE h.id_usuario = ?
       ORDER BY h.fecha_registro DESC`,
      [req.idUsuarioValidado]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: "Error al consultar historial" });
  }
});

app.post('/api/gastos', verificarToken, async (req, res) => {
  try {
    const { monto, idCategoria, tipo } = req.body; 
    const fechaActual = new Date().toISOString().slice(0, 19).replace('T', ' ');
    await pool.execute(
      `INSERT INTO historial (id_usuario, fecha_registro, categoria, monto, tipo) 
       VALUES (?, ?, ?, ?, ?)`,
      [req.idUsuarioValidado, fechaActual, idCategoria, monto, tipo || 'gasto']
    );
    res.status(201).json({ message: "Registro exitoso" });
  } catch (error) {
    res.status(500).json({ error: "Error al guardar registro" });
  }
});

app.delete('/api/gastos/:id', verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.execute(
      'DELETE FROM historial WHERE id = ? AND id_usuario = ?',
      [id, req.idUsuarioValidado]
    );
    if (result.affectedRows === 0) return res.status(404).json({ error: "No encontrado" });
    res.json({ message: "Eliminado correctamente" });
  } catch (error) {
    res.status(500).json({ error: "Error al eliminar registro" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor completo corriendo en puerto ${PORT}`);
});