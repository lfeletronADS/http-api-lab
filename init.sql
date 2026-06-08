-- ============================================================
-- HTTP API Lab — Estrutura do Banco de Dados (SQLite)
-- ============================================================
-- ATENÇÃO: Este arquivo é apenas para REFERÊNCIA educativa.
-- As tabelas são criadas AUTOMATICAMENTE pelo server.js
-- na primeira execução. Não é necessário rodar este SQL.
-- ============================================================

CREATE TABLE IF NOT EXISTS pessoas (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    nome      TEXT,
    idade     INTEGER,
    cpf       TEXT,
    cidade    TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carros (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    marca     TEXT,
    modelo    TEXT,
    ano       INTEGER,
    cor       TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS casas (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    endereco  TEXT,
    bairro    TEXT,
    valor     REAL,
    vagas     INTEGER,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cachorros (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    nome      TEXT,
    raca      TEXT,
    idade     INTEGER,
    dono      TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);
