# 008 — Sessões e múltiplos cronômetros

## Objetivo

Integrar o novo BLoC à arquitetura MVVM e representar vários cronômetros como
sessões de estado, eliminando widgets armazenados em controller global.

## Dependências

- [`006-treinos-e-historicos.md`](006-treinos-e-historicos.md),
  concluído;
- [`007-nucleo-cronometro-bloc.md`](007-nucleo-cronometro-bloc.md),
  concluído.

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

Todas as questões foram decididas antes da implementação.

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

- uma sessão iniciada continua ativa durante a navegação; abrir outra página,
  retornar à página principal ou reconstruir a Page não pausa nem encerra seu
  `Stopwatch`;
- somente uma ação temporal explícita ou o descarte confirmado da sessão altera
  o ciclo de vida da medição;
- cada escrita produzida por snapshot usa a identidade idempotente formada pelo
  treino persistido e por `snapshotRevision`;
- uma escrita que falhar permanece pendente e toda nova tentativa reutiliza a
  mesma identidade e o mesmo conteúdo; encontrar essa identidade já persistida
  equivale a sucesso, sem criar outra parcial;
- remover uma sessão em execução ou pausada exige confirmação; ao confirmar, a
  sessão encerra a medição, persiste os registros finais e só é removida depois
  do sucesso da persistência;
- cancelar a confirmação preserva a sessão, e uma falha de persistência impede
  sua remoção e mantém a escrita pendente para nova tentativa;
- sessões `idle`, ou `finished` sem escrita pendente, podem ser removidas
  diretamente; eventual descarte sem salvar deverá ser uma ação separada e
  explícita, não um efeito implícito da remoção;
- mensagens pertencem à sessão do atleta e carregam identidade e ordem
  estáveis; uma lista global, quando exibida, é somente uma projeção cronológica
  das mensagens das sessões existentes.

## Acompanhamento

**Estado:** Implementação e validações automatizadas concluídas. A validação
manual foi delegada ao mantenedor e será executada posteriormente; por isso, os
documentos permanecem em `doc/backlog/` até o aceite manual. A execução está
registrada em
[`008-sessoes-multiplos-cronometros-tasks.md`](008-sessoes-multiplos-cronometros-tasks.md).

**Entrega automatizada:** `PreciseStopwatchController`,
`StopwatchPageController`, `TrainingManager` e `HistoryManager` foram removidos,
assim como seus registros no injector. O fluxo de sessão usa domínio,
`StopwatchSessionViewModel` e `StopwatchPageViewModel`. Os adapters legados foram
preservados somente porque relatórios, PDF, compartilhamento e funções de
compatibilidade ainda possuem consumidores comprovados fora do fluxo de
sessão. A suíte completa terminou com 286 testes aprovados; `flutter analyze` e
`git diff --check` terminaram sem apontamentos.

**Pendente:** validação manual de múltiplos cronômetros, navegação durante uma
medição ativa, falha e repetição de escrita e todos os caminhos de remoção.

**Próximo backlog:** `009-relatorios-e-compartilhamento.md`.
