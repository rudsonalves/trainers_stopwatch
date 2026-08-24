# 007 — Núcleo temporal do cronômetro com BLoC

## Objetivo

Reimplementar a máquina temporal do cronômetro com BLoC e `dart:core Stopwatch`,
separando tempo decorrido, persistência e apresentação.

## Dependências

- `002-dominio-puro.md`;
- contratos de persistência de
  [`003-persistencia-e-repositories.md`](closed/003-persistencia-e-repositories.md),
  concluído.

## Escopo

- manter eventos de iniciar, pausar, retomar, resetar, parcial, volta e encerrar;
- usar uma instância de `Stopwatch` como fonte monotônica de duração;
- manter ticker apenas para solicitar atualizações visuais;
- representar marcos de parcial e volta por `Duration`;
- separar data civil por um contrato `Clock`;
- emitir um estado imutável com status, duração e contadores;
- remover `ValueNotifier`s paralelos do BLoC;
- impedir estados inválidos sem depender da habilitação dos botões;
- manter limite opcional de voltas;
- não acessar banco, tradução, usuário, cor, widgets ou ViewModel no BLoC;
- garantir cancelamento do ticker no fechamento.

## Fora de escopo

- persistir treino dentro do BLoC;
- migrar múltiplos cronômetros;
- redesenhar botões e display;
- usar Timer como fonte de duração.

## Critérios de aceite

- `Stopwatch.elapsed` é a única fonte de tempo decorrido;
- pausa e retomada não contam o período parado;
- parcial e volta usam diferenças entre snapshots monotônicos;
- o estado do BLoC é a única fonte para tempo e contadores;
- eventos inválidos não causam exceções por valores nulos;
- o BLoC não conhece persistência ou UI;
- comportamento temporal alterado é protegido por testes determinísticos;
- ticker e recursos são descartados corretamente;
- análise termina sem novos erros.

## Decisões

### 2026-08-13 — `dart:core Stopwatch` como fonte temporal

**Decisão:** o BLoC usará `Stopwatch` para tempo decorrido.

**Motivo:** ele já trata pausa e retomada monotonicamente e elimina ajustes
manuais com vários `DateTime`.

**Consequências:** `DateTime` fica restrito à data civil; o ticker atualiza a
tela, mas não mede o tempo.

### 2026-08-24 — Ticker visual padrão de 50 ms

**Decisão:** o ticker solicitará atualizações visuais a cada 50 ms por padrão.

**Motivo:** o intervalo acompanha adequadamente a apresentação em centésimos de
segundo sem transformar o ticker em fonte de duração.

**Consequências:** cada atualização consultará `Stopwatch.elapsed`; atrasos ou
perdas de ticks não alterarão o tempo medido.

### 2026-08-24 — Volta também fecha a parcial corrente

**Decisão:** registrar uma volta também gerará o snapshot da parcial corrente,
preservando o comportamento existente.

**Motivo:** volta e parcial são fechadas no mesmo instante monotônico, e o
`LapSnapshot` já representa ambas as durações.

**Consequências:** o evento de volta atualizará os contadores de volta e parcial
e produzirá um `LapSnapshot` com `lapDuration` e `splitDuration`.

### 2026-08-24 — Encerramento durante execução ou pausa

**Decisão:** o encerramento será permitido enquanto o cronômetro estiver em
execução ou pausado.

**Motivo:** a validade da transição não deve depender da habilitação dos botões,
e ambos os estados possuem duração monotônica bem definida.

**Consequências:** em execução, o cronômetro será parado e usará a duração do
instante do evento; em pausa, manterá a duração já congelada, sem contabilizar o
período pausado. Nos dois casos, o encerramento fechará os segmentos finais de
parcial e volta. Nos demais estados, o evento será ignorado.

### 2026-08-24 — Estados após reset e encerramento

**Decisão:** o reset retornará o cronômetro ao estado `idle`, enquanto o
encerramento emitirá o estado `finished`.

**Motivo:** reset é uma transição para uma nova medição, não uma condição
temporal própria. O estado `finished` distingue uma medição concluída de outra
que ainda não começou e mantém seu resultado disponível para os consumidores.

**Consequências:** `idle` terá duração e contadores zerados e não manterá
snapshots da medição anterior. `finished` preservará a duração final, os
contadores e o `FinishSnapshot`. Um novo início depois de `finished` criará uma
medição limpa.

## Acompanhamento

**Estado:** Planejado.

**Plano de execução:**
[`007-nucleo-cronometro-bloc-tasks.md`](007-nucleo-cronometro-bloc-tasks.md).

**Próximo backlog:** `008-sessoes-multiplos-cronometros.md`.
