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

## Decisões

1. `MainRouteDependencies` permanece como fronteira opcional para testes. A
   composição de produção fica interna à camada de rotas e é usada
   automaticamente por `createRouter()` quando nenhuma substituição é
   fornecida. Assim, `main.dart` e `MyMaterialApp` não transportam dependências
   das páginas, enquanto os testes continuam independentes do injector global.
2. `AppAppearanceState` permanece como dependência explícita do
   `MyMaterialApp`, pois o widget consome diretamente esse estado para tema,
   contraste e idioma. A injeção explícita preserva a testabilidade sem
   acoplar o widget ao injector global.
3. O cronômetro mantém uma instância dedicada de `SettingsViewModel`. Cada
   abertura da página de configurações recebe uma instância própria, com ciclo
   de vida independente. As instâncias compartilham `SettingsRepository` e
   `AppAppearanceState`, sem compartilhar comandos ou objetos descartáveis.

## Acompanhamento

**Estado:** Concluído — decisões fechadas e implementação validada.

**Validação em 2026-08-28:** `flutter analyze` terminou sem problemas, os 381
testes da suíte passaram e `git diff --check` não encontrou erros.

**Próximo passo:** mover este documento para `doc/backlog/closed/` e atualizar
o índice do backlog.
