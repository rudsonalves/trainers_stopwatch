# 006 — Tarefas de treinos e históricos

## Objetivo

Migrar consulta, edição, exclusão e seleção de treinos e históricos para MVVM,
operando sobre o domínio e os repositories novos, sem alterar o BLoC temporal.

## Decisões já tomadas

- a exclusão de treino delega à persistência a cascata dos históricos;
- persistir os eventos fundamentais e derivar os demais no domínio;
- o marco inicial e as durações das parciais são persistidos, enquanto as
  voltas são derivadas pela soma das parciais de cada ciclo;
- a seleção múltipla de treinos é estado transitório da UI;
- nomes e paths são centralizados no `go_router`, com navegação iniciada pelas
  Pages;
- UseCase será criado somente quando houver coordenação real entre treino e
  históricos.

## Ordem de execução

### 1. Consolidar a semântica de históricos no domínio

**Dependências:** backlogs 002, 003 e 005 concluídos.

- [x] Identificar no fluxo atual quais registros representam marco inicial e
      parciais.
- [x] Definir nos models de domínio a distinção entre evento persistido e volta
      derivada.
- [x] Derivar cada volta pela soma das parciais persistidas que compõem seu
      ciclo, mantendo o marco inicial fora do cálculo de duração.
- [x] Definir o comportamento para lista vazia, evento inicial ausente, ordem
      inválida e durações nulas, negativas ou repetidas.
- [x] Centralizar a derivação no domínio, sem cálculo concorrente na UI ou em
      models SQLite.
- [x] Preservar edição de comentários sem transformar volta derivada em novo
      registro persistido.

**Resultado esperado:** marco inicial e parciais formam uma única fonte de
verdade, e voltas são reproduzidas de maneira previsível pelo domínio.

**Entregue em 2026-08-20:** `TrainingEvent` agora identifica explicitamente a
origem persistida de `TrainingStarted` e `SplitRecorded` e a origem derivada de
`LapRecorded`. `TrainingEventGenerator` valida o marco inicial com duração zero,
parciais positivas e a ordem crescente das identidades persistidas. Lista vazia
continua válida, durações negativas permanecem bloqueadas por `HistoryEntry` e
durações repetidas são aceitas como medições independentes. As voltas continuam
sendo produzidas somente no domínio pela soma das parciais de cada ciclo, com o
comentário e a identidade da parcial que fecha a volta, sem criar outro registro
persistido.

### 2. Adequar contratos e repositories de treinos e históricos

**Dependência:** tarefa 1.

- [x] Confirmar que os contratos recebem e devolvem somente models de domínio.
- [x] Eliminar maps SQLite das fronteiras consumidas por aplicação e UI.
- [x] Expor carga de treinos por usuário e de históricos por treino.
- [x] Preservar cache no repository somente para consumidores que precisem de
      observação ou reutilização real dos dados.
- [x] Garantir que falhas preservem o último cache válido e retornem
      `Result`/`AppError` conforme o padrão do projeto.
- [x] Comprovar que excluir um treino remove seus históricos pela cascata.
- [x] Manter atualização de comentários e integridade das relações entre
      usuário, treino e histórico.

**Resultado esperado:** a camada de aplicação dispõe de contratos orientados
ao domínio e a exclusão não precisa coordenar remoções registro a registro.

**Entregue em 2026-08-20:** os contratos existentes de `TrainingRepository` e
`HistoryRepository` foram auditados e confirmados com entradas e saídas
exclusivamente de domínio; maps permanecem internos aos mappers e services. Os
caches imutáveis por usuário e por treino foram mantidos porque ainda alimentam
os consumidores dos fluxos e são atualizados somente após persistência
bem-sucedida. Testes agora comprovam isolamento, imutabilidade, preservação do
último snapshot em falhas de leitura e escrita, atualização de comentários e
merge de duração. O contrato do schema cobre as cascatas usuário → treino e
treino → histórico, em conjunto com a ativação de foreign keys já testada em
`DatabaseService`; portanto a exclusão pública continua removendo apenas o
treino.

### 3. Implementar a coordenação entre treino e históricos

**Dependências:** tarefas 1 e 2.

- [x] Mapear as operações que escrevem treino e histórico no mesmo fluxo.
- [x] Criar um UseCase somente para operações que exijam essa coordenação.
- [x] Garantir que a criação de treino e de seu marco inicial preserve
      consistência em falhas parciais.
- [x] Fazer o UseCase receber dependências por construtor e devolver
      `Result`/`AppError`.
- [x] Delegar operações simples diretamente ao repository quando não houver
      regra ou coordenação adicional.
- [x] Não criar UseCase para repetir a exclusão em cascata.

**Resultado esperado:** operações compostas têm uma fronteira explícita, sem
transformar cada chamada simples de repository em um UseCase vazio.

**Entregue em 2026-08-20:** `CreateTrainingUseCase` coordena exclusivamente a
inserção do treino e de seu marco inicial com duração zero. Se a inserção do
histórico falhar, o treino recém-criado é removido e a cascata mantém a
persistência consistente; se essa compensação também falhar, o `AppError`
preserva os erros primário e compensatório e a identidade do treino. O resultado
de sucesso retorna `TrainingInitialization` com as duas entidades persistidas.
O UseCase é transient, recebe ambos os repositories por construtor e já é usado
pelo fluxo real de início do cronômetro. Carga, atualização, exclusão e inserção
de parciais continuam delegadas diretamente aos respectivos repositories.

### 4. Criar TrainingsViewModel e estado de seleção

**Dependências:** tarefas 2 e 3 e padrão MVVM do backlog 005.

- [x] Criar `TrainingsViewModel` com dependências recebidas por construtor.
- [x] Expor Commands para carregar, atualizar e excluir treinos.
- [x] Expor seleção de usuário e carregamento dos treinos relacionados.
- [x] Manter a seleção múltipla como estado transitório da UI.
- [x] Expor IDs selecionados como coleção não modificável.
- [x] Implementar selecionar, desselecionar, selecionar todos e limpar seleção.
- [x] Reconciliar a seleção após troca de usuário, recarga e exclusão.
- [x] Consolidar loading e último `AppError` sem estados paralelos legados.
- [x] Não armazenar `BuildContext`, widgets ou `TextEditingController`.

**Resultado esperado:** a página de treinos possui estado e operações testáveis
sem depender de managers ou models legados.

**Entregue em 2026-08-20:** `TrainingsViewModel` recebe `UserRepository` e
`TrainingRepository` por construtor e expõe Commands para carregar usuários,
carregar os treinos do usuário selecionado, atualizar, excluir e excluir a
seleção. Os caches de domínio continuam nos repositories; o ViewModel mantém
somente o usuário selecionado, IDs selecionados, loading e último `AppError`.
A seleção é imutável para consumidores, ignora entidades indisponíveis e é
reconciliada em troca de usuário, recarga, exclusão individual, exclusão em lote
e remoção do usuário selecionado. Falhas preservam o último cache válido, e uma
falha no meio da exclusão em lote mantém selecionados apenas os itens ainda
existentes. O ViewModel não contém contexto, widgets ou controllers visuais.

### 5. Criar HistoryViewModel e apresentação derivada

**Dependências:** tarefas 1 a 3.

- [x] Criar `HistoryViewModel` com dependências recebidas por construtor.
- [x] Expor Commands para carregar, atualizar comentários e excluir históricos.
- [x] Expor históricos persistidos e voltas derivadas usando o domínio.
- [x] Atualizar informações e estatísticas após cada mutação bem-sucedida.
- [x] Consolidar loading e último `AppError` sem estados paralelos legados.
- [x] Preservar o comportamento das páginas de histórico e treino pessoal.
- [x] Não armazenar `BuildContext`, widgets ou `TextEditingController`.

**Resultado esperado:** consulta e edição de históricos usam uma única regra de
derivação e não dependem de `HistoryController` ou `HistoryManager`.

**Entregue em 2026-08-20:** `HistoryViewModel` recebe o treino e o contrato de
`HistoryRepository` por construtor e expõe Commands para carga, atualização de
comentários e exclusão com merge da próxima parcial. Históricos persistidos
continuam vindo do cache imutável do repository, enquanto eventos, parciais,
voltas e estatísticas são recalculados exclusivamente pelo
`TrainingEventGenerator` após cada mutação bem-sucedida. A apresentação válida
anterior é preservada em falhas, loading e último `AppError` são consolidados,
e as restrições atuais de exclusão do marco inicial e da última medição foram
mantidas. O ViewModel não contém dependências visuais; a conexão das páginas e
do fluxo pessoal permanece reservada à tarefa 6.

### 6. Migrar páginas, widgets e rotas

**Dependências:** tarefas 4 e 5.

- [x] Fazer a página de treinos consumir `TrainingsViewModel` e seus Commands.
- [x] Fazer as páginas de histórico consumirem `HistoryViewModel` e seus
      Commands.
- [x] Adequar widgets compartilhados de lista, edição e remoção para receber
      estado e callbacks tipados.
- [x] Remover das páginas o acesso a managers, stores e repositories concretos.
- [x] Operar com `User`, `Training` e `HistoryEntry` de domínio nos fluxos
      migrados.
- [x] Manter dialogs, controllers de texto e confirmação de gesto na UI.
- [x] Preservar layout, mensagens, edição de comentários e seleção atuais.
- [x] Remover os arquivos `page-name_overlay.dart` remanescentes de settings,
      users, stopwatch e trainings, pois o sistema de ajuda por overlay já foi
      removido.
- [x] Fazer as rotas construírem diretamente suas Pages e transferir para essa
      composição a criação e o descarte das dependências antes pertencentes aos
      wrappers de overlay.
- [x] Manter rotas nomeadas no `go_router` e definir argumentos tipados para
      entidades relacionadas.

**Resultado esperado:** a UI coordena somente interação e navegação, consumindo
ViewModels e tipos de domínio.

**Entregue em 2026-08-20:** as páginas de treinos, histórico salvo e treino
pessoal foram movidas para `lib/ui/pages` e agora consomem
`TrainingsViewModel`/`HistoryViewModel`, Commands e entidades de domínio. Lista,
seleção, edição de comentários e exclusão usam callbacks tipados; dialogs e
controllers de texto permanecem restritos aos widgets. O compartilhamento
passou a receber `User` e `Training` na fronteira da UI. Settings, users,
stopwatch e trainings deixaram de usar wrappers `*_overlay.dart`; o
`go_router` constrói diretamente cada Page, que assume o descarte de seus
ViewModels descartáveis. Os controllers e managers agora sem consumidores de
página permanecem fisicamente no projeto somente para a limpeza de composição
prevista na tarefa 7; o fluxo temporal do cronômetro não foi alterado.

### 7. Atualizar injeção e remover adapters legados

**Dependência:** tarefa 6.

- [x] Registrar factories dos ViewModels e eventual UseCase no composition
      root com ciclos de vida apropriados.
- [x] Remover a classe trivial `UsersViewModelFactory`; manter a criação por
      callback tipado no composition root para aceitar os IDs conhecidos em
      tempo de navegação.
- [x] Atualizar a criação das rotas de treinos e históricos.
- [x] Remover `TrainingsPageController` e `HistoryPageController` quando ficarem
      sem consumidores.
- [x] Remover `HistoryController` quando todas as subclasses forem migradas.
- [x] Remover `TrainingManager`, `HistoryManager` e seus registros quando
      ficarem sem consumidores.
- [x] Remover `UserManager` após migrar seu último consumidor no fluxo de
      treinos.
- [x] Verificar adapters usados pelo cronômetro e transferir ao backlog 008
      somente os que ainda pertencerem ao fluxo de sessões.
- [x] Confirmar que somente o composition root acessa o injector.

**Resultado esperado:** os fluxos migrados são compostos por contratos,
UseCases quando necessários e ViewModels, sem adapters temporários do backlog
003.

**Entregue em 2026-08-20:** os callbacks tipados que criam
`TrainingsViewModel`, `HistoryViewModel`, `UsersViewModel` e
`SettingsViewModel` ficam no composition root e produzem instâncias com ciclo
de vida da rota, sem classes Factory intermediárias. Foram removidos
`TrainingsPageController`, `HistoryPageController`,
`PersonalTrainingController`, `HistoryController`, seus estados e registros,
além de `UserManager`. `TrainingManager` e `HistoryManager` não puderam ser
removidos porque ainda compõem `PreciseStopwatchController`; sua substituição,
junto aos adapters de sessão, foi explicitada no backlog 008. Conversões ainda
usadas pelo PDF foram registradas no backlog 009. O acesso ao injector permanece
restrito a `main.dart` e `lib/core/config`, que formam o composition root.

### 8. Testar regras, coordenações e comportamento migrado

**Dependências:** tarefas 1 a 7.

- [x] Testar derivação da primeira volta e das voltas seguintes.
- [x] Testar entradas vazias, ausentes, repetidas, fora de ordem ou regressivas.
- [x] Testar carga, atualização, exclusão e preservação de cache em falhas.
- [x] Testar cascata de treino para históricos em integração com a
      persistência.
- [x] Testar coordenação e compensação de operações compostas.
- [x] Testar seleção individual, seleção total, troca de usuário, recarga e
      exclusão de item selecionado.
- [x] Testar edição de comentários e atualização das informações derivadas.
- [x] Testar factories, ciclos de vida e argumentos tipados das rotas.
- [x] Testar a construção direta das Pages pelas rotas após a remoção dos
      wrappers `*_overlay.dart`.

**Resultado esperado:** regras modificadas e fronteiras entre domínio,
persistência, aplicação e UI possuem cobertura proporcional ao risco.

**Entregue em 2026-08-20:** testes de domínio cobrem marco inicial, primeira
volta, múltiplas voltas, entradas vazias, repetidas, inválidas e fora de ordem.
Repositories e persistência cobrem caches, falhas, comentários, merge e
cascata. UseCase cobre ordem e compensação da criação composta. ViewModels
cobrem carga, seleção, troca de usuário, recarga, exclusões e atualização das
informações derivadas. A composição cobre ciclos de vida transient, argumentos
de domínio e construção direta de Settings, Users, Trainings e Stopwatch Pages
sem wrappers de overlay.

### 9. Validar e documentar a entrega

**Dependência:** tarefas 1 a 8.

- [x] Executar `dart format` nos arquivos alterados.
- [x] Executar os testes focados de domínio, repositories, UseCases e
      ViewModels.
- [x] Executar a suíte completa com `flutter test`.
- [x] Executar `flutter analyze` sem novas issues.
- [x] Executar `git diff --check`.
- [x] Delegar ao usuário a validação exploratória de consulta, troca de usuário,
      seleção, edição e exclusão; problemas encontrados serão tratados como
      correções posteriores.
- [x] Registrar limitações mantidas para os backlogs 008 e 009.
- [x] Atualizar arquitetura e acompanhamento do backlog 006; `Changelog.md` é
      gerenciado por outra aplicação e não foi alterado.
- [x] Mover backlog e tasks concluídos para `doc/backlog/closed/`.

**Resultado esperado:** os fluxos de treinos e históricos funcionam em MVVM e
os backlogs 008 e 009 recebem fronteiras de domínio estáveis.

**Entregue em 2026-08-20:** `dart format` não produziu alterações,
`flutter analyze` terminou sem issues, os 245 testes passaram e
`git diff --check` não encontrou erros. O aplicativo também compilou, instalou
e iniciou em um Android físico, exibindo a tela inicial e o drawer esperado.
A exploração completa dos fluxos no dispositivo ficou com o usuário. As
dependências temporárias de sessão foram registradas no backlog 008 e as de
relatório/compartilhamento no backlog 009. O changelog permanece fora do escopo
deste processo.

## Regra de conclusão

O backlog só pode ser encerrado quando as páginas migradas não dependerem de
managers, stores, repositories concretos ou models SQLite; voltas forem
derivadas exclusivamente dos eventos fundamentais; a cascata preservar a
integridade; e testes e análise terminarem sem novos erros.
