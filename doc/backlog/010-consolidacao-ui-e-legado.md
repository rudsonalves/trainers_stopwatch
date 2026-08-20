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

## Questões em aberto

1. Quais plataformas continuarão oficialmente suportadas?
2. Quais componentes atuais realmente justificam compartilhamento?
3. Quais avisos/depreciações devem ser resolvidos junto da migração e quais
   exigem backlog próprio?

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

Nenhuma decisão adicional aprovada.

## Acompanhamento

**Estado:** Planejado — encerramento da reestruturação arquitetural.

**Próximo backlog:** a definir conforme prioridades funcionais do produto.
