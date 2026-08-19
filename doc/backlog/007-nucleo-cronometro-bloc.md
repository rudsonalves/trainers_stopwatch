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

## Questões em aberto

1. Qual frequência visual padrão substituirá os atuais 66 ms?
2. Um evento de volta também gera snapshot de parcial como no comportamento
   atual?
3. O encerramento será permitido enquanto executando e enquanto pausado?
4. Qual estado será emitido depois do reset e depois do encerramento?

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

## Acompanhamento

**Estado:** Planejado.

**Próximo backlog:** `008-sessoes-multiplos-cronometros.md`.
