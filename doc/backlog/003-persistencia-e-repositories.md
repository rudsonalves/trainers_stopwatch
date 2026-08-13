# 003 — Persistência e repositories

## Objetivo

Reorganizar o acesso local a dados para que repositories escondam SQLite e
sejam consumidos por contratos injetáveis, preservando o banco existente.

## Dependências

- `001-fundacao-arquitetural.md`;
- `002-dominio-puro.md`.

## Organização proposta

```text
ViewModel/UseCase
  -> Repository
    -> Local Service/DAO
      -> Database
```

## Escopo

- mover abertura, configuração e ciclo de vida do banco para serviço de dados;
- transformar stores em DAOs injetáveis;
- definir repositories orientados ao domínio para settings, users, trainings e
  histories;
- converter registros SQLite somente dentro de `data`;
- devolver falhas esperadas como `Result`/`AppError`;
- revisar a responsabilidade atual dos managers e realocar cache conforme o
  tipo de estado;
- encapsular schema, migrations, transações, backup e restauração;
- preservar nomes de tabelas, colunas, chaves e dados existentes;
- criar adapters temporários para features ainda não migradas.

## Fora de escopo

- redesenhar o schema sem necessidade funcional;
- apagar ou recriar automaticamente o banco do usuário;
- migrar UI;
- manter cache visual em repositories.

## Questões em aberto

1. O serviço de banco será um contrato próprio ou `sqflite.Database` será
   injetado somente nos DAOs?
2. Quais caches dos managers representam dados e quais representam UI?
3. A versão lógica `1006` será mantida ou unificada futuramente com `dbVersion`?
4. Como recuperar a aplicação quando abertura ou migration falhar, sem `exit(1)`?

## Critérios de aceite

- UI, ViewModels e domínio não conhecem `sqflite` ou maps de persistência;
- DAOs recebem a dependência de banco e conhecem SQL;
- repositories recebem DAOs/serviços pelo construtor;
- operações retornam domínio ou `Result`, não exceções cruas;
- foreign keys, migrations, backup e restauração continuam funcionais;
- um banco da versão atual abre sem perda ou recriação;
- testes de compatibilidade são criados para as operações efetivamente migradas;
- análise termina sem novos erros.

## Decisões

### 2026-08-13 — Compatibilidade antes de redesenho

**Decisão:** a migração arquitetural não alterará o schema por conveniência.

**Motivo:** reorganização de código não justifica risco sobre dados existentes.

**Consequências:** mudanças de schema exigirão backlog funcional próprio,
migration incremental e validação de backup/restauração.

## Acompanhamento

**Estado:** Planejado.

**Próximo backlog:** `004-configuracoes-mvvm.md`.

