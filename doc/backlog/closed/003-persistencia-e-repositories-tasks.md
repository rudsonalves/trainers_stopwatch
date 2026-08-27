# 003 — Tarefas para persistência e repositories

## Objetivo

Organizar a implementação das decisões registradas em
[`003-persistencia-e-repositories.md`](003-persistencia-e-repositories.md),
substituindo dependências ocultas e Stores legados por data services
injetáveis e repositories com cache.

## Decisões já tomadas

- todas as dependências entram pelo construtor;
- o `AutoInjector` é o único composition root;
- nenhuma classe busca dependências diretamente no injector;
- o serviço de banco é singleton por registro no injector, não por implementação
  manual;
- `data/services` conhece SQLite, executa CRUD e converte registros em models;
- não será criada uma camada DAO adicional;
- repositories recebem services e mantêm o cache dos dados;
- Viewmodels não duplicam o cache dos repositories;
- a versão nativa do banco passa a usar a sequência atual, iniciando em `1006`;
- migrations históricas não serão sustentadas;
- um banco incompatível será preservado em backup antes da criação de um banco
  novo;
- Navigator, BLoC, páginas e fluxo visual não serão migrados nesta etapa.

## Ordem de execução

### 1. Preparar a estrutura da camada data

**Dependência:** backlog 002 concluído.

- [x] Criar `lib/data/services` organizado por banco, settings, users,
      trainings e histories conforme os serviços forem implementados.
- [x] Criar `lib/data/repositories` organizado pelos mesmos contextos.
- [x] Manter contratos e implementações de repository separados somente onde a
      injeção ou substituição justificar a separação.
- [x] Documentar a direção `Viewmodel/UseCase -> Repository -> Data Service ->
      Database`.
- [x] Documentar e aplicar às novas implementações a restrição de `sqflite`,
      SQL, tabelas, colunas e maps a `data`; as exceções legadas serão removidas
      nas tasks 4 a 11.
- [x] Definir convenção de construtores com parâmetros nomeados e obrigatórios.
- [x] Não criar agregadores, abstrações de banco ou UseCases sem consumidor
      concreto.

**Resultado esperado:** existe uma fronteira mínima de `data`, pronta para
receber as implementações sem dependências implícitas.

### 2. Implementar o serviço de ciclo de vida do banco

**Dependência:** tarefa 1.

- [x] Mover abertura, configuração e fechamento para um data service de banco.
- [x] Isolar `DatabaseManager` como legado temporário; seu singleton manual será
      removido ao adaptar os consumidores nas tasks 9 e 10.
- [x] Permitir que uma única instância do novo serviço seja criada pelo
      injector.
- [x] Manter a nova conexão encapsulada; novos consumidores não recebem
      `sqflite.Database` fora de `data/services`.
- [x] Ativar foreign keys em toda abertura da conexão.
- [x] Encapsular criação de tabelas e índices no serviço de schema.
- [x] Converter falhas esperadas de abertura, criação e fechamento em
      `Result`/`AppError`.
- [x] Garantir que chamadas repetidas de abertura reutilizem a mesma conexão.
- [x] Testar somente ciclo de vida, configuração e falhas alteradas nesta
      tarefa.

**Resultado esperado:** o banco possui um único ciclo de vida explícito e
injetável, sem acesso global escondido.

### 3. Unificar versão, backup e fallback do banco

**Dependência:** tarefa 2.

- [x] Substituir `dbVersion = 1` e o controle por
      `SettingsModel.dbSchemeVersion` por uma única versão nativa `1006`.
- [x] Fazer bancos novos nascerem diretamente no schema atual.
- [x] Remover a versão do banco dos models de settings e adapters de domínio.
- [x] Manter a coluna legada ignorada ao abrir bancos existentes, sem
      reconstrução apenas para removê-la.
- [x] Criar backup antes de tentar abrir/substituir banco de versão anterior.
- [x] Dar ao backup nome ou metadado suficiente para recuperação manual.
- [x] Se um banco legado não puder ser aberto/atualizado, fechar o arquivo
      original e criar um banco novo no schema atual.
- [x] Nunca apagar nem sobrescrever o backup durante o fallback.
- [x] Retornar `backupFailed`, `migrationFailed` ou erro de armazenamento
      adequado quando não for possível obter um banco utilizável.
- [x] Não chamar `exit(1)` nem recriar silenciosamente o banco sem backup.
- [x] Testar criação atual, backup e fallback a partir de um banco incompatível
      mínimo.

**Resultado esperado:** existe uma única versão de schema e um caminho simples,
recuperável e testado para bancos locais incompatíveis.

### 4. Migrar o CRUD de settings para data service

**Dependências:** tarefas 1 a 3.

- [x] Implementar `SettingsService` em `data/services` como substituto de
      `SettingsStore`; o arquivo legado será removido após adaptar seus
      consumidores na task 10.
- [x] Receber o serviço de banco pelo construtor.
- [x] Mover SQL, nomes de colunas e conversões de map para o service ou mapper
      privado de `data`.
- [x] Entregar o model de settings esperado pelo futuro repository.
- [x] Preservar os defaults atuais, exceto o controle removido de versão do
      banco.
- [x] Representar settings ausentes de forma explícita para permitir a criação
      do registro inicial no repository.
- [x] Converter falhas de leitura e escrita em `Result`/`AppError`.
- [x] Testar leitura, criação inicial e atualização efetivamente migradas.

**Resultado esperado:** settings deixam de depender de Store e maps fora da
camada data.

### 5. Migrar o CRUD de users para data service

**Dependências:** tarefas 1 e 2.

- [x] Implementar `UserService` em `data/services` como substituto de
      `UserStore`; o Store legado será removido após adaptar seus consumidores.
- [x] Receber o serviço de banco pelo construtor.
- [x] Implementar inserção, consulta por ID, listagem, alteração e exclusão.
- [x] Converter registros SQLite em models antes de devolvê-los.
- [x] Manter consulta de imagens dentro da fronteira adequada de dados.
- [x] Definir `storageNotFound` para consulta individual sem registro, sem
      retornar exceção crua.
- [x] Preservar constraints, índices e comportamento de exclusão atuais.
- [x] Testar as operações migradas e seus erros relevantes.

**Resultado esperado:** o CRUD de usuários é um serviço injetável e não expõe
maps ou SQLite.

### 6. Migrar o CRUD de trainings para data service

**Dependências:** tarefas 1 e 2.

- [x] Implementar `TrainingService` em `data/services` como substituto de
      `TrainingStore`; o Store legado será removido após adaptar consumidores.
- [x] Receber o serviço de banco pelo construtor.
- [x] Implementar inserção, consulta por ID, listagem por usuário, alteração e
      exclusão.
- [x] Reutilizar os tipos e parsers do backlog 002 para converter unidades
      persistidas em tipos de domínio.
- [x] Manter cor fora do registro persistido e do model de domínio.
- [x] Preservar IDs, datas, comentários, distâncias, limite e unidades.
- [x] Converter unidade desconhecida em `Failure` com `invalidData`.
- [x] Testar conversão e CRUD efetivamente migrados.

**Resultado esperado:** treinos são carregados como models tipados e strings de
persistência ficam dentro de `data`.

### 7. Migrar o CRUD e as transações de histories

**Dependências:** tarefas 1, 2 e 6.

- [x] Implementar `HistoryService` em `data/services` como substituto de
      `HistoryStore`; o Store legado será removido após adaptar consumidores.
- [x] Receber o serviço de banco pelo construtor.
- [x] Implementar inserção, consulta por ID, listagem por treino, alteração e
      exclusão.
- [x] Preservar a ordem necessária para geração de parciais e voltas.
- [x] Implementar em transação a exclusão que transfere a duração removida para
      o próximo registro.
- [x] Impedir a exclusão inválida do registro inicial dentro dessa operação.
- [x] Fazer rollback integral se exclusão ou atualização do próximo registro
      falhar.
- [x] Usar erros próprios de history no novo service, sem a referência incorreta
      a `TrainingStore` existente no legado.
- [x] Testar transação bem-sucedida, ausência de próximo registro, tentativa de
      excluir o início e rollback.

**Resultado esperado:** o histórico possui CRUD explícito e sua alteração
encadeada é atômica.

### 8. Implementar repositories com cache

**Dependências:** tarefas 4 a 7.

- [x] Definir contratos orientados ao domínio para settings, users, trainings e
      histories.
- [x] Injetar o data service correspondente em cada implementação.
- [x] Fazer `SettingsRepository` manter o valor atual das configurações.
- [x] Fazer `UserRepository` manter o cache de usuários.
- [x] Fazer `TrainingRepository` organizar caches de treinos por usuário.
- [x] Fazer `HistoryRepository` organizar caches de históricos por treino.
- [x] Expor caches como coleções não modificáveis ou snapshots imutáveis.
- [x] Popular ou substituir o cache após leituras bem-sucedidas.
- [x] Atualizar o cache somente após escrita bem-sucedida no service.
- [x] Manter o cache anterior quando uma operação falhar.
- [x] Não armazenar loading, seleção, filtros, mensagens ou controllers de UI.
- [x] Testar sincronização entre service e cache nos caminhos alterados.

**Resultado esperado:** repositories são a fonte de verdade em memória sem
misturar estado visual.

### 9. Registrar a cadeia no AutoInjector

**Dependências:** tarefas 2 e 8.

- [x] Registrar o serviço de banco como singleton no composition root.
- [x] Registrar data services com suas dependências de construtor.
- [x] Registrar repositories com seus services de construtor.
- [x] Escolher ciclo de vida coerente para repositories que mantêm cache.
- [x] Não acessar o injector dentro de services, repositories, managers ou
      features.
- [x] Remover `DatabaseManager` da nova cadeia de injeção; acessos estáticos e
      instanciações internas remanescentes pertencem exclusivamente ao legado e
      serão eliminados junto de seus consumidores na task 10.
- [x] Garantir que o bootstrap inicialize o banco antes de consumers de dados.
- [x] Retornar falha controlada quando a inicialização de persistência impedir o
      restante do bootstrap.
- [x] Testar a resolução da cadeia principal pelo injector.

**Resultado esperado:** todas as dependências de persistência são visíveis nos
construtores e compostas em um único lugar.

### 10. Adaptar managers e consumidores legados

**Dependências:** tarefas 8 e 9.

- [x] Manter managers somente como adapters temporários para telas ainda não
      migradas.
- [x] Injetar repositories nos managers pelo construtor.
- [x] Remover as listas próprias de `UserManager`, `TrainingManager` e
      `HistoryManager`.
- [x] Fazer getters legados refletirem os caches dos repositories.
- [x] Preservar as APIs públicas necessárias aos controllers atuais, sem criar
      novos singletons.
- [x] Migrar `SettingsManager` estático para adapter injetável ou substituí-lo
      nos consumidores diretos.
- [x] Fazer migrations e backup dependerem de services, nunca de manager ou
      repository de UI.
- [x] Marcar cada adapter com o backlog responsável por removê-lo.
- [x] Testar compatibilidade somente nos consumidores conectados.

**Resultado esperado:** a aplicação antiga continua funcional enquanto a nova
camada data passa a ser a implementação real.

### 11. Remover duplicações e revisar fronteiras

**Dependências:** tarefas 1 a 10.

- [x] Remover Stores e repositories antigos depois que não possuírem mais
      consumidores.
- [x] Remover o controle de migration por settings e scripts históricos sem
      uso.
- [x] Verificar que somente `data` importa `sqflite` e constantes de schema.
- [x] Verificar que models de domínio não possuem `toMap`, `fromMap` ou nomes de
      colunas.
- [x] Verificar que nenhuma dependência de persistência é criada dentro da
      classe consumidora.
- [x] Verificar que nenhum código fora do composition root acessa o injector.
- [x] Verificar que repositories não mantêm estado visual.
- [x] Verificar que Viewmodels/controllers não duplicam os caches migrados.
- [x] Atualizar o documento de arquitetura com a estrutura efetivamente
      entregue.

**Resultado esperado:** existe uma única implementação para persistência,
cache e composição de dependências.

### 12. Validar e documentar a entrega

**Dependências:** tarefas 1 a 11.

- [x] Executar `dart format` nos arquivos alterados.
- [x] Executar os testes próximos aos services, repositories, cache, transação,
      backup e injector modificados.
- [x] Executar a suíte completa com `flutter test`.
- [x] Executar `flutter analyze` sem novas issues.
- [x] Executar `git diff --check`.
- [x] Registrar a dispensa da validação manual de abertura do aplicativo e
      leitura dos dados iniciais, adiada pelo responsável pelo projeto em
      2026-08-13 e não bloqueante para o encerramento desta etapa.
- [x] Validar inserção, alteração e exclusão em ao menos um fluxo conectado.
- [x] Confirmar que um banco incompatível produz backup antes do fallback.
- [x] Registrar adapters e limitações adiados para os backlogs 004 a 006.
- [x] Atualizar o acompanhamento de `003-persistencia-e-repositories.md`.
- [x] Marcar este checklist somente após todas as verificações.
- [x] Mover backlog e tasks concluídos para `doc/backlog/closed/`.

**Resultado esperado:** a camada de dados está injetável, o cache pertence aos
repositories, o aplicativo continua executável e o backlog 004 pode iniciar a
migração de settings para MVVM.

## Regra de conclusão

Os testes acompanham apenas comportamentos alterados e limites relevantes; o
objetivo não é ampliar cobertura geral. Uma tarefa só pode ser concluída quando
suas dependências estiverem explícitas, seus erros forem convertidos para
`Result`/`AppError` e não houver uma segunda fonte de verdade para o cache.
