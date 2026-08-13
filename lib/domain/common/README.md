# Domain common

Este diretório contém conceitos e regras estáveis do Trainer's Stopwatch.

## Dependências permitidas

O domínio pode importar somente:

- bibliotecas de Dart;
- `lib/core/result` para representar operações que podem falhar;
- outros tipos do próprio domínio.

O domínio não pode importar Flutter, SQLite, plugins, repositories, Viewmodels,
widgets, navegação, localização ou detalhes de persistência.

## Organização

Contextos como `user`, `training`, `history`, `settings` e `stopwatch` devem ser criados apenas quando o primeiro tipo concreto de cada contexto for implementado. Não devem existir arquivos agregadores ou abstrações vazias apenas para reproduzir a árvore planejada.
