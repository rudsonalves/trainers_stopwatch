# 002 — Domínio puro

## Objetivo

Isolar conceitos e regras estáveis do Trainer's Stopwatch em Dart puro, sem
dependências de Flutter, SQLite, plugins ou apresentação.

## Dependência

Depende de
[`closed/001-fundacao-arquitetural.md`](closed/001-fundacao-arquitetural.md)
para os contratos transversais.

## Escopo

- organizar `lib/domain/common` por usuário, treino, histórico, configurações e
  cronômetro;
- definir models de domínio pequenos, explícitos e preferencialmente imutáveis;
- retirar `Color`, `ValueNotifier` e detalhes SQLite dos conceitos de domínio;
- transformar unidades de distância e velocidade em enums ou value objects;
- migrar cálculos de velocidade e formatação independente de localização;
- migrar a regra que deriva parciais e voltas do histórico;
- definir snapshots temporais imutáveis para parcial, volta e encerramento;
- manter conversões para tradução e apresentação fora do domínio;
- criar UseCases apenas quando uma coordenação real for identificada.

## Fora de escopo

- mudar banco ou migrations;
- reescrever o `StopwatchBloc`;
- migrar páginas;
- criar DTOs idênticos aos models apenas por simetria.

## Questões em aberto

1. A cor do treino é configuração persistente, identidade visual da sessão ou
   somente estado de apresentação?
2. Quais combinações de unidade de distância e velocidade são válidas?
3. Como representar tempo zero e distância inválida nos cálculos?
4. O relatório de domínio deve produzir linhas neutras ou mensagens prontas?

## Critérios de aceite

- models de domínio não importam Flutter nem `sqflite`;
- unidades deixam de depender de strings espalhadas;
- regras de velocidade, parcial e volta possuem uma única implementação;
- tradução e cores não fazem parte das regras de domínio;
- adapters temporários mantêm consumidores antigos funcionando;
- testes são adicionados somente às regras alteradas e seus limites relevantes;
- análise termina sem novos erros.

## Decisões

Nenhuma decisão adicional aprovada.

## Acompanhamento

**Estado:** Planejado.

**Dependência:** backlog 001 concluído.

**Próximo backlog:** `003-persistencia-e-repositories.md`.
