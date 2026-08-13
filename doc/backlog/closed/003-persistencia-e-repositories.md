# 003 — Persistência e repositories

## Objetivo

Reorganizar o acesso local a dados para que repositories escondam SQLite e
sejam consumidos por contratos injetáveis, preservando o banco existente.

As tarefas de implementação estão organizadas em
[`003-persistencia-e-repositories-tasks.md`](003-persistencia-e-repositories-tasks.md).

## Dependências

- backlog 001 concluído;
- `002-dominio-puro.md`.

## Organização entregue

```text
ViewModel/UseCase
  -> Repository
    -> Data Service
      -> Database
```

- `lib/data/services/database` concentra ciclo de vida, schema, versão e
  backup, além da fábrica de infraestrutura usada pelo composition root;
- `lib/data/services/{settings,users,trainings,histories}` concentra CRUD e
  conversão de registros SQLite;
- `lib/data/repositories` contém os contratos orientados ao domínio e as
  implementações que mantêm os caches;
- `lib/manager` contém somente adapters temporários para as telas legadas, sem
  listas próprias;
- `lib/core/config/dependencies.dart` registra toda a cadeia no
  `AutoInjector`; `main.dart` apenas resolve as dependências de entrada e as
  entrega às rotas da navegação 1.0;
- `Stores`, repositories antigos, `DatabaseManager` e `SettingsManager` foram
  removidos.

Os acessos legados a `AppSettings.instance` permanecem até o backlog 004. Os
managers temporários serão eliminados nos backlogs 005 e 006, quando suas telas
forem convertidas integralmente para Viewmodels.

## Escopo

- mover abertura, configuração e ciclo de vida do banco para serviço de dados;
- transformar stores em services de dados injetáveis;
- definir repositories orientados ao domínio para settings, users, trainings e
  histories;
- converter registros SQLite somente dentro de `data`;
- devolver falhas esperadas como `Result`/`AppError`;
- revisar a responsabilidade atual dos managers e realocar cache conforme o
  tipo de estado;
- encapsular schema, migrations, transações e backup;
- preservar nomes de tabelas, colunas e chaves do schema atual;
- criar adapters temporários para features ainda não migradas.

## Fora de escopo

- redesenhar o schema sem necessidade funcional;
- apagar ou recriar automaticamente o banco do usuário;
- migrar UI;
- manter cache visual em repositories.

## Questões em aberto

Nenhuma questão permanece aberta nesta etapa.

## Critérios de aceite

- UI, ViewModels e domínio não conhecem `sqflite` ou maps de persistência;
- services recebem a dependência de banco, conhecem SQL e fazem o CRUD;
- services convertem registros SQLite e entregam models aos repositories;
- repositories recebem services pelo construtor;
- operações retornam domínio ou `Result`, não exceções cruas;
- foreign keys e backup continuam funcionais;
- um banco da versão atual abre normalmente;
- antes de substituir um banco incompatível, a aplicação preserva uma cópia;
- testes são criados para as operações efetivamente reorganizadas;
- análise termina sem novos erros.

## Decisões

### 2026-08-13 — Schema atual preservado

**Decisão:** a migração arquitetural preservará o schema atual, mas não terá o
objetivo de recuperar todas as versões históricas do banco.

**Motivo:** a aplicação não possui usuários no momento. O custo e a
complexidade de sustentar migrations antigas não se justificam nesta etapa.

**Consequências:** mudanças futuras de schema usam migrations nativas do
`sqflite`. Um banco incompatível pode ser substituído após a criação de backup.

### 2026-08-13 — Dependências explícitas desde o injector

**Decisão:** o serviço responsável pelo ciclo de vida do banco será registrado
como singleton no `AutoInjector`. Services, repositories e adapters
receberão suas dependências exclusivamente pelo construtor.

**Motivo:** o singleton continua adequado para representar uma única conexão
local, mas sua criação e seu compartilhamento pertencem ao composition root. A
dependência não deve surgir no meio da implementação por acesso a
`DatabaseManager.instance`, criação interna de Store ou outro service locator.

**Consequências:**

- remover o singleton implementado manualmente por `DatabaseManager`;
- registrar uma única instância do serviço de banco no `AutoInjector`;
- data services recebem o serviço de banco pelo construtor;
- repositories recebem seus data services pelo construtor;
- managers e adapters temporários também recebem repositories pelo construtor;
- services não instanciam `DatabaseManager`, outros services ou repositories;
- nenhuma classe acessa o injector fora do composition root;
- `sqflite.Database` permanece como detalhe interno da camada `data`, sem
  atravessar contratos de repository, domínio, Viewmodels ou UI.

### 2026-08-13 — CRUD nos data services

**Decisão:** o CRUD será implementado em `data/services`. Esses services
conhecem SQLite, SQL, tabelas, colunas e maps de persistência, e entregam models
aos repositories.

**Motivo:** essa é a separação adotada nos projetos MVVM atuais: o service
encapsula a fonte de dados e suas conversões, enquanto o repository coordena o
acesso aos dados e mantém o cache consumido pela aplicação.

**Consequências:**

- não será criada uma camada adicional chamada DAO;
- os Stores atuais serão substituídos por services em `lib/data/services`;
- conversões `Map<String, Object?>` para model e model para map ficam nos data
  services ou em mappers/DTOs privados dessa camada;
- repositories não conhecem SQL, nomes de tabelas, colunas ou `Database`;
- repositories recebem models dos services e atualizam seus caches;
- services não mantêm estado de apresentação nem o cache compartilhado da
  aplicação;
- contratos de repository continuam orientados ao domínio e retornam `Result`;
- adapters temporários convertem para models legados somente nas fronteiras que
  ainda não foram migradas.

### 2026-08-13 — Cache de dados nos repositories

**Decisão:** os caches de usuários, treinos e históricos serão mantidos pelos
repositories, seguindo o padrão MVVM adotado nos projetos atuais.

**Motivo:** os repositories são a fonte de verdade dos dados da aplicação e
coordenam persistência e memória. Viewmodels consomem esse estado e mantêm
somente estado de apresentação e de interação da tela.

**Consequências:**

- `UserRepository` mantém o cache de usuários;
- `TrainingRepository` mantém caches de treinos organizados pelo usuário;
- `HistoryRepository` mantém caches de históricos organizados pelo treino;
- leitura do banco popula ou atualiza o cache correspondente;
- inserção, alteração e exclusão atualizam o cache somente após persistência
  bem-sucedida;
- repositories não armazenam seleção atual, loading, mensagens, filtros
  visuais, controllers ou qualquer outro estado de UI;
- Viewmodels não duplicam as listas como uma segunda fonte de verdade;
- managers atuais tornam-se adapters temporários sobre os repositories
  injetados e deixam de possuir caches próprios;
- a exclusão de histórico que transfere duração para o próximo registro será
  executada atomicamente antes da atualização do cache.

### 2026-08-13 — Versão única integrada ao sqflite

**Decisão:** a sequência lógica atual, cujo valor vigente é `1006`, passará a
ser a versão nativa entregue ao `openDatabase` do `sqflite`. O controle paralelo
por `dbVersion = 1` e `SettingsModel.dbSchemeVersion` será removido.

**Motivo:** a aplicação ainda não possui uma base de usuários que exija manter
o mecanismo histórico. Um backup é suficiente como proteção para os bancos
locais de desenvolvimento.

**Consequências:**

- a versão atual do banco passa a ser uma única constante com valor `1006`;
- bancos novos são criados diretamente no schema atual e recebem
  `PRAGMA user_version = 1006` pelo próprio `sqflite`;
- migrations futuras usam apenas `onUpgrade`, seguindo a sequência `1007`,
  `1008` e assim por diante;
- `dbSchemeVersion` deixa de fazer parte dos models de settings e do controle
  de fluxo da aplicação;
- a coluna legada pode permanecer sem uso nos bancos existentes; bancos novos
  não precisam criá-la;
- antes de tentar atualizar ou substituir um banco de versão anterior, a
  aplicação cria uma cópia de backup com identificação suficiente para
  recuperação manual;
- não haverá migration de ponte para reproduzir a sequência histórica
  `1001–1006`;
- se a abertura ou atualização do banco legado falhar, a aplicação fecha o
  arquivo, preserva o backup e cria um banco novo no schema atual;
- não será usado `exit(1)`; falha no backup ou na criação do banco novo retorna
  `AppError` e interrompe o bootstrap de forma controlada;
- testes cobrem criação do schema atual, criação do backup e o fallback para um
  banco novo a partir de um banco legado incompatível.

## Acompanhamento

**Estado:** Tasks 1 a 11 concluídas. Validações automatizadas da task 12
concluídas; abertura e leitura inicial no aplicativo foram adiadas pelo
responsável pelo projeto em 2026-08-13. O backlog permanece aberto até essa
validação manual.

**Próximo backlog:** `004-configuracoes-mvvm.md`.
