# Repositories

Repositories são a fronteira de dados consumida por Viewmodels e UseCases.

## Responsabilidades

- receber data services por parâmetros nomeados e obrigatórios no construtor;
- expor operações orientadas ao domínio usando `Result` ou `AsyncResult`;
- manter caches de dados pequenos e explícitos;
- atualizar o cache somente depois de uma operação persistente bem-sucedida;
- expor coleções não modificáveis ou snapshots imutáveis;
- esconder SQLite, SQL, maps, nomes de tabelas e detalhes de armazenamento.

Repositories não acessam o `AutoInjector`, não criam services e não mantêm
loading, seleção de tela, mensagens, controllers, navegação ou qualquer outro
estado visual.

## Organização

Cada contexto terá contrato e implementação separados quando houver uma razão
concreta para substituição ou injeção:

```text
repositories/<contexto>/<contexto>_repository.dart
repositories/<contexto>/<contexto>_repository_impl.dart
```

Não serão criados contratos, implementações ou arquivos agregadores antes de
existir um consumidor real.
