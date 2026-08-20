# 008 — Sessões e múltiplos cronômetros

## Objetivo

Integrar o novo BLoC à arquitetura MVVM e representar vários cronômetros como
sessões de estado, eliminando widgets armazenados em controller global.

## Dependências

- [`006-treinos-e-historicos.md`](closed/006-treinos-e-historicos.md),
  concluído;
- `007-nucleo-cronometro-bloc.md`.

## Escopo

- criar `StopwatchPageViewModel` para seleção e ciclo de vida das sessões;
- criar um `StopwatchSessionViewModel` por atleta;
- compor cada sessão com seu `StopwatchBloc` e dependências injetadas;
- substituir a lista de `PreciseStopwatch` por models/ViewModels de sessão;
- construir widgets na Page a partir de IDs/chaves estáveis;
- coordenar criação do treino antes do primeiro início;
- capturar snapshots e persistir parcial, volta e encerramento;
- substituir `TrainingManager` e `HistoryManager` por dependências de sessão
  orientadas a domínio e remover seus registros do composition root;
- remover do fluxo temporal os adapters legados de `UserModel`,
  `TrainingModel` e `HistoryModel`, incluindo a conversão de treino feita na
  rota de treino pessoal;
- definir tratamento recuperável para falha de persistência durante medição;
- substituir o canal global de mensagens por estado de apresentação explícito;
- garantir descarte independente de BLoC, ticker e Commands por atleta;
- manter sessões temporalmente independentes.

## Fora de escopo

- alterar o domínio de cálculo;
- gerar PDF;
- migrar para Navigator 2.0;
- guardar widgets ou `BuildContext` nos ViewModels.

## Questões em aberto

1. A sessão iniciada deve continuar ativa ao navegar para outra página?
2. Como reapresentar uma escrita de parcial que falhou sem duplicá-la?
3. Remover um cronômetro ativo exige confirmação e encerramento do treino?
4. Mensagens da sessão serão uma lista global ou agrupadas por atleta?

## Critérios de aceite

- nenhum controller/ViewModel armazena widgets;
- cada atleta possui BLoC e ciclo de vida independentes;
- remover uma sessão descarta somente seus recursos;
- falha de persistência não apaga o tempo medido;
- parciais não são duplicadas em nova tentativa;
- múltiplos cronômetros mantêm o comportamento funcional atual;
- managers e adapters legados de sessão não possuem consumidores restantes;
- navegação continua sob responsabilidade das Pages;
- testes acompanham coordenação, independência e descarte modificados;
- análise termina sem novos erros.

## Decisões

Nenhuma decisão adicional aprovada.

## Acompanhamento

**Estado:** Planejado.

**Próximo backlog:** `009-relatorios-e-compartilhamento.md`.
