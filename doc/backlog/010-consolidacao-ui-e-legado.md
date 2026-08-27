# 010 — Consolidação da UI e remoção do legado

## Objetivo

Concluir a adoção de MVVM na apresentação, uniformizar páginas e componentes e
remover a arquitetura antiga que já não possuir consumidores.

## Dependências

Depende da conclusão dos backlogs 004 a 009.

## Escopo

- revisar todas as Pages e ViewModels contra as regras arquiteturais;
- revisar nomes, paths e argumentos já centralizados no `go_router`;
- manter navegação, dialogs, snackbars, focus e controllers nas Pages;
- garantir loading, vazio, sucesso e erro nos fluxos relevantes;
- mover widgets compartilháveis para `ui/components` somente quando houver uso
  real em mais de uma feature;
- padronizar tema e remover usos obsoletos identificados pelo analyzer;
- remover managers, stores, controllers e singletons substituídos;
- remover adapters temporários sem consumidores;
- revisar dependências do `pubspec` e excluir somente as comprovadamente não
  utilizadas;
- atualizar README, arquitetura e backlogs concluídos;
- validar manualmente os fluxos suportados em cada plataforma mantida.

## Fora de escopo

- redesenho visual completo;
- trocar `go_router` por outra solução de navegação;
- novas funcionalidades de produto;
- abstrações de componentes sem reutilização concreta.

## Questões resolvidas

1. **Quais plataformas continuarão oficialmente suportadas?** Permanecem as
   plataformas já suportadas nesta versão, sem ampliação ou redução de escopo.
2. **Quais componentes atuais realmente justificam compartilhamento?** Um
   componente somente deve ser movido para `ui/components` quando houver
   reutilização concreta em duas ou mais features. Sem reutilização comprovada,
   ele permanece próximo da feature consumidora.
3. **Quais avisos/depreciações devem ser resolvidos junto da migração e quais
   exigem backlog próprio?** O backlog 010 corrige avisos dos arquivos migrados,
   imports obsoletos, substituições simples de API e problemas apontados pelo
   analyzer. Mudanças amplas de comportamento, atualizações relevantes de
   dependências, alterações nativas ou redesenho fora da consolidação recebem
   backlog próprio. Mensagens informativas de dependências externas não ampliam
   este escopo.

## Critérios de aceite

- páginas dependem somente de ViewModels/BLoCs e componentes adequados;
- nenhum ViewModel possui `BuildContext`, widget ou controller visual;
- nenhum fluxo migrado depende de manager/store/singleton legado;
- rotas nomeadas e argumentos permanecem centralizados no `go_router`;
- estados de tela importantes são explícitos;
- imports e dependências não utilizados são removidos;
- documentação descreve a arquitetura efetivamente entregue;
- `flutter analyze` não apresenta erros nem avisos introduzidos pela migração;
- testes afetados e validações manuais dos fluxos terminam com sucesso.

## Decisões

- manter as plataformas atualmente suportadas;
- promover widgets para `ui/components` somente com reutilização concreta em
  duas ou mais features;
- corrigir depreciações locais e simples no backlog 010 e separar mudanças
  amplas em backlog próprio.

## Acompanhamento

**Estado:** Em validação final — implementação e verificações automatizadas
concluídas; validação manual em Android e iOS pendente.

**Próximo backlog:** a definir conforme prioridades funcionais do produto.

## Validação da entrega

- formatação verificada em 210 arquivos Dart, sem alterações pendentes;
- 65 testes focados de ViewModels, BLoC, rotas, injeção, estados e widgets
  passaram;
- suíte completa passou com 345 testes;
- `flutter analyze` terminou sem issues;
- `git diff --check`, buscas de fronteiras e buscas de legado passaram;
- links relativos da documentação foram verificados e corrigidos;
- nenhum backlog derivado foi identificado;
- validação manual em Android e iOS permanece pendente.
