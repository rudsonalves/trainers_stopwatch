# Arquitetura atual do Trainer's Stopwatch

> Estado consolidado em 26 de agosto de 2026, após os backlogs 001 a 010.

## Visão geral

O Trainer's Stopwatch é uma aplicação Flutter local-first para controlar
cronômetros de vários atletas, registrar parciais e voltas, consultar treinos e
compartilhar relatórios. A aplicação usa MVVM na apresentação e preserva BLoC
exclusivamente no núcleo temporal do cronômetro.

```text
UI (Pages e Components)
        |
        v
ViewModels / StopwatchBloc
        |
        v
UseCases e domínio
        |
        v
Repositories
        |
        v
Services (SQLite e plugins)
```

As dependências são montadas no composition root em `lib/core/config`. Objetos
de aplicação recebem colaboradores por construtor; Pages não consultam o
injetor, repositories, serviços de plataforma ou singletons.

## Organização do código

```text
lib/
├── application/         sessões e coordenação dos cronômetros
├── core/                bootstrap, configuração, resultado, Commands e rotas
├── data/                repositories e serviços concretos
├── domain/              entidades, valores, regras, contratos e UseCases
├── ui/
│   ├── app/             MaterialApp e estado global de aparência
│   ├── components/      componentes reutilizados por múltiplos fluxos
│   └── pages/           Pages, ViewModels e widgets locais
└── main.dart            inicialização e composition root
```

O diretório legado `lib/features` foi removido. Componentes só ficam em
`ui/components` quando possuem reutilização concreta; widgets específicos
permanecem próximos da Page consumidora.

## Inicialização e configurações

`main.dart` inicializa Flutter e localização, preserva a splash durante o
bootstrap, configura as dependências e monta `MyMaterialApp`. O
`DatabaseProvider` abre o SQLite, carrega as configurações pelo repository e
sincroniza `AppAppearanceState`. Falhas de bootstrap são convertidas em
`AppError` e apresentadas por uma aplicação mínima de erro.

Não existe mais `AppSettings` nem outro singleton de negócio. Brilho, contraste
e locale são observados por `AppAppearanceState`; edição e persistência ficam em
`SettingsViewModel` e `SettingsRepository`.

## Apresentação

As rotas constroem as Pages e injetam suas dependências. Cada Page mantém apenas
responsabilidades visuais, como navegação, dialogs, menus, focus e controllers
de campos. Operações e estado não visual ficam em ViewModels ou no BLoC.

| Fluxo | Estado de apresentação |
| --- | --- |
| cronômetros | `StopwatchPageViewModel` e sessões individuais |
| usuários | `UsersViewModel` |
| treino ativo | `HistoryViewModel` e sessão do cronômetro |
| treinos e relatórios | `TrainingsViewModel` |
| histórico | `HistoryViewModel` |
| configurações | `SettingsViewModel` e `AppAppearanceState` |

Intenções assíncronas são expostas por `Command` ou por estado equivalente da
sessão. Loading, vazio e falha são explícitos nos fluxos relevantes, e controles
incompatíveis ficam bloqueados durante operações pendentes.

## Navegação

`go_router` centraliza nomes e paths em `lib/core/routing/routes.dart`. Pages
navegam por nomes centralizados; ViewModels não recebem `BuildContext`. Dados de
rota são transportados por classes de argumentos tipadas. A rota de treino
individual recebe um identificador estável de sessão e resolve a instância no
composition root, sem transportar ViewModels como argumento.

## Domínio e aplicação

O domínio usa Dart puro e `core/result`. Ele não depende de Flutter, SQLite,
plugins, localização ou widgets. Seus principais grupos são:

- usuários, configurações, treinos e históricos;
- unidades e valores de distância e velocidade;
- eventos de treino e cálculo de velocidade;
- conteúdo de relatórios e contratos de entrega;
- UseCases de usuários, treinos, persistência de sessões e relatórios.

`Result`, `AppError` e `Unit` representam sucesso e falhas esperadas. Adapters,
models e helpers da arquitetura anterior foram removidos depois da migração de
seus consumidores.

## Núcleo do cronômetro

`StopwatchBloc` é a máquina temporal e controla início, pausa, retomada, reset,
parcial, volta e término. `StopwatchSessionViewModel` coordena uma sessão,
persiste treino e histórico por UseCases e publica um estado imutável com
operação pendente e erro apresentável.

`StopwatchPageViewModel` mantém as sessões ativas indexadas por identificador,
agrega mensagens e controla remoções concorrentes. A UI constrói os widgets a
partir dessas sessões; nenhum ViewModel armazena widgets.

## Persistência e integrações

Repositories mantêm o cache observável e delegam operações a serviços de dados.
Os serviços SQLite convertem registros diretamente para tipos de domínio. O
banco existente continua compatível e preserva a substituição segura de um
arquivo antigo antes da abertura.

Plugins ficam atrás de serviços concretos para seleção, compressão e
armazenamento de imagens, geração de PDF, arquivo temporário, compartilhamento e
e-mail. UseCases coordenam essas fronteiras e garantem ownership e limpeza dos
arquivos temporários.

## Relatórios

`TrainingReportContentBuilder` produz conteúdo de domínio sem PDF, bundle ou
plugins. O renderer recebe dados e textos preparados pela apresentação. Os
UseCases carregam históricos, geram o arquivo e o entregam por compartilhamento
ou e-mail, propagando falhas como `AppError`.

## Tema, localização e plataformas

`MyMaterialApp` deriva os temas de `AppAppearanceState`. Componentes migrados
usam `ColorScheme` e tipografia do tema sem impor um redesenho. Textos de UI são
fornecidos por `easy_localization`; textos de PDF são preparados na fronteira de
apresentação.

As plataformas mantidas nesta versão são Android e iOS. Integrações nativas
devem ser confirmadas manualmente nas duas plataformas antes do encerramento de
um backlog que as altere.

## Validação

Os testes cobrem domínio, serviços, repositories, UseCases, ViewModels, BLoC,
rotas e estados de widget relevantes. A entrega é validada por `dart format`,
testes focados, suíte completa, `flutter analyze`, `git diff --check`, buscas de
fronteiras e legado e validação manual dos fluxos nativos em Android e iOS.
