# 014 — Composição de dependências fora do `main`

## Objetivo

Simplificar a inicialização da aplicação, removendo do `main.dart` a criação
manual dos ViewModels e eliminando o repasse dessas dependências pelo
`MyMaterialApp` somente para que cheguem às rotas.

## Contexto

Atualmente, o `main.dart` resolve ou constrói os ViewModels das páginas e os
entrega ao `MyMaterialApp`. O widget, por sua vez, reúne essas instâncias em
`MainRouteDependencies` e as passa ao roteador.

Esse encadeamento faz o ponto de entrada conhecer detalhes das páginas, dos
repositories e dos UseCases. A aplicação `banklab/mobile` mantém o ponto de
entrada menor: registra as dependências no módulo de composição e as resolve
mais perto das rotas que as consomem.

Não existe uma necessidade funcional no Trainer's Stopwatch que exija a
estrutura atual. A principal razão para preservá-la parcialmente é permitir
que os testes de rotas forneçam dependências controladas sem inicializar toda
a infraestrutura real.

## Direção proposta

- registrar no módulo de dependências os ViewModels que ainda são construídos
  manualmente no `main.dart`, incluindo o `TrainingsViewModel`;
- deixar o `main.dart` responsável apenas pela inicialização da infraestrutura
  global, localização e execução do app;
- fazer o `MyMaterialApp` obter somente o estado global que realmente consome
  e criar o roteador sem receber ViewModels por construtor;
- mover a composição usada pelas páginas para a camada de rotas;
- manter um ponto de injeção opcional no roteador para que testes possam usar
  doubles sem depender do injector global;
- respeitar o ciclo de vida de cada ViewModel, distinguindo instâncias globais
  de instâncias criadas por navegação e descartadas pelas páginas.

## Escopo

- `lib/main.dart`;
- `lib/ui/app/my_material_app.dart`;
- registro de ViewModels em `lib/core/config/dependencies/`;
- criação do roteador e composição em `lib/core/routing/`;
- testes do roteador e da inicialização afetados pela mudança.

## Fora de escopo

- alterar comportamentos das páginas;
- modificar regras de negócio ou fluxos de relatórios;
- substituir o `AutoInjector`;
- transformar todos os ViewModels em singletons;
- refatorar a navegação além do necessário para remover o encadeamento de
  dependências.

## Critérios de aceite

- `main.dart` não importa nem constrói ViewModels, repositories ou UseCases de
  páginas;
- `MyMaterialApp` não recebe ViewModels nem fábricas de páginas pelo
  construtor;
- as rotas continuam criando cada página com as dependências corretas;
- ViewModels descartados pelas páginas não são registrados como singletons;
- os testes de rotas continuam podendo fornecer dependências controladas;
- não há mudança observável nos fluxos de navegação;
- `flutter analyze`, testes afetados e `git diff --check` passam.

## Questões para fechar antes da execução

1. Manter `MainRouteDependencies` como fronteira opcional de testes, com uma
   composição de produção interna às rotas, ou fazer cada rota consultar o
   injector diretamente?
2. O `AppAppearanceState` deve continuar sendo resolvido pelo
   `MyMaterialApp`, por ser estado global efetivamente consumido pelo widget?
3. O `SettingsViewModel` usado pelo cronômetro deve ter instância dedicada ou
   compartilhar algum estado com a página de configurações?

## Acompanhamento

**Estado:** Backlog criado — aguardando discussão das questões em aberto.

**Próximo passo:** fechar as decisões arquiteturais e somente então criar o
arquivo de tasks para a implementação.
