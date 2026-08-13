# 001 — Tarefas da fundação arquitetural

## Objetivo

Organizar a execução das decisões registradas em
[`001-fundacao-arquitetural.md`](001-fundacao-arquitetural.md).

## Ordem de execução

### 1. Criar os contratos de resultado

- [x] Criar `Result<T>`, `Success<T>` e `Failure<T>`.
- [x] Criar `AppError` com código, mensagem e detalhes opcionais.
- [x] Criar o catálogo inicial de `AppErrorCode`.
- [x] Criar `Unit` para operações sem retorno significativo.
- [x] Cobrir sucesso, falha e `fold` com testes próximos.

### 2. Criar Commands

- [x] Criar `Command0` e `Command1`.
- [x] Expor estados idle, running, success e failure.
- [x] Impedir execução concorrente do mesmo Command.
- [x] Preservar `AppError` esperado.
- [x] Converter exceção inesperada em `AppErrorCode.unexpected`.
- [x] Cobrir transições, entrada e falhas com testes próximos.

### 3. Criar infraestrutura transversal

- [x] Criar logging de desenvolvimento sem conteúdo sensível.
- [x] Adicionar `AutoInjector` às dependências.
- [x] Criar `setupDependencies()` idempotente.
- [x] Registrar dependências existentes como adapters temporários.
- [x] Confirmar resolução do grafo sem executar APIs de plataforma no teste.

### 4. Adaptar o bootstrap

- [x] Criar o serviço `Bootstrap`.
- [x] Resolver o bootstrap pelo composition root.
- [x] Fazer `DatabaseProvider.init` retornar `AsyncResult<Unit>`.
- [x] Remover `exit(1)` da abertura do banco.
- [x] Diferenciar abertura e criação do banco.
- [x] Não confundir falha de leitura de settings com ausência do registro.
- [x] Bloquear migration quando o backup falhar.
- [x] Restaurar o backup quando a migration falhar.
- [x] Diferenciar falha de migration e falha de restauração.
- [x] Exibir fallback mínimo quando o bootstrap falhar.

### 5. Validar e documentar

- [x] Executar formatação.
- [x] Executar testes afetados.
- [x] Executar a suíte completa.
- [x] Executar `flutter analyze`.
- [x] Corrigir os três avisos preexistentes de imports relativos.
- [x] Registrar limitações.
- [x] Atualizar o acompanhamento do backlog principal.

## Regra de conclusão

O backlog só será concluído depois que a composição resolver o grafo, o caminho
de bootstrap não encerrar o processo abruptamente e todas as verificações
afetadas forem executadas.
