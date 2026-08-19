# 006 — Treinos e históricos

## Objetivo

Migrar consulta, edição e exclusão de treinos e históricos para MVVM, usando o
domínio e os repositories novos.

## Dependências

- `002-dominio-puro.md`;
- [`003-persistencia-e-repositories.md`](closed/003-persistencia-e-repositories.md), concluído;
- `005-usuarios-e-imagens.md`.

## Escopo

- criar `TrainingsViewModel` e `HistoryViewModel`;
- expor Commands para carregar, atualizar, excluir e selecionar registros;
- substituir `TrainingManager`, `HistoryManager` e `HistoryController` nos fluxos
  migrados;
- manter caches de dados no repository somente quando houver necessidade real;
- operar sobre models de domínio, sem maps SQLite;
- usar a nova regra de parcial/volta do domínio;
- introduzir UseCase para operações que coordenem treino e históricos;
- manter rotas nomeadas e argumentos tipados no Navigator 1.0;
- preservar exclusão em cascata e edição de comentários.

## Fora de escopo

- reescrever o BLoC temporal;
- implementar compartilhamento/PDF;
- redesenhar páginas;
- criar um UseCase para cada método simples de repository.

## Questões em aberto

1. A exclusão de treino será delegada à cascata ou explicitada em UseCase?
2. Como representar histórico inicial, parcial e volta no domínio sem duplicar
   persistência?
3. A seleção de múltiplos treinos pertence ao ViewModel ou a um model de página?

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

Nenhuma decisão adicional aprovada.

## Acompanhamento

**Estado:** Planejado.

**Próximos backlogs:** `007-nucleo-cronometro-bloc.md` e
`009-relatorios-e-compartilhamento.md`.
