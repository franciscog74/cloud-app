require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const { CognitoJwtVerifier } = require("aws-jwt-verify");
const cors = require('cors');
const helmet = require('helmet');
<<<<<<< HEAD
const fs = require('fs');
=======
const fs = require('node:fs');
>>>>>>> 3813db410621230e389cbdff76620ade41c6f78d

const app = express();

app.use(helmet()); 
app.use(express.json({ limit: '10kb' })); 

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

const verifier = CognitoJwtVerifier.create({
  userPoolId: process.env.AWS_COGNITO_USER_POOL_ID || "us-east-1_VweJB0bqs",
  tokenUse: "id",
  clientId: process.env.AWS_COGNITO_CLIENT_ID || "4tre8tk0co9c1lgslqiaes347v",
});

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'ENDPOINT_DE_RDS.amazonaws.com',
  user: process.env.DB_USER || 'admin',
  password: process.env.DB_PASS || 'password_rds',
  database: process.env.DB_NAME || 'gastos_db',
<<<<<<< HEAD
  ssl: {
    ca: fs.readFileSync(__dirname + '/global-bundle.pem')
=======
  ssl  : {
    ca : fs.readFileSync(__dirname + '/global-bundle.pem')
>>>>>>> 3813db410621230e389cbdff76620ade41c6f78d
  },
  waitForConnections: true,
  connectionLimit: process.env.DB_CONN_LIMIT ? parseInt(process.env.DB_CONN_LIMIT) : 10,
  queueLimit: 0,
  timezone: '-06:00',
  supportBigNumbers: true, 
  bigNumberStrings: true
});

async function verificarToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: "Formato de token inválido o ausente" });
    }
    
    const token = authHeader.split(" ")[1];
    const payload = await verifier.verify(token);
    
    req.idUsuarioValidado = payload.sub; 
    next();
  } catch (error) {
    console.error('Error de Auth Cognito:', error.message);
    return res.status(401).json({ error: "Sesión expirada o token inválido" }); 
  }
}

app.get('/api/categorias', verificarToken, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT id, nombre, color FROM categorias WHERE id_usuario = ? ORDER BY nombre ASC',
      [req.idUsuarioValidado],
      function (error, _, _) {
        if (error)
          console.log(error.code)
      }
    );
    res.status(200).json(rows);
  } catch (error) {
    console.error('Error GET categorias:', error);
    res.status(500).json({ error: "Error interno del servidor al obtener categorías" });
  }
});

app.post('/api/categorias', verificarToken, async (req, res) => {
  try {
    const { nombre, colorHex } = req.body; 
    
    if (!nombre || typeof nombre !== 'string' || nombre.trim().length === 0) {
        return res.status(400).json({ error: "El nombre de la categoría es obligatorio e inválido" });
    }
    if (!colorHex || !/^[0-9A-Fa-f]{6}$/.test(colorHex)) {
        return res.status(400).json({ error: "El colorHex debe ser un código hexadecimal de 6 caracteres válido" });
    }

    await pool.query(
      'INSERT INTO categorias (nombre, id_usuario, color) VALUES (?, ?, ?)',
      [nombre.trim(), req.idUsuarioValidado, colorHex],
      function (error, _, _) {
        if (error)
          console.log(error.code)
      }
    );
    res.status(201).json({ message: "Categoría creada exitosamente" });
  } catch (error) {
    console.error('Error POST categorias:', error);
    res.status(500).json({ error: "Error interno del servidor al crear categoría" });
  }
});

app.put('/api/categorias/:id', verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, colorHex } = req.body;

    if (!id || isNaN(parseInt(id))) return res.status(400).json({ error: "ID de categoría inválido" });
    if (!nombre || nombre.trim().length === 0) return res.status(400).json({ error: "El nombre es obligatorio" });

    const [result] = await pool.query(
      'UPDATE categorias SET nombre = ?, color = ? WHERE id = ? AND id_usuario = ?',
      [nombre.trim(), colorHex, parseInt(id), req.idUsuarioValidado]
    );

    if (result.affectedRows === 0) {
        return res.status(404).json({ error: "Categoría no encontrada o no tienes permiso para editarla" });
    }
    res.status(200).json({ message: "Categoría actualizada exitosamente" });
  } catch (error) {
    console.error('Error PUT categorias:', error);
    res.status(500).json({ error: "Error interno del servidor al actualizar categoría" });
  }
});

app.delete('/api/categorias/:id', verificarToken, async (req, res) => {
  const connection = await pool.getConnection(); 
  try {
    const { id } = req.params;
    if (!id || isNaN(parseInt(id))) return res.status(400).json({ error: "ID inválido" });

    await connection.beginTransaction();

    const [gastos] = await connection.query(
        'SELECT id FROM historial WHERE categoria_id = ? AND id_usuario = ? LIMIT 1',
        [parseInt(id), req.idUsuarioValidado]
    );

    if (gastos.length > 0) {
        await connection.rollback();
        return res.status(409).json({ error: "No puedes eliminar esta categoría porque tiene transacciones asociadas. Elimina los gastos primero." });
    }

    const [result] = await connection.query(
      'DELETE FROM categorias WHERE id = ? AND id_usuario = ?', 
      [parseInt(id), req.idUsuarioValidado]
    );
    
    if (result.affectedRows === 0) {
      await connection.rollback();
      return res.status(404).json({ error: "Categoría no encontrada" });
    }

    await connection.commit();
    res.status(200).json({ message: "Categoría eliminada exitosamente" });
  } catch (error) {
    await connection.rollback();
    console.error('Error DELETE categorias:', error);
    res.status(500).json({ error: "Error interno del servidor al eliminar categoría" });
  } finally {
    connection.release();
  }
});

app.post('/api/gastos', verificarToken, async (req, res) => {
  try {
    const { monto, categoria_id, tipo } = req.body; 

    if (!monto || isNaN(parseFloat(monto)) || parseFloat(monto) <= 0) {
        return res.status(400).json({ error: "Monto inválido. Debe ser un número mayor a 0." });
    }
    if (!categoria_id || isNaN(parseInt(categoria_id))) {
        return res.status(400).json({ error: "ID de categoría inválido." });
    }
    const tipoSeguro = (tipo === 'ingreso') ? 'ingreso' : 'gasto';

    await pool.query(
      `INSERT INTO historial (id_usuario, fecha_registro, categoria, monto, tipo) 
       VALUES (?, NOW(), ?, ?, ?)`,
      [req.idUsuarioValidado, parseInt(categoria_id), parseFloat(monto), tipoSeguro]
    );

    res.status(201).json({ message: "Transacción registrada exitosamente" });
  } catch (error) {
    console.error('Error POST gastos:', error);
    if (error.code === 'ER_NO_REFERENCED_ROW_2') {
        return res.status(400).json({ error: "La categoría seleccionada no existe o es inválida." });
    }
    res.status(500).json({ error: "Error interno del servidor al guardar transacción" });
  }
});

app.get('/api/gastos', verificarToken, async (req, res) => {
  try {
    let limite = parseInt(req.query.limite) || 100;
    limite = Math.min(limite, 500);

    const [rows] = await pool.query(
      `SELECT h.id, h.fecha_registro, h.monto, h.tipo, 
              c.nombre AS categoria_nombre, c.color AS categoria_colorHex
       FROM historial h
       JOIN categorias c ON h.categoria = c.id
       WHERE h.id_usuario = ?
       ORDER BY h.fecha_registro DESC
       LIMIT ?`,
      [req.idUsuarioValidado, limite]
    );
    res.status(200).json(rows);
  } catch (error) {
    console.error('Error GET gastos:', error);
    res.status(500).json({ error: "Error interno del servidor al consultar el historial" });
  }
});

app.delete('/api/gastos/:id', verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    if (!id || isNaN(parseInt(id))) return res.status(400).json({ error: "ID de transacción inválido" });

    const [result] = await pool.query(
      'DELETE FROM historial WHERE id = ? AND id_usuario = ?',
      [parseInt(id), req.idUsuarioValidado]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Transacción no encontrada o no tienes permiso para eliminarla" });
    }

    res.status(200).json({ message: "Transacción eliminada correctamente" });
  } catch (error) {
    console.error('Error DELETE gastos:', error);
    res.status(500).json({ error: "Error interno del servidor al eliminar la transacción" });
  }
});

app.use((req, res, next) => {
    res.status(404).json({ error: "Ruta de API no encontrada" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend seguro inicializado en el puerto ${PORT}`);
});