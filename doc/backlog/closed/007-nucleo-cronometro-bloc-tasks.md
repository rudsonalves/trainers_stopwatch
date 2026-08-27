# 007 — Tarefas do núcleo temporal do cronômetro com BLoC

## Objetivo

Reimplementar a máquina temporal do cronômetro com BLoC e
`dart:core Stopwatch`, tornando seu estado a única fonte de duração e
contadores, sem incorporar persistência ou responsabilidades de sessão.

## Decisões já tomadas

- `Stopwatch.elapsed` é a única fonte de tempo decorrido em produção;
- o ticker solicita atualizações visuais a cada 50 ms por padrão, mas não mede
  a duração;
- uma volta também fecha a parcial corrente e produz um `LapSnapshot` com as
  duas durações;
- o encerramento é válido durante execução e pausa;
- em execução, o encerramento usa a duração do instante do evento;
- em pausa, o encerramento preserva a duração congelada e não contabiliza o
  período pausado;
- reset retorna ao estado `idle`, zerando a medição;
- encerramento emite `finished`, preservando duração, contadores e
  `FinishSnapshot`;
- um novo início depois de `finished` cria uma medição limpa;
- eventos inválidos não dependem da habilitação dos botões e não lançam
  exceções por estado incompleto;
- data civil é obtida por um callback `DateTime Function()` injetável e não
  participa do cálculo da duração;
- persistência, coordenação de sessões e tratamento de falhas de escrita
  permanecem no backlog 008.

## Ordem de execução

### 1. Definir dependências temporais injetáveis

**Dependências:** backlogs 002, 003 e 006 concluídos.

- [x] Receber no BLoC um callback `DateTime Function()` para fornecer
      exclusivamente a data civil, usando `DateTime.now` em produção e funções
      controláveis nos testes.
- [x] Receber no BLoC um callback `Stopwatch Function()` para criar a fonte
      monotônica, usando `Stopwatch.new` em produção e uma implementação
      controlável nos testes.
- [x] Manter esses callbacks próximos ao consumidor, sem criar interfaces,
      classes concretas ou arquivos que apenas encaminhem `DateTime.now` e
      `Stopwatch.new`.
- [x] Usar diretamente um `Timer?` privado como ticker visual, sem criar
      interface, factory ou service para ele.
- [x] Adotar 50 ms como intervalo padrão e permitir a injeção somente desse
      `Duration` em testes.
- [x] Manter o `Timer` restrito ao pedido de atualização visual.
- [x] Não colocar dependências de Flutter, settings, banco ou tradução nas
      dependências temporais.

**Resultado esperado:** duração monotônica, data civil e solicitação de render
possuem responsabilidades distintas, sem abstrações cerimoniais, e podem ser
testadas deterministicamente.

### 2. Modelar eventos, status e estado imutável

**Dependência:** tarefa 1.

- [x] Substituir as classes de estado vazias por um estado imutável com status,
      duração, contadores e resultado temporal mais recente.
- [x] Representar explicitamente os status `idle`, `running`, `paused` e
      `finished`.
- [x] Incluir no estado os horários civis necessários de início e encerramento,
      sem usá-los para calcular duração.
- [x] Representar o limite opcional de voltas como configuração validada da
      medição, sem campo público livremente mutável durante a execução.
- [x] Expor `SplitSnapshot`, `LapSnapshot` ou `FinishSnapshot` no estado quando
      uma ação produzir um novo marco.
- [x] Associar ao snapshot uma revisão monotônica para que consumidores possam
      distinguir uma nova ação dos ticks visuais subsequentes.
- [x] Garantir igualdade por valor e `copyWith` ou construção equivalente sem
      mutação interna observável.
- [x] Representar iniciar, pausar, retomar, resetar, parcial, volta e encerrar
      como eventos explícitos.
- [x] Criar um evento interno de tick que não faça parte da API de interação da
      UI.
- [x] Eliminar `StopwatchStateReset`; reset deve ser uma transição para
      `idle`.
- [x] Definir eventos inválidos como operações sem efeito, sem emitir estado de
      erro para transições normais rejeitadas.

**Resultado esperado:** um único estado descreve integralmente a máquina
temporal e permite identificar cada snapshot produzido.

### 3. Implementar a máquina temporal no BLoC

**Dependências:** tarefas 1 e 2.

- [x] Injetar os callbacks de data civil e criação de `Stopwatch`, o intervalo
      visual e o limite opcional de voltas pelo construtor.
- [x] Ao iniciar em `idle` ou `finished`, zerar a medição anterior, capturar a
      data civil inicial, iniciar o `Stopwatch` e ativar o ticker.
- [x] Ao pausar em `running`, parar o `Stopwatch`, cancelar o ticker e emitir a
      duração congelada.
- [x] Ao retomar em `paused`, reiniciar a mesma instância de `Stopwatch` e
      reativar o ticker sem contar o período parado.
- [x] Em cada tick válido, consultar somente `Stopwatch.elapsed` e atualizar a
      duração visual sem alterar contadores ou snapshots.
- [x] Ao registrar parcial em `running`, calcular a diferença entre o elapsed
      atual e o último marco de parcial.
- [x] Ao registrar volta em `running`, calcular no mesmo elapsed as diferenças
      desde os últimos marcos de parcial e volta.
- [x] Incrementar os contadores de parcial e volta de forma atômica com a
      criação do snapshot correspondente.
- [x] Preservar a regra atual de reinício do contador de parciais por volta com
      base na quantidade configurada de parciais por volta.
- [x] Ao atingir o limite opcional de voltas, concluir automaticamente a
      medição com os mesmos dados da volta final e emitir `finished`.
- [x] Ao encerrar em `running`, parar o `Stopwatch`, cancelar o ticker e fechar
      os segmentos finais de parcial e volta.
- [x] Ao encerrar em `paused`, manter o elapsed congelado e fechar os segmentos
      finais sem incluir o período pausado.
- [x] Produzir `FinishSnapshot` com as durações finais, contadores atualizados e
      horário civil de encerramento.
- [x] Ao resetar nos estados permitidos, parar e zerar o `Stopwatch`, cancelar o
      ticker e emitir `idle` sem snapshot anterior.
- [x] Ignorar com segurança eventos incompatíveis com o status atual.
- [x] Remover do BLoC acessos a `AppSettings`, `ValueNotifier`, cores, usuário,
      tradução, widgets, ViewModels e persistência.

**Resultado esperado:** toda duração e todo segmento derivam exclusivamente de
snapshots de `Stopwatch.elapsed`, com transições válidas e previsíveis.

### 4. Garantir ciclo de vida e concorrência dos eventos

**Dependência:** tarefa 3.

- [x] Fazer o ticker despachar eventos internos em vez de emitir estado fora de
      um handler do BLoC.
- [x] Impedir a criação de mais de um ticker para a mesma medição.
- [x] Descartar ticks enfileirados depois de pausa, reset, encerramento ou
      fechamento do BLoC.
- [x] Cancelar o ticker ao atingir o limite de voltas.
- [x] Sobrescrever `close()` para cancelar o ticker e liberar seus recursos
      antes de fechar o BLoC.
- [x] Tornar chamadas repetidas de pausa, reset, encerramento e fechamento
      seguras e idempotentes quando aplicável.
- [x] Remover o método `dispose()` próprio do BLoC e padronizar consumidores em
      `close()`.

**Resultado esperado:** nenhum ticker sobrevive à medição ou ao BLoC, e eventos
atrasados não restauram estados antigos.

### 5. Adaptar minimamente os consumidores legados

**Dependências:** tarefas 2 a 4.

- [x] Fazer o display observar `StopwatchState.elapsed` pelo stream do BLoC.
- [x] Fazer os contadores observarem somente os campos do estado do BLoC.
- [x] Atualizar a barra de botões para os status `idle`, `running`, `paused` e
      `finished`.
- [x] Usar o evento explícito de retomada no botão correspondente.
- [x] Adaptar `PreciseStopwatchController` para obter início, duração,
      contadores e snapshots exclusivamente do estado emitido.
- [x] Remover esperas fixas de 100 ms usadas apenas para aguardar o
      processamento de eventos, substituindo-as por observação do estado ou
      coordenação determinística equivalente.
- [x] Fazer o controller legado consumir uma única vez cada revisão de
      snapshot ao gerar os registros temporários atuais.
- [x] Manter persistência, mensagens, usuário, cores e tradução fora do BLoC e
      no adapter legado existente até o backlog 008.
- [x] Preservar o layout e os gestos atuais, inclusive reset e encerramento por
      toque longo.
- [x] Não introduzir `StopwatchSessionViewModel`, múltiplas sessões novas ou a
      migração dos managers reservada ao backlog 008.

**Resultado esperado:** a aplicação atual continua funcional sem
`ValueNotifier`s paralelos ao estado temporal e sem antecipar a arquitetura de
sessões.

### 6. Atualizar composição e remover dependências temporais legadas

**Dependência:** tarefa 5.

- [x] Atualizar a criação do BLoC para receber os callbacks e as configurações
      temporais necessárias.
- [x] Manter o BLoC com ciclo de vida independente por cronômetro existente.
- [x] Remover do BLoC a leitura direta de
      `AppSettings.instance.mSecondRefresh`.
- [x] Transferir o intervalo visual e as configurações de parciais/voltas pela
      fronteira de composição apropriada.
- [x] Garantir que alterações de configuração não mutem uma medição em
      andamento de forma inconsistente.
- [x] Usar `DateTime.now` e `Stopwatch.new` na composição de produção, sem
      registrar wrappers triviais no injector.

**Resultado esperado:** o núcleo temporal recebe toda configuração por
construtor e não depende de singletons globais.

### 7. Testar deterministicamente a máquina temporal

**Dependências:** tarefas 1 a 6.

- [x] Criar funções de data civil e uma implementação de `Stopwatch`
      controláveis nos testes; controlar o `Timer` com o tempo assíncrono do
      ambiente de teste.
- [x] Testar início, ticks visuais e duração obtida do elapsed monotônico.
- [x] Testar que atraso, ausência ou excesso de ticks não altera a duração
      medida.
- [x] Testar pausa e retomada sem contabilizar o período parado.
- [x] Testar reset para `idle` com duração, contadores e snapshot zerados.
- [x] Testar parcial como diferença desde o último marco de parcial.
- [x] Testar múltiplas parciais consecutivas e reinício do contador por volta.
- [x] Testar volta fechando parcial e volta no mesmo instante monotônico.
- [x] Testar múltiplas voltas com marcos independentes.
- [x] Testar encerramento durante execução e durante pausa.
- [x] Testar `FinishSnapshot`, horário civil final e estado `finished`.
- [x] Testar novo início depois de `finished` como medição limpa.
- [x] Testar conclusão automática ao alcançar o limite opcional de voltas.
- [x] Testar eventos inválidos e repetidos em todos os status relevantes.
- [x] Testar que eventos inválidos não acessam valores nulos nem lançam
      exceções.
- [x] Testar que o ticker é único e cancelado em pausa, reset, encerramento,
      limite de voltas e `close()`.
- [x] Testar que ticks tardios não emitem estado depois do cancelamento.
- [x] Testar em widget a adaptação do display e dos contadores ao novo estado e
      verificar barra de botões e controller legado pela suíte completa e pela
      análise estática.

**Resultado esperado:** o comportamento temporal alterado possui cobertura sem
esperas reais ou dependência do relógio da máquina.

### 8. Validar e documentar a entrega

**Dependência:** tarefas 1 a 7.

- [x] Executar `dart format` nos arquivos alterados.
- [x] Executar os testes focados do domínio temporal, BLoC e consumidores
      adaptados.
- [x] Executar a suíte completa com `flutter test`.
- [x] Executar `flutter analyze` sem novas issues.
- [x] Executar `git diff --check`.
- [x] Registrar que a validação manual de iniciar, pausar, retomar, resetar,
      registrar parcial, registrar volta e encerrar ficou delegada ao usuário;
      a consulta de dispositivos não foi autorizada nesta sessão.
- [x] Confirmar que múltiplos cronômetros legados continuam temporalmente
      independentes.
- [x] Registrar no backlog 008 as fronteiras temporárias mantidas no
      `PreciseStopwatchController` e nos managers de sessão.
- [x] Atualizar o acompanhamento do backlog 007 com o resultado da entrega.
- [x] Mover backlog e tasks concluídos para `doc/backlog/closed/`.

**Resultado esperado:** o novo núcleo temporal está integrado ao fluxo atual,
sem regressões conhecidas, e oferece uma fronteira estável para o backlog 008.

**Entregue em 2026-08-24:** o núcleo temporal, atualmente localizado em
`lib/ui/pages/stopwatch/bloc`, passou a usar uma instância de
`dart:core Stopwatch` como fonte exclusiva de duração. O estado imutável expõe
status, elapsed, contadores, datas civis, configuração e snapshots revisionados.
O ticker padrão de 50 ms apenas despacha atualizações internas e é cancelado em
pausa, reset, encerramento, limite de voltas e `close()`. Display, contadores,
barra de botões e controller legado foram adaptados ao novo estado sem
`ValueNotifier`s temporais paralelos ou esperas fixas. Testes determinísticos
cobrem ticks, pausa, retomada, reset, parciais, voltas, encerramentos, limite,
eventos inválidos, descarte e independência entre instâncias; teste de widget
comprova a reconstrução de display e contadores. Os 258 testes da suíte completa
passaram, `flutter analyze` terminou sem issues e `git diff --check` passou. A
validação exploratória em dispositivo ficou delegada ao usuário porque a
consulta de dispositivos não foi autorizada nesta sessão.

## Regra de conclusão

O backlog só pode ser encerrado quando `Stopwatch.elapsed` for a única fonte de
tempo decorrido em produção; o estado imutável do BLoC for a única fonte de
duração, contadores e snapshots; nenhum recurso temporal sobreviver ao
`close()`; eventos inválidos forem seguros; o BLoC não conhecer persistência ou
UI; e testes determinísticos, suíte completa, análise e verificação do diff
terminarem sem novos erros.
