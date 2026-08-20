# Arquitetura atual do Trainer's Stopwatch

> Levantamento do código existente em 13 de agosto de 2026. Este documento
> descreve a aplicação como ela está hoje; não propõe ainda uma arquitetura de
> destino.

A arquitetura de destino e a estratégia incremental estão descritas em
[`plano_reestruturacao_mvvm.md`](plano_reestruturacao_mvvm.md).

## Estado da transição arquitetural

Os backlogs 001 e as tarefas 1 a 10 do backlog 002 introduziram uma fundação
nova sem remover ainda as camadas legadas.

### Fundação entregue

- `core/result`: `Result`, `AppError`, `Unit` e Commands;
- `core/config`: composition root com `AutoInjector`;
- `core/bootstrap`: inicialização tipada da aplicação;
- logging transversal de desenvolvimento;
- erros distintos para banco, migration, backup, restauração e storage.

### Domínio entregue

```text
domain/common/
├── user/models/User
├── settings/models/Settings
├── history/models/HistoryEntry
├── stopwatch/models/*Snapshot
└── training/
    ├── models/Training
    ├── units/DistanceUnit, SpeedUnit
    ├── values/Distance, Speed
    ├── events/TrainingEvent
    └── services/SpeedCalculator, TrainingEventGenerator
```

O domínio usa Dart puro e `core/result`. Ele não conhece Flutter, SQLite,
localização, widgets, repositories ou plugins. Cor permanece estado visual da
sessão. A versão do schema permanece metadado da persistência.

### Convivência temporária

Adapters em `lib/common/adapters` conectam os models antigos aos tipos novos.
`StopwatchFunctions.speedCalc` já delega para `SpeedCalculator`, e
`TrainingReport` já delega para `TrainingEventGenerator`. Esses adapters serão
removidos conforme dados, configurações e UI forem migrados nos backlogs 003 a
005.

## 1. Visão geral

O Trainer's Stopwatch é uma aplicação Flutter local-first para controlar
cronômetros de vários atletas, registrar parciais e voltas, manter o histórico
dos treinos e compartilhar relatórios.

A organização atual é híbrida:

- a apresentação é agrupada principalmente por funcionalidade em `features`;
- o acesso a dados segue uma separação em camadas;
- a máquina de estados do cronômetro usa BLoC;
- as demais telas usam controllers com `ChangeNotifier` ou estado local;
- configurações, banco e controle da tela principal usam singletons;
- integrações com arquivos e serviços do dispositivo são chamadas diretamente.

Portanto, o projeto não implementa integralmente Clean Architecture, MVC, MVVM
ou BLoC. Ele reúne elementos desses estilos em uma arquitetura própria.

## 2. Mapa de alto nível

```text
main.dart
  |
  +-- DatabaseProvider ------ DatabaseManager / migrações / backup
  |
  +-- EasyLocalization
  |
  +-- MyMaterialApp --------- tema, idioma e rotas
          |
          +-- Pages / Overlays / Widgets
                    |
                    +-- Page Controllers / HistoryController
                    |         |
                    |         +-- Managers
                    |                   |
                    |                   +-- Repositories
                    |                             |
                    |                             +-- Stores
                    |                                      |
                    |                                      +-- SQLite
                    |
                    +-- PreciseStopwatchController
                              |
                              +-- StopwatchBloc
                              +-- TrainingManager
                              +-- HistoryManager
```

O fluxo acima é predominante, mas não obrigatório. Há controllers que acessam
singletons diretamente, funções que instanciam repositories e widgets mantidos
dentro de um controller global.

## 3. Inicialização da aplicação

O ponto de entrada é `lib/main.dart`:

1. inicializa os bindings do Flutter;
2. mantém a splash screen ativa;
3. inicializa `easy_localization`;
4. abre e prepara o banco por meio de `DatabaseProvider`;
5. carrega configurações globais em `AppSettings`;
6. executa migrações, com backup anterior e tentativa de restauração em caso de
   erro;
7. monta `MyMaterialApp` dentro de `EasyLocalization`.

`MyMaterialApp` observa brilho e contraste em `AppAppearanceState`, cria os
temas e entrega a navegação ao `GoRouter`. A rota inicial é `/stopwatch`.

## 4. Apresentação e navegação

A camada de apresentação fica em `lib/features`. Cada funcionalidade pode conter
página, overlay de tutorial, controller e widgets próprios.

| Funcionalidade | Rota | Responsabilidade |
| --- | --- | --- |
| cronômetros | `/stopwatch` | selecionar atletas e controlar vários cronômetros |
| usuários | `/users` | cadastrar, editar, excluir e selecionar atletas |
| treino ativo | `/training` | exibir o histórico ligado a um cronômetro |
| treinos | `/trainings` | consultar, selecionar e compartilhar treinos salvos |
| histórico | `/history` | detalhar e editar registros de um treino |
| configurações | `/settings` | alterar unidades, distâncias, tema, idioma e tutorial |
| sobre | `/about` | apresentar informações e links externos |

Os overlays envolvem algumas páginas para implementar o onboarding com
`onboarding_overlay`. O `go_router` centraliza paths, nomes, observer e
transições em `lib/core/routing`. As Pages navegam por nome e passam objetos em
classes de argumentos tipadas; ViewModels não conhecem navegação. O `Navigator`
direto permanece apenas para fechar rotas modais, como dialogs e drawer.

### Estado da interface

Não existe um mecanismo único de estado para toda a apresentação:

- `StatefulWidget` controla estado estritamente visual;
- `ChangeNotifier` representa os estados de usuários e treinos;
- `HistoryController` define uma base comum para páginas de histórico;
- `ValueNotifier` atualiza contadores, mensagens, configurações e ações pontuais;
- `StopwatchBloc` controla exclusivamente o ciclo do cronômetro;
- alguns controllers são instâncias locais, enquanto outros são singletons.

As classes de estado dos controllers de página usam estados simples como
`Initial`, `Loading`, `Success` e `Error`. Erros são normalmente registrados no
log e convertidos para o estado `Error`.

## 5. Núcleo do cronômetro

O cronômetro é dividido em três partes:

### `PreciseStopwatch`

Widget que apresenta atleta, tempo, contadores e botões. Cada atleta selecionado
recebe uma instância desse widget e de `PreciseStopwatchController`.

### `PreciseStopwatchController`

Coordena a regra de aplicação do treino:

- envia eventos ao BLoC;
- cria e persiste o treino no primeiro início;
- registra o histórico inicial e as parciais;
- calcula velocidades;
- produz mensagens de início, parcial, volta e fim;
- comunica essas mensagens ao controller global da página principal.

### `StopwatchBloc`

É a máquina de estados temporal. Recebe eventos de iniciar, pausar, reiniciar,
registrar volta, registrar parcial e encerrar. Seus estados são inicial,
executando, pausado, reiniciado e erro.

`DateTime.now()` é a fonte de tempo. Um `Timer.periodic` atualiza a duração
exibida, mas a duração efetiva é calculada pela diferença entre instantes. Ao
retomar, os marcos temporais são deslocados pelo período pausado.

O BLoC publica o estado pelo próprio `flutter_bloc`, mas expõe tempo e contadores
por `ValueNotifier`. Assim, esta parte também é híbrida, não um BLoC puro.

## 6. Múltiplos cronômetros

`StopwatchPageController` é um singleton que mantém:

- usuários selecionados;
- novos usuários aguardando inclusão;
- uma lista de widgets `PreciseStopwatch` já construídos;
- quantidade de cronômetros em um `ValueNotifier`;
- última mensagem de histórico em outro `ValueNotifier`.

Esse controller funciona como estado de sessão da tela principal e também como
canal de comunicação entre cronômetros e o painel de mensagens. O fato de manter
widgets no controller mistura estado de apresentação com composição de UI.

## 7. Camada de aplicação: controllers e managers

Os controllers recebem ações da interface e coordenam operações assíncronas.
Eles também transformam resultados em estados observáveis pela UI.

Os managers encapsulam operações sobre coleções de modelos:

- `UserManager`: usuários;
- `TrainingManager`: treinos de um usuário;
- `HistoryManager`: históricos de um treino;
- `SettingsManager`: configurações.

Em geral, um manager consulta o repository, mantém uma lista em memória e a
atualiza após inserir, alterar ou excluir. `UserManager` é singleton;
`TrainingManager` e `HistoryManager` são normalmente criados por fluxo.

Não há uma camada explícita de casos de uso. Na prática, controllers e managers
dividem essa responsabilidade.

## 8. Acesso a dados

O acesso aos dados segue quatro níveis:

```text
Controller
   -> Manager                 coordenação e cache em memória
      -> Repository           conversão Model <-> Map
         -> Store             comandos SQLite e tratamento de erro
            -> DatabaseManager abertura e ciclo de vida do banco
```

### Repositories

Há um contrato abstrato e uma implementação concreta para usuário, treino,
histórico e configurações. As implementações convertem os mapas retornados pelo
store em models e atualizam identificadores depois de inserções.

Apesar das interfaces, managers normalmente instanciam repositories concretos
internamente. A abstração existe, mas não funciona como ponto de injeção de
dependência no desenho atual.

### Stores

Cada store executa CRUD diretamente com `sqflite`, obtém o banco pelo singleton
`DatabaseManager` e converte exceções em novas exceções com contexto de log.

### Banco e migrações

O banco `stopwatch.db` fica no diretório de documentos da aplicação. O SQLite é
aberto com chaves estrangeiras habilitadas.

Existem duas noções de versão:

- `dbVersion = 1`, usada por `openDatabase`;
- versão lógica de esquema `1006`, armazenada nas configurações e usada pelos
  scripts de migração.

Antes da migração, `DatabaseProvider` solicita um backup. `DatabaseMigration`
desativa chaves estrangeiras, aplica batches incrementais, atualiza a versão nas
configurações e reativa as chaves.

## 9. Modelo de dados

```text
User 1 -------- N Training 1 -------- N History

Settings (registro global)
```

| Entidade | Campos relevantes |
| --- | --- |
| `SettingsModel` | distâncias, unidade, versão do esquema, brilho, contraste, idioma, atualização e tutorial |
| `UserModel` | nome, e-mail, telefone e caminho da foto |
| `TrainingModel` | usuário, data, comentários, distâncias, limite de voltas, unidades e cor |
| `HistoryModel` | treino, duração e comentários |
| `MessagesModel` | representação de uma mensagem exibida; não é uma tabela |

Usuários possuem treinos e treinos possuem históricos, ambos com exclusão em
cascata. Voltas não possuem tabela própria: são derivadas da sequência de
parciais e da relação entre comprimento da volta e comprimento da parcial.

A cor existe em `TrainingModel`, mas não é incluída em `toMap` e não possui coluna
no esquema. Portanto, ela é estado de execução e não é restaurada do banco.

## 10. Configuração global

`AppSettings` estende `SettingsModel` e é um singleton. Além dos valores
persistidos, expõe `ValueNotifier` para brilho e contraste e mantém informações
de tutorial e diretórios da aplicação.

Ele é acessado diretamente pelo app, BLoC, controllers e páginas. Assim,
configuração persistida, estado global observável e detalhes de ambiente ficam
reunidos no mesmo objeto.

## 11. Serviços e funções transversais

`lib/common/functions` contém serviços estáticos ou funções de domínio:

- `StopwatchFunctions`: formatação de duração e conversão de velocidade;
- `TrainingReport`: transforma históricos em mensagens de início, parcial e
  volta;
- `BuildPdf`: consulta históricos e gera o arquivo PDF;
- `AppShare`: compartilha o PDF ou abre o cliente de e-mail.

Esses componentes ficam fora da cadeia manager/repository/store. `BuildPdf`, por
exemplo, instancia `HistoryRepository` diretamente. Diretórios, bundle de assets,
e-mail e compartilhamento também são acessados diretamente pelas APIs dos
plugins.

As fotos de usuários são escolhidas pela interface, comprimidas no controller e
gravadas no diretório de documentos. O controller também remove arquivos que não
estão mais referenciados no banco.

## 12. Internacionalização, tema e assets

As traduções ficam em `assets/translations` para `pt-BR`, `en-US` e espanhol. A
localização é disponibilizada acima de `MaterialApp`.

O tema Material possui variantes clara/escura e três níveis de contraste. As
preferências são observadas por `AnimatedBuilder`. Imagens, ícones e fontes são
empacotados como assets; fotos de usuários ficam no armazenamento da aplicação.

## 13. Dependências e acoplamentos arquiteturais

Os principais pontos que condicionam futuras atualizações são:

1. **Arquitetura de estado híbrida:** BLoC, `ChangeNotifier`, `ValueNotifier`,
   estado local e singletons coexistem.
2. **Dependências construídas internamente:** controllers, managers, repositories
   e stores instanciam suas dependências concretas.
3. **Estado global:** `AppSettings`, `DatabaseManager`, `UserManager` e
   `StopwatchPageController` vivem como singletons.
4. **UI dentro de controller:** a lista global de cronômetros contém widgets, e
   não somente modelos de estado.
5. **Camadas parcialmente atravessadas:** serviços como PDF acessam repository
   diretamente e controllers executam operações de sistema de arquivos.
6. **Regra distribuída:** a lógica de treino está dividida entre BLoC,
   `PreciseStopwatchController`, managers, models e funções comuns.
7. **Contratos abstratos pouco explorados:** repositories possuem interfaces,
   mas elas não são injetadas nos consumidores.
8. **Erros tratados localmente:** predominam log, nova `Exception` e estado
   genérico de erro; não há um modelo comum de falhas.

Esses pontos não são, por si sós, defeitos. Eles descrevem as fronteiras atuais e
onde uma mudança pode repercutir em mais de uma camada.

## 14. Fluxos principais

### Iniciar um treino

```text
Usuário toca Iniciar
  -> PreciseStopwatchController
  -> StopwatchBloc inicia medição
  -> TrainingManager persiste Training
  -> HistoryManager persiste registro inicial
  -> StopwatchPageController recebe mensagem
  -> UI atualiza tempo e painel de eventos
```

### Registrar parcial ou volta

```text
Botão parcial/volta
  -> evento no StopwatchBloc
  -> BLoC calcula duração desde o último marco
  -> controller calcula velocidade
  -> HistoryManager persiste parcial
  -> controller deriva mensagem de parcial/volta
  -> tela principal recebe a mensagem
```

### Consultar e compartilhar treinos

```text
TrainingsPage
  -> TrainingsPageController
  -> UserManager / TrainingManager
  -> Repository -> Store -> SQLite
  -> seleção de treinos
  -> AppShare -> BuildPdf
  -> HistoryRepository -> SQLite
  -> plugin de compartilhamento ou e-mail
```

## 15. Consequência para a atualização do código

Antes de escolher mudanças estruturais, é necessário decidir quais características
atuais devem ser preservadas e qual arquitetura de destino será adotada. A ordem
natural do trabalho é:

1. usar este mapa como linha de base;
2. definir objetivos da atualização, plataformas mantidas e restrições;
3. escolher as fronteiras desejadas entre apresentação, aplicação, domínio e
   infraestrutura;
4. atualizar por fluxo vertical, evitando uma reescrita integral;
5. criar testes somente para proteger o comportamento afetado em cada mudança e
   para reproduzir defeitos encontrados.

Os testes, portanto, apoiam a atualização; não são o produto principal deste
levantamento.
