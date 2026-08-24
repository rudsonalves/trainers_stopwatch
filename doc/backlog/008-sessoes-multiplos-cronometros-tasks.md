# 008 — Tarefas de sessões e múltiplos cronômetros

## Objetivo

Substituir a composição legada de widgets e controllers globais por sessões
MVVM independentes, mantendo o `StopwatchBloc` como núcleo temporal e tornando
criação do treino, persistência, mensagens e descarte responsabilidades
explícitas da sessão.

## Decisões já tomadas

- a sessão continua ativa durante a navegação e não depende do ciclo de vida da
  `StopWatchPage`;
- somente ações temporais explícitas ou descarte confirmado alteram uma medição;
- uma escrita de snapshot é identificada por treino persistido e
  `snapshotRevision`;
- tentativas repetidas reutilizam a mesma identidade e o mesmo conteúdo, e uma
  identidade já persistida é tratada como sucesso;
- remover uma sessão em execução ou pausada exige confirmação, encerra a
  medição e aguarda a persistência final antes do descarte;
- falha de persistência preserva a sessão, o tempo medido e a escrita pendente;
- sessões `idle`, ou `finished` e sincronizadas, podem ser removidas sem
  confirmação temporal;
- mensagens são mantidas por sessão e a lista global é uma projeção
  cronológica derivada;
- não haverá uma ação implícita de descartar treino sem salvar.

## Ordem de execução

### 1. Modelar a identidade e o estado operacional da sessão

**Dependência:** backlog 007 concluído.

- [ ] Criar os models de aplicação da sessão próximos ao consumidor em
      `lib/application/stopwatch/session/`, sem dependências de widgets ou
      `BuildContext`.
- [ ] Definir uma identidade estável de sessão baseada no ID persistido do
      atleta, adequada para `ValueKey` e para localizar, editar e remover a
      sessão.
- [ ] Modelar o estado imutável da sessão com atleta, treino corrente, estado de
      inicialização, estado de persistência, escrita pendente, mensagens e erro
      recuperável.
- [ ] Representar cada escrita por um valor imutável contendo o ID do treino,
      `snapshotRevision`, tipo de snapshot e conteúdo que será repetido sem
      reconstrução.
- [ ] Modelar mensagens de apresentação com identidade da sessão, identidade do
      evento ou revisão, ordem temporal estável, tipo e conteúdo necessário à
      UI.
- [ ] Não duplicar duração, contadores ou status temporal no estado da sessão;
      esses valores continuam pertencendo ao `StopwatchState`.

**Resultado esperado:** sessão, escrita pendente e mensagem possuem identidades
explícitas e não dependem da árvore de widgets.

### 2. Criar as operações de persistência idempotente

**Dependência:** tarefa 1.

- [ ] Definir em `lib/domain/` a operação necessária para persistir um snapshot
      uma única vez por `trainingId + snapshotRevision`, sem acoplar o domínio
      ao BLoC.
- [ ] Adaptar `HistoryEntry`, mapper, service e repository somente com os campos
      necessários para conservar a identidade da escrita até o banco.
- [ ] Adicionar ao schema uma restrição única para a identidade idempotente e a
      migração compatível com bancos existentes, preservando históricos já
      gravados.
- [ ] Fazer a inserção retornar o registro existente como sucesso quando a
      mesma identidade e o mesmo conteúdo já estiverem persistidos.
- [ ] Tratar a mesma identidade com conteúdo diferente como inconsistência, sem
      sobrescrever silenciosamente o registro anterior.
- [ ] Manter a escrita imutável na sessão após falha; `retry` deve reenviar o
      mesmo valor, sem gerar nova revisão ou nova mensagem de sucesso.
- [ ] Preservar a criação transacional de treino e marcador inicial fornecida
      por `CreateTrainingUseCase`.

**Resultado esperado:** repetir uma tentativa após resultado incerto ou falha
recuperável nunca duplica uma parcial.

### 3. Implementar `StopwatchSessionViewModel`

**Dependências:** tarefas 1 e 2.

- [ ] Criar `StopwatchSessionViewModel` em
      `lib/application/stopwatch/session/stopwatch_session_view_model.dart` com
      um `StopwatchBloc` exclusivo e dependências recebidas por construtor.
- [ ] Inicializar a sessão com o model de domínio `User`, configurações do treino
      e callbacks/factories necessários, sem `UserModel`, managers ou singletons.
- [ ] Criar e persistir o treino antes do primeiro início efetivo e configurar o
      BLoC com os limites desse treino.
- [ ] Coordenar início, pausa, retomada, reset, parcial, volta e encerramento por
      métodos nomeados que despachem os eventos públicos correspondentes do
      BLoC.
- [ ] Consumir cada `snapshotRevision` uma única vez e converter seu snapshot em
      uma escrita imutável antes de chamar a persistência.
- [ ] Manter a medição e o snapshot intactos quando a persistência falhar, expor
      o erro no estado e oferecer nova tentativa da escrita pendente.
- [ ] Só publicar a mensagem de sucesso da ação depois que sua escrita estiver
      confirmada, evitando mensagens duplicadas em `retry`.
- [ ] Ao terminar, persistir os segmentos finais, marcar a sessão como
      sincronizada e preparar um treino limpo apenas quando o próximo início for
      solicitado.
- [ ] Implementar `dispose()` idempotente que cancele Commands/observações da
      sessão e aguarde `StopwatchBloc.close()`.

**Resultado esperado:** cada atleta possui uma unidade operacional independente
que coordena BLoC e persistência sem conhecer widgets ou navegação.

### 4. Implementar `StopwatchPageViewModel`

**Dependência:** tarefa 3.

- [ ] Criar `StopwatchPageViewModel` em
      `lib/application/stopwatch/stopwatch_page_view_model.dart` e torná-lo o
      proprietário das sessões enquanto a aplicação estiver ativa.
- [ ] Receber por construtor uma factory de `StopwatchSessionViewModel` e manter
      somente models/ViewModels indexados pela identidade estável do atleta.
- [ ] Adicionar os atletas selecionados sem duplicar sessões já existentes e
      expor IDs ativos para a página de seleção.
- [ ] Expor uma coleção imutável e observável de sessões, sem listas paralelas de
      usuários, contadores manuais ou widgets armazenados.
- [ ] Derivar a lista global de mensagens combinando apenas as mensagens das
      sessões existentes e ordenando-as pela identidade temporal estável.
- [ ] Fazer navegação e reconstruções da Page preservarem as mesmas instâncias
      das sessões e seus BLoCs.
- [ ] No descarte do ViewModel da aplicação, encerrar e aguardar o descarte de
      todas as sessões ainda existentes.

**Resultado esperado:** a página observa uma coleção de sessões persistente e
não controla manualmente o ciclo de vida de cada cronômetro.

### 5. Definir remoção segura de uma sessão

**Dependências:** tarefas 3 e 4.

- [ ] Expor no `StopwatchPageViewModel` uma consulta de remoção que informe se a
      Page deve pedir confirmação, mantendo o diálogo sob responsabilidade da
      UI.
- [ ] Remover diretamente uma sessão `idle`, ou `finished` sem escrita pendente.
- [ ] Ao confirmar a remoção de uma sessão `running` ou `paused`, solicitar seu
      encerramento e aguardar todas as escritas finais.
- [ ] Somente retirar a sessão da coleção e executar `dispose()` depois que ela
      estiver encerrada e sincronizada.
- [ ] Se o usuário cancelar, não despachar evento temporal nem alterar a sessão.
- [ ] Se alguma escrita falhar, manter a sessão na coleção com o erro e a escrita
      pendente disponíveis para nova tentativa.
- [ ] Impedir comandos concorrentes de remoção, encerramento e `retry` para a
      mesma sessão.

**Resultado esperado:** remover um atleta nunca perde silenciosamente uma
medição ou descarta recursos antes de concluir sua persistência.

### 6. Migrar os widgets para sessões

**Dependências:** tarefas 3 a 5.

- [ ] Fazer `StopWatchPage` observar `StopwatchPageViewModel` e construir um
      cronômetro por sessão com `ValueKey` baseada na identidade do atleta.
- [ ] Alterar `PreciseStopwatch` para receber `StopwatchSessionViewModel`, sem
      criar, inicializar ou descartar o controller temporal no estado do widget.
- [ ] Manter `StopwatchDisplay`, contadores e barra de botões observando o
      `StopwatchBloc` da sessão.
- [ ] Mover edição das configurações do treino para métodos da sessão e manter o
      diálogo e seus `ValueNotifier`s estritamente na apresentação.
- [ ] Adaptar `StopwatDismissible` para consultar a necessidade de confirmação e
      delegar a remoção confirmada ao Page ViewModel.
- [ ] Renderizar o log global a partir da projeção de mensagens do Page
      ViewModel, sem `_messageList` local nem canal `historyMessage` global.
- [ ] Preservar layout, gestos atuais e feedback visível de inicialização,
      persistência pendente, falha recuperável e nova tentativa.

**Resultado esperado:** widgets são reconstruções descartáveis do estado das
sessões e nenhuma medição depende da permanência de um widget na árvore.

### 7. Migrar seleção, rotas e composição

**Dependências:** tarefas 4 e 6.

- [ ] Substituir `StopwatchPageController` por `StopwatchPageViewModel` nas
      dependências de `StopWatchPage`, `UsersPage`, `MainRouteDependencies` e
      `MyMaterialApp`.
- [ ] Fazer o retorno da seleção entregar models de domínio ao Page ViewModel e
      usar suas identidades de sessão para bloquear atletas já ativos.
- [ ] Alterar `PersonalTrainingRouteArguments` para transportar identidade ou
      ViewModel de sessão, nunca um widget `PreciseStopwatch`.
- [ ] Fazer a rota de treino pessoal obter `Training` diretamente da sessão,
      removendo a conversão `TrainingModel.toDomain()` da configuração de rotas.
- [ ] Registrar factories e ViewModels em `lib/core/config/dependencies/` com o
      escopo necessário para manter as sessões durante a navegação.
- [ ] Remover a configuração tardia `StopwatchPageController.configure()` e a
      dependência circular entre controller da página e controller do
      cronômetro.
- [ ] Confirmar que Pages continuam sendo as únicas responsáveis por abrir
      rotas e diálogos.

**Resultado esperado:** composição e navegação usam estado de domínio/sessão e
não transportam widgets nem adapters legados.

### 8. Remover a composição legada

**Dependências:** tarefas 3, 6 e 7.

- [ ] Remover `PreciseStopwatchController` depois que todos os seus consumidores
      tiverem sido migrados.
- [ ] Remover `StopwatchPageController` depois que seleção, lista, mensagens e
      rotas consumirem o novo Page ViewModel.
- [ ] Remover `TrainingManager` e `HistoryManager`, seus registros no injector e
      imports restantes.
- [ ] Remover do fluxo de sessão os adapters de `UserModel`, `TrainingModel` e
      `HistoryModel`, preservando-os apenas se outro fluxo legado ainda possuir
      consumidor comprovado.
- [ ] Remover listas de `PreciseStopwatch`, `GlobalKey` por cronômetro, canal
      global de mensagem e flags temporais paralelas ao estado do BLoC.
- [ ] Atualizar comentários de migração que ainda atribuam ao backlog 007
      responsabilidades agora tratadas pelo backlog 008.
- [ ] Usar `rg` para confirmar que managers, controllers e conversões removidos
      não possuem consumidores restantes.

**Resultado esperado:** não resta uma segunda arquitetura de sessão concorrendo
com os novos ViewModels.

### 9. Testar coordenação, independência e descarte

**Dependências:** tarefas 1 a 8.

- [ ] Testar criação de uma sessão por atleta, rejeição de duplicatas e
      preservação das instâncias durante navegação/reconstrução da Page.
- [ ] Testar que iniciar, pausar, retomar, registrar ações e encerrar uma sessão
      não altera estado, ticker, mensagens ou persistência das demais.
- [ ] Testar que o treino é persistido antes do primeiro início observável e que
      uma falha de criação não inicia uma medição órfã.
- [ ] Testar consumo único de cada revisão e persistência de parcial, volta,
      encerramento e conclusão automática por limite de voltas.
- [ ] Testar falha antes e depois de uma escrita efetiva, repetição com a mesma
      identidade e ausência de duplicação no banco.
- [ ] Testar que uma tentativa bem-sucedida limpa somente a escrita pendente
      correspondente e publica uma única mensagem.
- [ ] Testar remoção direta de sessão `idle` e `finished` sincronizada.
- [ ] Testar cancelamento da confirmação sem alteração temporal.
- [ ] Testar remoção confirmada durante execução e pausa, incluindo
      encerramento, persistência final e descarte posterior.
- [ ] Testar que falha na persistência final impede a remoção e permite `retry`.
- [ ] Testar que remover uma sessão cancela somente seu BLoC e seus recursos.
- [ ] Testar projeção global ordenada a partir de mensagens isoladas por sessão
      e retirada das mensagens ao remover o atleta.
- [ ] Testar em widget seleção, chaves estáveis, controles, diálogo de remoção,
      erro recuperável e navegação para edição sem transportar widget na rota.

**Resultado esperado:** testes determinísticos comprovam a coordenação sem
esperas reais e sem acoplamento entre atletas.

### 10. Validar e documentar a entrega

**Dependência:** tarefas 1 a 9.

- [ ] Executar `dart format` nos arquivos alterados.
- [ ] Executar os testes focados de sessão, persistência e widgets migrados.
- [ ] Executar a suíte completa com `flutter test`.
- [ ] Executar `flutter analyze` sem novas issues.
- [ ] Executar `git diff --check`.
- [ ] Validar manualmente múltiplos cronômetros, navegação com medição ativa,
      falha/repetição de escrita e todos os caminhos de remoção.
- [ ] Confirmar por busca que nenhum controller/ViewModel armazena widget ou
      `BuildContext` e que managers/adapters removidos não têm consumidores.
- [ ] Atualizar o acompanhamento do backlog 008 com os resultados e limitações
      da entrega.
- [ ] Mover backlog e tasks concluídos para `doc/backlog/closed/` somente depois
      de cumprir os critérios de aceite.

**Resultado esperado:** a migração permanece executável, analisada e testada,
com as decisões e eventuais limitações registradas.

## Regra de conclusão

O backlog só pode ser encerrado quando cada atleta possuir uma sessão
independente e persistente durante navegação; widgets forem derivados de
identidades estáveis; repetição de escrita for idempotente; remoção ativa nunca
perder uma medição; mensagens pertencerem às sessões; controllers, managers e
adapters temporários não tiverem consumidores; e testes, análise e verificação
do diff terminarem sem novos erros.
