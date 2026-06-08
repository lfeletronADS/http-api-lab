# API Lab CRUD — Laboratorio HTTP Educativo

**Desenvolvido por:** Leandro Ferreira  
**Acesso:** http://api.guardiao.lan  
**Stack:** Node.js + Express + SQLite + Docker  
> 📥 **[Clique aqui para baixar o projeto (ZIP)](https://github.com/lfeletronADS/http-api-lab/raw/main/http-api-lab.zip)**


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
5. **PUT** — abre o modal com os valores atuais pre-preenchidos, edite e confirme
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
├── Dockerfile         # Imagem do container
├── init.sql           # Referencia da estrutura do banco (educativo)
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

## Desafios para voce — proximos niveis

Este projeto foi construido de forma intencional com algumas lacunas. Cada item abaixo e um desafio real que voce pode tentar resolver para evoluir o projeto. Nao existe resposta errada — o objetivo e pensar, pesquisar e tentar.

---

### Desafio 1 — Validacao de entrada e SQL Injection

- [ ] **Adicionar validacao de entrada nas rotas dinamicas**

**O que e validar uma entrada?**
Validar uma entrada significa verificar se o dado que chegou da requisicao e exatamente o que voce esperava antes de usar esse dado em qualquer operacao. Se o campo idade deve ser um numero, voce precisa garantir que o usuario nao mandou a palavra banana no lugar. Se o campo nome nao pode ficar vazio, voce precisa checar isso antes de gravar no banco.

**O que e SQL Injection?**
SQL Injection acontece quando um usuario consegue inserir trechos de codigo SQL dentro de uma requisicao e o servidor executa esse codigo sem perceber, achando que e parte da query normal.

Imagine que alguem preencha o campo nome assim:

    '; DELETE FROM pessoas; DELETE FROM carros; DELETE FROM casas; DELETE FROM cachorros; --

Se o servidor montar a query concatenando esse valor diretamente, o banco receberia e executaria isso em sequencia:

    INSERT INTO pessoas (nome) VALUES ('');
    DELETE FROM pessoas;
    DELETE FROM carros;
    DELETE FROM casas;
    DELETE FROM cachorros;

Resultado: todos os registros de todas as tabelas apagados em uma unica requisicao.

**O que realmente funciona neste projeto?**

Os valores dos campos estao protegidos pelo better-sqlite3 usando prepared statements com ? como placeholder. O perigo real esta em dois outros pontos:

Vulnerabilidade 1: o nome da tabela vem direto da URL sem filtro:

    const { tabela } = req.params;
    db.prepare("SELECT * FROM " + tabela + " ORDER BY id DESC").all();

Qualquer pessoa pode chamar GET /api/sqlite_master e receber a estrutura interna do banco inteiro: nomes de tabelas, colunas e tipos expostos em uma unica requisicao.

Vulnerabilidade 2: os nomes das colunas vem do body sem filtro:

    const colunas = Object.keys(dados).join(", ");
    db.prepare("INSERT INTO " + tabela + " (" + colunas + ") VALUES (?)");

As chaves do JSON viram nomes de colunas direto na query sem nenhuma verificacao.

---

ATIVIDADE PRATICA: Quebre sua propria aplicacao

Esta atividade e intencional. O objetivo e voce sentir o impacto de uma falha de seguranca na propria pele para nunca mais esquecer de validar entradas.

Passo 1: Crie registros na interface
Abra o laboratorio, selecione PESSOA e faca ao menos 5 POSTs com nomes, idades e cidades reais. Confirme com GET que os dados estao la.

Passo 2: Exponha a estrutura do banco
Abra o terminal e execute:

    curl -s http://localhost:3005/api/sqlite_master

Voce acabou de receber a estrutura interna completa do banco de dados, como um atacante faria para mapear o sistema antes de agir.

Passo 3: Apague tudo
Com os IDs em maos (obtidos via GET), execute:

    curl -s -X DELETE http://localhost:3005/api/pessoas/1
    curl -s -X DELETE http://localhost:3005/api/pessoas/2
    curl -s -X DELETE http://localhost:3005/api/pessoas/3

Faca um GET novamente. Os dados foram. Sem senha, sem permissao especial, sem conhecimento avancado. Qualquer pessoa com acesso a URL consegue fazer isso.

Passo 4: Recupere a aplicacao
Como o banco e um arquivo SQLite, a recuperacao e simples:

    docker compose down

    rem Apaga o banco (Windows)
    del lab_postman.db

    # Apaga o banco (Linux/Mac)
    rm lab_postman.db

    docker compose up -d

Abra o laboratorio. Tudo zerado, pronto para comecar de novo. Grave esse sentimento.

**O que voce acabou de aprender:**
Sem validacao, qualquer pessoa com acesso a URL pode apagar dados, expor a estrutura do banco e comprometer a aplicacao inteira sem precisar de nenhuma senha ou ferramenta avancada. Um simples teste unitario que verificasse se a tabela informada esta em uma lista de valores permitidos teria bloqueado todos esses ataques antes mesmo de chegar ao banco.

**O seu desafio de correcao:**
Crie uma lista de tabelas permitidas no server.js:

    const TABELAS_PERMITIDAS = ["pessoas", "carros", "casas", "cachorros"];

No inicio de cada rota, verifique se a tabela solicitada esta nessa lista. Se nao estiver, retorne um erro 400 com a mensagem "Tabela nao permitida". Teste chamando /api/sqlite_master novamente: agora deve retornar erro. Depois escreva um teste automatizado que confirme esse comportamento para garantir que ninguem vai quebrar isso acidentalmente no futuro.

### Desafio 2 — Rota GET por ID

- [ ] **Criar a rota GET /api/:tabela/:id**

**O que falta?**  
Hoje o GET retorna todos os registros da tabela de uma vez. Mas em uma API real, voce precisa buscar um registro especifico pelo seu ID — sem trazer os outros.

**O que isso significa na pratica?**  
Se voce tem 500 pessoas cadastradas e precisa editar apenas a de ID 42, nao faz sentido baixar todas as 500 para encontrar a que voce quer. A rota `/api/pessoas/42` deveria retornar apenas aquele registro.

**O seu desafio:** Adicione uma nova rota no `server.js` que aceite um ID na URL e execute um `SELECT * FROM tabela WHERE id = ?`. Se o registro nao existir, retorne um erro 404 com uma mensagem clara.

---

### Desafio 3 — Paginacao no GET

- [ ] **Implementar paginacao com LIMIT e OFFSET**

**O que e paginacao?**  
Quando uma tabela tem muitos registros, retornar todos de uma vez e ineficiente — imagina carregar 10.000 carros de uma vez na tela. Paginacao e a tecnica de dividir esses resultados em paginas: primeiro voce ve os 10 mais recentes, depois os proximos 10, e assim por diante.

**Como funciona no SQL?**  
O SQL tem dois comandos para isso: `LIMIT` define quantos registros trazer, e `OFFSET` define a partir de qual posicao comecar:

```sql
SELECT * FROM pessoas ORDER BY id DESC LIMIT 10 OFFSET 0;  -- pagina 1
SELECT * FROM pessoas ORDER BY id DESC LIMIT 10 OFFSET 10; -- pagina 2
SELECT * FROM pessoas ORDER BY id DESC LIMIT 10 OFFSET 20; -- pagina 3
```

**O seu desafio:** Modifique a rota GET para aceitar parametros de query na URL, como `/api/pessoas?page=2&limit=10`. Use esses valores para calcular o `OFFSET` correto e retornar apenas os registros daquela pagina. Inclua no JSON de resposta o total de registros para que o frontend saiba quantas paginas existem.

---

### Desafio 4 — Variaveis de ambiente com .env

- [ ] **Mover configuracoes para um arquivo .env**

**O que e um arquivo .env?**
Um arquivo .env e onde ficam as configuracoes que mudam de ambiente para ambiente — como portas, senhas e chaves. O nome vem de environment (ambiente em ingles). Cada linha e um par chave:valor:

    PORT=3000
    DB_PATH=./lab_postman.db

**A diferenca entre porta interna e porta externa no Docker:**

Pense no Docker como uma caixa fechada. Dentro dessa caixa o servidor roda em uma porta — essa e a porta *interna*, conhecida so pelo processo dentro do container. Do lado de fora da caixa, quem quiser acessar precisa bater em outra porta — essa e a porta *externa*, exposta para a rede local ou para a internet.

O docker-compose faz a ponte entre as duas:

    ports:
      - 3005:3000

Isso significa: quem bater na porta 3005 de fora vai ser redirecionado para a porta 3000 de dentro. E como uma fechadura com duas chaves — quem tem so uma das duas nao consegue abrir. O servidor precisa saber que escuta na 3000, e quem acessa precisa saber que bate na 3005.

    Rede local  →  porta 3005 (externa)  →  Docker  →  porta 3000 (interna)  →  server.js

Se voce mudar a porta interna no .env mas esquecer de mudar no docker-compose (ou vice-versa), a conexao quebra — as duas chaves precisam estar sincronizadas.

**Por que isso importa?**
Hoje o valor 3000 esta fixo dentro do server.js. Se amanha voce quiser mudar, precisa editar o codigo. Com o .env, voce muda so a configuracao sem tocar no codigo. Alem disso, arquivos .env nunca devem ir para o GitHub — eles ficam no .gitignore — porque podem conter senhas e chaves secretas.

**O seu desafio:**
Crie um arquivo .env com as variaveis abaixo:

    PORT=3000
    DB_PATH=./lab_postman.db

Instale a biblioteca dotenv (npm install dotenv), importe no inicio do server.js e substitua os valores fixos pelas variaveis de ambiente (process.env.PORT e process.env.DB_PATH). Adicione .env ao .gitignore. Por fim, teste mudar a porta interna para 4000, ajustar o docker-compose para 3006:4000, e confirme que o laboratorio continua abrindo — so que agora nas novas portas.

### Desafio 5 — Autenticacao com JWT

- [ ] **Proteger as rotas com autenticacao por token JWT**

**O que e autenticacao?**  
Hoje qualquer pessoa que souber a URL da sua API pode criar, editar ou deletar registros sem nenhuma restricao. Autenticacao e o mecanismo que garante que so quem tem permissao pode acessar determinadas rotas.

**O que e JWT?**  
JWT significa JSON Web Token. E um token (uma string longa e cifrada) que o servidor gera quando o usuario faz login com usuario e senha. Nas proximas requisicoes, o cliente envia esse token no cabecalho da requisicao — e o servidor valida se o token e autentico antes de executar a operacao.

O fluxo funciona assim:

```
1. Cliente envia: POST /login  { usuario: "admin", senha: "123" }
2. Servidor valida e retorna: { token: "eyJhbGciOiJIUzI1NiIs..." }
3. Cliente armazena o token
4. Nas proximas requisicoes: GET /api/pessoas
   Header: Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
5. Servidor verifica o token antes de responder
```

**O seu desafio:** Instale a biblioteca `jsonwebtoken`, crie uma rota `POST /login` que aceite usuario e senha e retorne um token. Crie um middleware que verifique o token antes de permitir acesso as rotas `/api/*`. Teste usando o campo de cabecalho no Postman ou diretamente pela interface.

---

> Boa sorte! Cada desafio resolvido e um nivel a mais na sua evolucao como desenvolvedor.  
> Compartilhe suas solucoes abrindo um Pull Request neste repositorio.
