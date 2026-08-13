# 002 — Domínio puro

## Objetivo

Isolar conceitos e regras estáveis do Trainer's Stopwatch em Dart puro, sem
dependências de Flutter, SQLite, plugins ou apresentação.

As tarefas de implementação estão organizadas em
[`002-dominio-puro-tasks.md`](002-dominio-puro-tasks.md).

## Dependência

Depende de
[`closed/001-fundacao-arquitetural.md`](closed/001-fundacao-arquitetural.md)
para os contratos transversais.

## Escopo

- organizar `lib/domain/common` por usuário, treino, histórico, configurações e
  cronômetro;
- definir models de domínio pequenos, explícitos e preferencialmente imutáveis;
- retirar `Color`, `ValueNotifier` e detalhes SQLite dos conceitos de domínio;
- transformar unidades de distância e velocidade em enums ou value objects;
- migrar cálculos de velocidade e formatação independente de localização;
- migrar a regra que deriva parciais e voltas do histórico;
- definir snapshots temporais imutáveis para parcial, volta e encerramento;
- manter conversões para tradução e apresentação fora do domínio;
- criar UseCases apenas quando uma coordenação real for identificada.

## Fora de escopo

- mudar banco ou migrations;
- reescrever o `StopwatchBloc`;
- migrar páginas;
- criar DTOs idênticos aos models apenas por simetria.

## Questões em aberto

Nenhuma questão permanece aberta nesta etapa. As decisões de domínio estão
registradas abaixo.

## Critérios de aceite

- models de domínio não importam Flutter nem `sqflite`;
- unidades deixam de depender de strings espalhadas;
- regras de velocidade, parcial e volta possuem uma única implementação;
- tradução e cores não fazem parte das regras de domínio;
- adapters temporários mantêm consumidores antigos funcionando;
- testes são adicionados somente às regras alteradas e seus limites relevantes;
- análise termina sem novos erros.

## Decisões

### 2026-08-13 — Cor como estado visual transitório

**Decisão:** a cor usada no cronômetro e nas mensagens pertence à apresentação
da sessão ativa. Ela não será parte do modelo de domínio nem persistida no
banco.

**Motivo:** a cor serve para diferenciar visualmente cronômetros e mensagens
durante o uso. Ela não participa das regras de treino, duração, distância,
velocidade, parcial ou volta. O comportamento atual também não inclui a cor em
`TrainingModel.toMap()` nem no schema SQLite.

**Consequências:**

- models de domínio não importam `Color` ou Flutter;
- nenhuma migration será criada para armazenar cor;
- a UI ou o `StopwatchSessionViewmodel` controla a seleção e reutilização da cor
  durante a sessão;
- mensagens de apresentação podem carregar a cor enquanto estiverem em memória;
- ao carregar um treino histórico, a interface usa as cores do tema ou o padrão
  visual vigente;
- se surgir necessidade funcional de identificação persistente por cor, ela
  exigirá backlog próprio e será armazenada como valor neutro, convertido em
  `Color` somente na UI.

### 2026-08-13 — Proteção explícita contra duração zero

**Decisão:** o cálculo de velocidade deve rejeitar duração igual a zero com o
código específico `AppErrorCode.zeroElapsedTime`.

**Motivo:** o fluxo normal registra parcial ou volta depois que o cronômetro já
avançou, portanto duração zero não é um estado esperado da operação. O registro
inicial do treino possui duração zero, mas representa apenas o início da sessão
e não deve solicitar cálculo de velocidade. Ainda assim, chamadas muito próximas,
resolução temporal ou uso futuro da função podem fornecer zero; dividir por zero
produziria um resultado infinito e propagaria um valor inválido silenciosamente.

**Consequências:**

- `AppErrorCode` receberá `zeroElapsedTime` neste backlog;
- a operação verificará a duração antes da divisão;
- duração zero não será convertida em velocidade zero;
- o histórico inicial continuará aceitando `Duration.zero`, pois não é uma
  medição de deslocamento;
- o chamador deverá tratar a falha sem persistir velocidade infinita;
- distância inválida continuará sujeita à validação própria do domínio, sem ser
  confundida com duração zero.

### 2026-08-13 — Sistema métrico como padrão

**Decisão:** novos valores de domínio usarão metro (`m`) como unidade padrão de
distância e metros por segundo (`m/s`) como unidade padrão de velocidade.

**Motivo:** o sistema métrico já é o padrão dos models e configurações atuais e
oferece uma base coerente para os cálculos internos.

**Consequências:**

- cálculos internos normalizarão distância para metros e tempo para segundos;
- apresentação poderá converter o resultado para a unidade selecionada;
- quilômetros por hora (`km/h`), jardas, milhas, jardas por segundo e milhas por
  hora continuarão suportados;
- a migração não alterará preferências já persistidas pelo usuário;
- ausência de unidade em um novo valor usará `m` e `m/s`;
- enums substituirão as strings dispersas nas novas fronteiras de domínio.

### 2026-08-13 — Matriz atual de unidades preservada

**Decisão:** a reestruturação manterá inicialmente as combinações aceitas hoje:

| Distância | Velocidades permitidas |
| --- | --- |
| `m` | `m/s`, `km/h` |
| `km` | `m/s`, `km/h` |
| `yd` | `yd/s`, `m/s`, `mph` |
| `mi` | `yd/s`, `m/s`, `mph` |

**Motivo:** restringir ou ampliar combinações durante a extração do domínio
misturaria reorganização arquitetural com mudança funcional.

**Consequências:** os enums e validadores representarão essa matriz; qualquer
revisão posterior terá backlog funcional próprio.

### 2026-08-13 — Relatório de domínio neutro

**Decisão:** o domínio produzirá eventos estruturados de início, parcial e
volta, sem mensagens prontas ou tradução.

**Motivo:** identificação, duração, velocidade e ordem são regras reutilizáveis;
labels, cores, ícones, localização e formatação pertencem à apresentação ou ao
renderer do relatório.

**Consequências:**

- o domínio não dependerá de `easy_localization`, `Color` ou widgets;
- eventos carregarão tipo, índice, duração, velocidade e comentários;
- a UI transformará eventos em mensagens localizadas;
- o renderer PDF transformará os mesmos eventos em linhas próprias;
- cálculos não serão duplicados entre tela e exportação.

## Acompanhamento

**Estado:** Concluído em 2026-08-13.

**Dependência:** backlog 001 concluído.

**Próximo backlog:** `003-persistencia-e-repositories.md`.

### Entrega

- domínio Dart puro criado para usuários, treinos, históricos, configurações,
  unidades, valores, snapshots e eventos temporais;
- cálculo tipado de velocidade protegido contra duração zero;
- geração neutra de eventos de início, parcial e volta, com duração acumulada
  correta para a volta;
- adapters conectados aos models, ao cálculo e ao relatório legados;
- formatação e localização mantidas fora do domínio;
- arquitetura atualizada com as fronteiras efetivamente entregues.

### Validação

- `dart format` executado nos arquivos alterados;
- 119 testes aprovados na suíte completa de `flutter test`, incluindo unidades,
  valores, velocidade, eventos e adapters;
- `flutter analyze` concluído sem issues;
- `git diff --check` concluído sem erros;
- bootstrap confirmado no emulador Android, com a tela principal carregada;
- parcial e volta confirmadas pelo teste integrado do adapter legado. A
  interação manual completa no emulador não foi concluída porque a permissão de
  captura/interação do ambiente foi interrompida durante a validação.

### Limitações e trabalho adiado

- adapters entre os models legados e o domínio permanecem temporariamente até
  os backlogs 003 a 006 migrarem persistência e consumidores;
- `TrainingReport` ainda converte eventos neutros para `MessagesModel` e textos
  localizados na borda legada;
- `StopwatchFunctions` permanece como fachada compatível sobre o novo cálculo;
- a formatação histórica de duração acima de uma hora foi preservada para não
  introduzir mudança visual neste backlog e deverá ser revista na consolidação
  da apresentação;
- schema, migrations e persistência de cor não foram alterados, conforme o
  escopo e as decisões desta etapa.
