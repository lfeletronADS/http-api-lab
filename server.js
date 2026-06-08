const express = require('express');
const Database = require('better-sqlite3');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

const db = new Database('./lab_postman.db');

db.exec(`
  CREATE TABLE IF NOT EXISTS pessoas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, idade INTEGER, cpf TEXT, cidade TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
  );
  CREATE TABLE IF NOT EXISTS carros (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    marca TEXT, modelo TEXT, ano INTEGER, cor TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
  );
  CREATE TABLE IF NOT EXISTS casas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endereco TEXT, bairro TEXT, valor REAL, vagas INTEGER,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
  );
  CREATE TABLE IF NOT EXISTS cachorros (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, raca TEXT, idade INTEGER, dono TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
  );
`);

console.log('Banco SQLite pronto — lab_postman.db');

// POST
app.post('/api/:tabela', (req, res) => {
  const { tabela } = req.params;
  const dados = req.body;
  const colunas = Object.keys(dados).join(', ');
  const placeholders = Object.keys(dados).map(() => '?').join(', ');
  try {
    const stmt = db.prepare(`INSERT INTO ${tabela} (${colunas}) VALUES (${placeholders})`);
    const result = stmt.run(...Object.values(dados));
    res.status(201).json({ id: result.lastInsertRowid, mensagem: 'Gravado!' });
  } catch (e) {
    res.status(500).json({ erro: e.message });
  }
});

// GET
app.get('/api/:tabela', (req, res) => {
  const { tabela } = req.params;
  try {
    const rows = db.prepare(`SELECT * FROM ${tabela} ORDER BY id DESC`).all();
    res.json(rows);
  } catch (e) {
    res.status(500).json({ erro: e.message });
  }
});

// PUT
app.put('/api/:tabela/:id', (req, res) => {
  const { tabela, id } = req.params;
  const dados = req.body;
  const sets = Object.keys(dados).map(k => `${k} = ?`).join(', ');
  try {
    const stmt = db.prepare(`UPDATE ${tabela} SET ${sets} WHERE id = ?`);
    stmt.run(...Object.values(dados), id);
    res.json({ mensagem: 'Atualizado no banco!' });
  } catch (e) {
    res.status(500).json({ erro: e.message });
  }
});

// DELETE
app.delete('/api/:tabela/:id', (req, res) => {
  const { tabela, id } = req.params;
  try {
    db.prepare(`DELETE FROM ${tabela} WHERE id = ?`).run(id);
    res.json({ mensagem: `Registro ${id} removido da tabela ${tabela}!` });
  } catch (e) {
    res.status(500).json({ erro: e.message });
  }
});

app.listen(3000, '0.0.0.0', () => console.log('API Lab ON — porta 3000'));
