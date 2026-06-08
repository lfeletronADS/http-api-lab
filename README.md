# API Lab CRUD — Laboratorio HTTP Educativo

**Desenvolvido por:** Leandro Ferreira  
**Acesso:** http://api.guardiao.lan  
**Stack:** Node.js + Express + SQLite + Docker  

---

## O que e este projeto?

Um laboratorio interativo para aprender na pratica como funcionam os 4 verbos HTTP do padrao REST. A interface visual simula um terminal que exibe respostas JSON em tempo real e registra o historico de chamadas — sem precisar do Postman.

| Verbo | Acao no banco | Para que serve |
|-------|--------------|----------------|
| POST | INSERT | Criar um novo registro |
| GET | SELECT | Consultar registros |
| PUT | UPDATE | Atualizar um registro |
| DELETE | DELETE | Remover um registro |

---

## Por que SQLite?

O projeto usa **SQLite** — um banco de dados embutido, sem necessidade de servidor externo. Isso torna o projeto completamente portavel:

- Aluno clona o repositorio
- Roda `docker compose up`
- Ja funciona — sem instalar banco, sem configurar senha, sem dependencia externa

O banco e um unico arquivo (`lab_postman.db`) criado automaticamente na primeira execucao.

---

## Arquitetura

```
Browser (index.html)
       |
       | fetch() — chamadas HTTP
       v
Node.js + Express — porta 3000 interna / 3005 externa
       |
       | better-sqlite3 (sincrono, sem servidor)
       v
SQLite — arquivo lab_postman.db (na propria pasta do projeto)
```

---

## Endpoints da API

A API usa rotas dinamicas — o nome da tabela e passado diretamente na URL.

### POST — Criar registro
```
POST /api/:tabela
Content-Type: application/json
Body: { "nome": "Joao", "idade": 30 }
Response 201: { "id": 7, "mensagem": "Gravado!" }
```

### GET — Listar registros
```
GET /api/:tabela
Response 200: [ { "id": 7, "nome": "Joao", ... }, ... ]
Retorna todos ordenados do mais recente (ORDER BY id DESC)
```

### PUT — Atualizar registro
```
PUT /api/:tabela/:id
Content-Type: application/json
Body: { "nome": "Joao Silva" }
Response 200: { "mensagem": "Atualizado no banco!" }
Suporta atualizacao parcial — so os campos enviados sao alterados.
```

### DELETE — Remover registro
```
DELETE /api/:tabela/:id
Response 200: { "mensagem": "Registro 7 removido da tabela pessoas!" }
```

---

## Entidades disponiveis

| Entidade | Endpoint | Campos |
|----------|----------|--------|
| Pessoa | /api/pessoas | nome, idade, cpf, cidade |
| Carro | /api/carros | marca, modelo, ano, cor |
| Casa | /api/casas | endereco, bairro, valor, vagas |
| Cachorro | /api/cachorros | nome, raca, idade, dono |

Tabelas criadas automaticamente no primeiro start — nao precisa rodar nenhum SQL manualmente.

---

## Como usar a interface

1. Clique em uma das 4 entidades (Pessoa, Carro, Casa, Cachorro)
2. Preencha os dados no modal
3. **POST** — grava no banco e exibe o ID gerado
4. **GET** — busca o registro mais recente, exibe JSON no terminal
5. **PUT** — abre o modal para alterar campos e atualiza o banco
6. **DELETE** — remove o registro buscado pelo GET

Painel em tempo real:
- Terminal JSON (resposta crua da API)
- Visualizacao em texto (campos formatados)
- Historico de URIs chamadas

---

## Estrutura de arquivos

```
/
├── server.js          # API Node.js/Express com SQLite
├── index.html         # Interface visual interativa
├── docker-compose.yml # Definicao do container
├── package.json       # Dependencias
├── lab_postman.db     # Banco SQLite (criado automaticamente)
└── node_modules/      # Instalado automaticamente no start
```

---

## Executar o projeto

```bash
# Subir
docker compose up -d

# Ver logs
docker logs api_crud_postman -f

# Parar
docker compose down
```

Nao precisa de nenhuma configuracao adicional. O banco e criado automaticamente na primeira execucao.

---

## Decisoes tecnicas

**SQLite em vez de MariaDB/PostgreSQL**  
Banco embutido — sem servidor externo, sem configuracao. Ideal para fins educativos e distribuicao do projeto para alunos testarem em casa.

**better-sqlite3**  
Driver sincrono para SQLite. Mais simples de entender do que drivers async — o codigo de cada rota fica linear e facil de ler.

**Rotas dinamicas**  
`/api/:tabela` serve qualquer entidade com o mesmo codigo. Um unico POST, GET, PUT, DELETE cobre todas as tabelas.

**SQL direto sem ORM**  
Sem Sequelize ou Prisma para nao abstrair o aprendizado. O aluno ve o SQL sendo executado em cada operacao.

**HTML puro**  
Sem React, Vue ou qualquer framework no frontend. Foco total nos verbos HTTP e no ciclo request/response.

---

## Proximos passos sugeridos

- [ ] Adicionar validacao de entrada (prevenir SQL Injection nas rotas dinamicas)
- [ ] Rota GET por ID: /api/:tabela/:id
- [ ] Paginacao no GET (LIMIT/OFFSET)
- [ ] Mover configuracoes para .env
- [ ] Autenticacao com JWT — proximo nivel de aprendizado
