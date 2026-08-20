# 006 — Treinos e históricos

## Objetivo

Migrar consulta, edição e exclusão de treinos e históricos para MVVM, usando o
domínio e os repositories novos.

As tarefas planejadas estão registradas em
[`006-treinos-e-historicos-tasks.md`](006-treinos-e-historicos-tasks.md).

## Dependências

- `002-dominio-puro.md`;
- [`003-persistencia-e-repositories.md`](003-persistencia-e-repositories.md), concluído;
- [`005-usuarios-e-imagens.md`](005-usuarios-e-imagens.md), concluído.

## Escopo

- criar `TrainingsViewModel` e `HistoryViewModel`;
- expor Commands para carregar, atualizar, excluir e selecionar registros;
- substituir `TrainingManager`, `HistoryManager` e `HistoryController` nos fluxos
  migrados;
- manter caches de dados no repository somente quando houver necessidade real;
- operar sobre models de domínio, sem maps SQLite;
- usar a nova regra de parcial/volta do domínio;
- introduzir UseCase para operações que coordenem treino e históricos;
- manter rotas nomeadas e argumentos tipados no `go_router`;
- preservar exclusão em cascata e edição de comentários.

## Fora de escopo

- reescrever o BLoC temporal;
- implementar compartilhamento/PDF;
- redesenhar páginas;
- criar um UseCase para cada método simples de repository.

## Questões em aberto

Nenhuma questão permanece aberta nesta etapa.

## Critérios de aceite

- páginas não acessam managers, stores ou repositories concretos;
- ViewModels recebem dependências por construtor;
- histórico de volta continua derivado de parciais de forma previsível;
- exclusões mantêm integridade entre usuário, treino e histórico;
- argumentos de rota são tipados quando carregam entidades relacionadas;
- edição e seleção mantêm o comportamento atual;
- testes acompanham regras e coordenações modificadas;
- análise termina sem novos erros.

## Decisões

### 2026-08-20 — Roteamento declarativo com go_router

**Decisão:** substituir a tabela do Navigator 1.0 por `go_router`, seguindo a
organização de `go-list2/mobile/lib/core/routing`.

**Motivo:** centralizar nomes, paths, transições, observação e contratos de
argumentos antes da migração das páginas de treinos e históricos.

**Consequências:**

- `MaterialApp.router` recebe uma única configuração de `GoRouter`;
- Pages continuam decidindo quando navegar e ViewModels permanecem sem
  `BuildContext`;
- argumentos de treino pessoal e histórico usam classes próprias em vez de
  maps dinâmicos;
- `Navigator.pop` permanece nos fluxos modais de dialogs e drawer.

### 2026-08-20 — Exclusão de treino por cascata

**Decisão:** a exclusão dos históricos relacionados a um treino será delegada
à cascata já garantida pela persistência.

**Motivo:** a integridade referencial já pertence à fronteira de persistência e
não exige um UseCase que apenas repita a remoção de cada histórico.

**Consequências:**

- o consumidor solicita somente a exclusão do treino;
- repository e testes de integração devem comprovar a remoção dos históricos;
- não será criado UseCase apenas para reproduzir a cascata.

### 2026-08-20 — Persistência dos eventos fundamentais

**Decisão:** persistir os eventos fundamentais e derivar os demais no domínio.

**Motivo:** armazenar simultaneamente parciais e voltas duplica informação e
permite que duas representações do mesmo evento se tornem inconsistentes.

**Consequências:**

- o marco inicial e as parciais formam a fonte persistida;
- cada parcial persiste a duração do seu segmento;
- cada volta é derivada pela soma das parciais que compõem seu ciclo;
- regras de apresentação não recalculam voltas por conta própria;
- testes de domínio cobrem ordem, primeira volta e sequências inválidas.

### 2026-08-20 — Seleção múltipla como estado da UI

**Decisão:** a seleção múltipla de treinos será estado transitório da camada de
UI, mantido pelo ViewModel ou model de página da feature.

**Motivo:** a seleção representa uma interação visual durante o ciclo de vida
da página e não altera a identidade nem a persistência dos treinos.

**Consequências:**

- domínio e repositories não armazenam seleção;
- a UI expõe a seleção como coleção não modificável;
- troca de usuário, recarga e exclusão reconciliam IDs selecionados com os
  treinos disponíveis.

## Acompanhamento

**Estado:** Concluído em 2026-08-20.

**Próximos backlogs:** [`007-nucleo-cronometro-bloc.md`](../007-nucleo-cronometro-bloc.md),
[`008-sessoes-multiplos-cronometros.md`](../008-sessoes-multiplos-cronometros.md)
e [`009-relatorios-e-compartilhamento.md`](../009-relatorios-e-compartilhamento.md).
