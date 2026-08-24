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
- data civil é obtida por um contrato `Clock` e não participa do cálculo da
  duração;
- persistência, coordenação de sessões e tratamento de falhas de escrita
  permanecem no backlog 008.

## Ordem de execução

### 1. Definir contratos temporais e recursos injetáveis

**Dependências:** backlogs 002, 003 e 006 concluídos.

- [ ] Criar o contrato `Clock` para fornecer exclusivamente a data civil.
- [ ] Criar a implementação de produção do `Clock` baseada em `DateTime.now`.
- [ ] Definir uma fábrica injetável de `Stopwatch` cuja implementação de
      produção devolva uma instância de `dart:core Stopwatch`.
- [ ] Permitir uma implementação controlável dessa fábrica nos testes sem
      alterar a fonte monotônica usada em produção.
- [ ] Definir uma abstração mínima para criar e cancelar o ticker visual.
- [ ] Adotar 50 ms como intervalo padrão e permitir sua injeção em testes.
- [ ] Manter `Timer`, quando usado pela implementação do ticker, restrito ao
      pedido de atualização visual.
- [ ] Não colocar dependências de Flutter, settings, banco ou tradução nos
      contratos temporais.

**Resultado esperado:** duração monotônica, data civil e solicitação de render
possuem responsabilidades distintas e podem ser testadas deterministicamente.

### 2. Modelar eventos, status e estado imutável

**Dependência:** tarefa 1.

- [ ] Substituir as classes de estado vazias por um estado imutável com status,
      duração, contadores e resultado temporal mais recente.
- [ ] Representar explicitamente os status `idle`, `running`, `paused` e
      `finished`.
- [ ] Incluir no estado os horários civis necessários de início e encerramento,
      sem usá-los para calcular duração.
- [ ] Representar o limite opcional de voltas como configuração validada da
      medição, sem campo público livremente mutável durante a execução.
- [ ] Expor `SplitSnapshot`, `LapSnapshot` ou `FinishSnapshot` no estado quando
      uma ação produzir um novo marco.
- [ ] Associar ao snapshot uma revisão monotônica para que consumidores possam
      distinguir uma nova ação dos ticks visuais subsequentes.
- [ ] Garantir igualdade por valor e `copyWith` ou construção equivalente sem
      mutação interna observável.
- [ ] Representar iniciar, pausar, retomar, resetar, parcial, volta e encerrar
      como eventos explícitos.
- [ ] Criar um evento interno de tick que não faça parte da API de interação da
      UI.
- [ ] Eliminar `StopwatchStateReset`; reset deve ser uma transição para
      `idle`.
- [ ] Definir eventos inválidos como operações sem efeito, sem emitir estado de
      erro para transições normais rejeitadas.

**Resultado esperado:** um único estado descreve integralmente a máquina
temporal e permite identificar cada snapshot produzido.

### 3. Implementar a máquina temporal no BLoC

**Dependências:** tarefas 1 e 2.

- [ ] Injetar `Clock`, fábrica de `Stopwatch`, fábrica de ticker, intervalo
      visual e limite opcional de voltas pelo construtor.
- [ ] Ao iniciar em `idle` ou `finished`, zerar a medição anterior, capturar a
      data civil inicial, iniciar o `Stopwatch` e ativar o ticker.
- [ ] Ao pausar em `running`, parar o `Stopwatch`, cancelar o ticker e emitir a
      duração congelada.
- [ ] Ao retomar em `paused`, reiniciar a mesma instância de `Stopwatch` e
      reativar o ticker sem contar o período parado.
- [ ] Em cada tick válido, consultar somente `Stopwatch.elapsed` e atualizar a
      duração visual sem alterar contadores ou snapshots.
- [ ] Ao registrar parcial em `running`, calcular a diferença entre o elapsed
      atual e o último marco de parcial.
- [ ] Ao registrar volta em `running`, calcular no mesmo elapsed as diferenças
      desde os últimos marcos de parcial e volta.
- [ ] Incrementar os contadores de parcial e volta de forma atômica com a
      criação do snapshot correspondente.
- [ ] Preservar a regra atual de reinício do contador de parciais por volta com
      base na quantidade configurada de parciais por volta.
- [ ] Ao atingir o limite opcional de voltas, concluir automaticamente a
      medição com os mesmos dados da volta final e emitir `finished`.
- [ ] Ao encerrar em `running`, parar o `Stopwatch`, cancelar o ticker e fechar
      os segmentos finais de parcial e volta.
- [ ] Ao encerrar em `paused`, manter o elapsed congelado e fechar os segmentos
      finais sem incluir o período pausado.
- [ ] Produzir `FinishSnapshot` com as durações finais, contadores atualizados e
      horário civil de encerramento.
- [ ] Ao resetar nos estados permitidos, parar e zerar o `Stopwatch`, cancelar o
      ticker e emitir `idle` sem snapshot anterior.
- [ ] Ignorar com segurança eventos incompatíveis com o status atual.
- [ ] Remover do BLoC acessos a `AppSettings`, `ValueNotifier`, cores, usuário,
      tradução, widgets, ViewModels e persistência.

**Resultado esperado:** toda duração e todo segmento derivam exclusivamente de
snapshots de `Stopwatch.elapsed`, com transições válidas e previsíveis.

### 4. Garantir ciclo de vida e concorrência dos eventos

**Dependência:** tarefa 3.

- [ ] Fazer o ticker despachar eventos internos em vez de emitir estado fora de
      um handler do BLoC.
- [ ] Impedir a criação de mais de um ticker para a mesma medição.
- [ ] Descartar ticks enfileirados depois de pausa, reset, encerramento ou
      fechamento do BLoC.
- [ ] Cancelar o ticker ao atingir o limite de voltas.
- [ ] Sobrescrever `close()` para cancelar o ticker e liberar seus recursos
      antes de fechar o BLoC.
- [ ] Tornar chamadas repetidas de pausa, reset, encerramento e fechamento
      seguras e idempotentes quando aplicável.
- [ ] Remover o método `dispose()` próprio do BLoC e padronizar consumidores em
      `close()`.

**Resultado esperado:** nenhum ticker sobrevive à medição ou ao BLoC, e eventos
atrasados não restauram estados antigos.

### 5. Adaptar minimamente os consumidores legados

**Dependências:** tarefas 2 a 4.

- [ ] Fazer o display observar `StopwatchState.elapsed` pelo stream do BLoC.
- [ ] Fazer os contadores observarem somente os campos do estado do BLoC.
- [ ] Atualizar a barra de botões para os status `idle`, `running`, `paused` e
      `finished`.
- [ ] Usar o evento explícito de retomada no botão correspondente.
- [ ] Adaptar `PreciseStopwatchController` para obter início, duração,
      contadores e snapshots exclusivamente do estado emitido.
- [ ] Remover esperas fixas de 100 ms usadas apenas para aguardar o
      processamento de eventos, substituindo-as por observação do estado ou
      coordenação determinística equivalente.
- [ ] Fazer o controller legado consumir uma única vez cada revisão de
      snapshot ao gerar os registros temporários atuais.
- [ ] Manter persistência, mensagens, usuário, cores e tradução fora do BLoC e
      no adapter legado existente até o backlog 008.
- [ ] Preservar o layout e os gestos atuais, inclusive reset e encerramento por
      toque longo.
- [ ] Não introduzir `StopwatchSessionViewModel`, múltiplas sessões novas ou a
      migração dos managers reservada ao backlog 008.

**Resultado esperado:** a aplicação atual continua funcional sem
`ValueNotifier`s paralelos ao estado temporal e sem antecipar a arquitetura de
sessões.

### 6. Atualizar composição e remover dependências temporais legadas

**Dependência:** tarefa 5.

- [ ] Atualizar a criação do BLoC para receber os contratos temporais e as
      configurações necessárias.
- [ ] Manter o BLoC com ciclo de vida independente por cronômetro existente.
- [ ] Remover do BLoC a leitura direta de
      `AppSettings.instance.mSecondRefresh`.
- [ ] Transferir o intervalo visual e as configurações de parciais/voltas pela
      fronteira de composição apropriada.
- [ ] Garantir que alterações de configuração não mutem uma medição em
      andamento de forma inconsistente.
- [ ] Confirmar que somente o composition root conhece implementações concretas
      dos contratos temporais quando houver registro no injector.

**Resultado esperado:** o núcleo temporal recebe toda configuração por
construtor e não depende de singletons globais.

### 7. Testar deterministicamente a máquina temporal

**Dependências:** tarefas 1 a 6.

- [ ] Criar fakes controláveis de `Clock`, `Stopwatch` e ticker.
- [ ] Testar início, ticks visuais e duração obtida do elapsed monotônico.
- [ ] Testar que atraso, ausência ou excesso de ticks não altera a duração
      medida.
- [ ] Testar pausa e retomada sem contabilizar o período parado.
- [ ] Testar reset para `idle` com duração, contadores e snapshot zerados.
- [ ] Testar parcial como diferença desde o último marco de parcial.
- [ ] Testar múltiplas parciais consecutivas e reinício do contador por volta.
- [ ] Testar volta fechando parcial e volta no mesmo instante monotônico.
- [ ] Testar múltiplas voltas com marcos independentes.
- [ ] Testar encerramento durante execução e durante pausa.
- [ ] Testar `FinishSnapshot`, horário civil final e estado `finished`.
- [ ] Testar novo início depois de `finished` como medição limpa.
- [ ] Testar conclusão automática ao alcançar o limite opcional de voltas.
- [ ] Testar eventos inválidos e repetidos em todos os status relevantes.
- [ ] Testar que eventos inválidos não acessam valores nulos nem lançam
      exceções.
- [ ] Testar que o ticker é único e cancelado em pausa, reset, encerramento,
      limite de voltas e `close()`.
- [ ] Testar que ticks tardios não emitem estado depois do cancelamento.
- [ ] Testar a adaptação mínima do display, contadores, botões e controller
      legado ao novo estado.

**Resultado esperado:** o comportamento temporal alterado possui cobertura sem
esperas reais ou dependência do relógio da máquina.

### 8. Validar e documentar a entrega

**Dependência:** tarefas 1 a 7.

- [ ] Executar `dart format` nos arquivos alterados.
- [ ] Executar os testes focados do domínio temporal, BLoC e consumidores
      adaptados.
- [ ] Executar a suíte completa com `flutter test`.
- [ ] Executar `flutter analyze` sem novas issues.
- [ ] Executar `git diff --check`.
- [ ] Validar manualmente iniciar, pausar, retomar, resetar, registrar parcial,
      registrar volta e encerrar nos fluxos existentes quando houver ambiente
      disponível.
- [ ] Confirmar que múltiplos cronômetros legados continuam temporalmente
      independentes.
- [ ] Registrar no backlog 008 as fronteiras temporárias mantidas no
      `PreciseStopwatchController` e nos managers de sessão.
- [ ] Atualizar o acompanhamento do backlog 007 com o resultado da entrega.
- [ ] Mover backlog e tasks concluídos para `doc/backlog/closed/`.

**Resultado esperado:** o novo núcleo temporal está integrado ao fluxo atual,
sem regressões conhecidas, e oferece uma fronteira estável para o backlog 008.

## Regra de conclusão

O backlog só pode ser encerrado quando `Stopwatch.elapsed` for a única fonte de
tempo decorrido em produção; o estado imutável do BLoC for a única fonte de
duração, contadores e snapshots; nenhum recurso temporal sobreviver ao
`close()`; eventos inválidos forem seguros; o BLoC não conhecer persistência ou
UI; e testes determinísticos, suíte completa, análise e verificação do diff
terminarem sem novos erros.
