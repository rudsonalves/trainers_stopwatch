# Data

Esta camada contém a persistência local e a coordenação dos dados do Trainer's
Stopwatch.

## Direção das dependências

```text
Viewmodel/UseCase
  -> Repository
    -> Data Service
      -> Database
```

- Viewmodels e UseCases consomem contratos de repository;
- repositories coordenam data services e mantêm caches de dados;
- data services executam CRUD e convertem registros de persistência;
- o serviço de banco controla abertura, configuração, schema, backup e
  fechamento da conexão.

Uma camada inferior não busca nem instancia sua dependência. Todas as
dependências são recebidas por construtor e compostas em
`lib/core/config/dependencies.dart`.

## Dependências permitidas

`data` pode depender de:

- bibliotecas de Dart;
- `core`, incluindo `Result` e `AppError`;
- models e regras de `domain`;
- serviços e mappers da própria camada;
- plugins de persistência apenas dentro de `data/services`.

`data` não pode depender de widgets, páginas, Viewmodels, `BuildContext`,
navegação, localização ou estado visual.

Durante o backlog 003, `lib/store` e `lib/repositories` permanecem como legado
temporário e ainda podem importar SQLite ou detalhes de persistência. Nenhuma
implementação nova deve ampliar essas exceções. As tasks 4 a 10 movem os
consumidores, e a task 11 verifica e remove as fronteiras antigas.

## Organização incremental

Os contextos `database`, `settings`, `users`, `trainings` e `histories` devem
ser criados em `services` e `repositories` somente quando receberem a primeira
implementação concreta. Não devem existir arquivos agregadores, contratos
vazios, DAOs ou wrappers que apenas reproduzam a API do SQLite.
