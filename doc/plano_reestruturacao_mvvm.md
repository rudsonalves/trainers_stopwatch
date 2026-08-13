# Plano de reestruturação para MVVM

> Proposta analisada em 13 de agosto de 2026. A referência arquitetural é o
> aplicativo `go-list2/mobile`. O objetivo principal é atualizar e organizar o
> código; testes acompanham somente o comportamento alterado em cada etapa.

Os incrementos executáveis deste plano estão organizados em
[`backlog/README.md`](backlog/README.md).

## 1. Direção recomendada

A reestruturação é viável e pode ser incremental. A arquitetura de destino deve
seguir o mesmo vocabulário e as mesmas regras do `go-list2/mobile`, adaptadas a
uma aplicação local-first:

```text
Fluxo comum

UI -> ViewModel -> Repository -> Local Service/DAO -> Database

Fluxo coordenado

UI -> ViewModel -> UseCase -> Repositories/Services

Fluxo temporal

UI -> StopwatchViewModel -> StopwatchBloc -> dart:core Stopwatch
                         \-> UseCase/Repository para persistência
```

O BLoC não concorre com MVVM. Ele será um componente especializado, interno à
feature de cronômetro, responsável apenas pela máquina temporal. O ViewModel
continua sendo a fronteira da página com persistência, comandos e estado de
apresentação.

## 2. Princípios herdados de `go-list2/mobile`

- separar `core`, `data`, `domain` e `ui`;
- injetar dependências pelo construtor;
- usar `Result`, `AppError` e `Command` para operações que podem falhar;
- impedir exceções cruas de chegarem à UI;
- manter ViewModels sem `BuildContext`, widgets, focus nodes ou navegação;
- deixar páginas responsáveis por navegação, dialogs e feedback;
- esconder persistência atrás de repositories;
- criar UseCases somente quando coordenarem operações relevantes;
- manter o domínio independente de Flutter e SQLite;
- evitar abstrações vazias criadas apenas por simetria.

## 3. Adaptação ao Trainer's Stopwatch

O `go-list2/mobile` usa `API Service -> RestClient -> Dio`. Aqui, o equivalente é:

```text
Repository -> Local Service/DAO -> Database
```

O DAO conhece tabelas, colunas, queries, batches e maps SQLite. O repository
conhece operações do aplicativo e converte registros persistidos em modelos de
domínio. ViewModels e UseCases não conhecem `sqflite` nem `Map<String, dynamic>`.

Integrações que não são banco também ficam atrás de contratos pequenos:

- diretórios e arquivos;
- seleção e compressão de imagens;
- geração de PDF;
- compartilhamento;
- envio por e-mail;
- backup do banco.

## 4. Estrutura de diretórios proposta

```text
lib/
├── core/
│   ├── config/
│   │   └── dependencies.dart
│   ├── result/
│   │   ├── app_error.dart
│   │   ├── command.dart
│   │   ├── result.dart
│   │   └── unit.dart
│   ├── services/
│   │   ├── clock/
│   │   ├── database/
│   │   ├── files/
│   │   └── logging/
│   └── resources/
├── data/
│   ├── repositories/
│   │   ├── history/
│   │   ├── settings/
│   │   ├── training/
│   │   └── user/
│   └── services/
│       ├── database/
│       │   ├── daos/
│       │   ├── migrations/
│       │   └── schema/
│       ├── images/
│       └── reports/
├── domain/
│   ├── common/
│   │   ├── history/
│   │   ├── settings/
│   │   ├── stopwatch/
│   │   ├── training/
│   │   └── user/
│   └── usecases/
│       ├── training/
│       └── reports/
├── ui/
│   ├── components/
│   ├── pages/
│   │   ├── history/
│   │   ├── settings/
│   │   ├── stopwatch/
│   │   ├── trainings/
│   │   └── users/
│   └── theme/
└── main.dart
```

Não é necessário criar todas as pastas antecipadamente. Elas entram conforme as
features forem migradas.

## 5. Responsabilidades das camadas

### `core`

Infraestrutura transversal e independente das features:

- composição de dependências;
- `Result`, `AppError`, `Unit` e `Command`;
- logging;
- contratos básicos de relógio, arquivos e banco;
- rotas e configuração global.

`core` não conhece atleta, treino, histórico, página ou ViewModel.

### `domain`

Conceitos e regras estáveis:

- `User`, `Training`, `HistoryEntry` e configurações relevantes;
- unidades de distância e velocidade como tipos/enums, não strings dispersas;
- cálculos de velocidade, índice de volta/parcial e relatório;
- estado temporal independente de Flutter quando possível;
- UseCases para operações compostas.

Os modelos devem usar Dart puro. `Color`, `ValueNotifier`, SQLite, paths e
plugins não pertencem ao domínio. A cor de apresentação do cronômetro deve ser
um valor serializável ou estado da UI, conforme a decisão de produto.

### `data`

Implementa repositories e integrações:

- DAOs executam SQLite;
- repositories convertem persistência em domínio;
- serviços acessam arquivos, imagens e relatórios;
- migrations e schema permanecem encapsulados;
- falhas viram `AppError` apropriado.

### `ui`

Contém páginas, ViewModels, componentes, tema e o BLoC da feature temporal.

- Page: widget tree, `BuildContext`, navegação, dialogs e controllers visuais;
- ViewModel: comandos, estado de apresentação e coordenação;
- BLoC: estado temporal do cronômetro;
- componente: somente valores e callbacks, sem acesso a repository ou singleton.

## 6. Desenho do cronômetro

### Limite de responsabilidade

`StopwatchBloc` deve controlar exclusivamente:

- iniciar;
- pausar;
- retomar;
- reiniciar;
- registrar snapshot de parcial;
- registrar snapshot de volta;
- encerrar;
- aplicar limite de voltas;
- emitir estado temporal imutável.

Ele não deve:

- criar `Training` no banco;
- instanciar managers ou repositories;
- montar mensagens traduzidas;
- conhecer usuário, página, cor ou PDF;
- usar `BuildContext` ou `ValueNotifier`.

### Uso de `dart:core Stopwatch`

Cada instância do BLoC possui um `Stopwatch`:

```text
Stopwatch.elapsed             duração total ativa
lastSplitElapsed              marco da última parcial
lastLapElapsed                marco da última volta
splitDuration = elapsed - lastSplitElapsed
lapDuration   = elapsed - lastLapElapsed
```

`Stopwatch.start()` retoma sem contar o período parado, eliminando o ajuste
manual de pausas feito hoje com vários `DateTime`. `stop()` pausa e `reset()`
zera a medição.

Um ticker periódico continua necessário apenas para solicitar atualizações de
tela. Ele não será a fonte do tempo. O estado emitido lê `Stopwatch.elapsed`.

`DateTime.now()` continua necessário para a data civil de início/fim do treino,
mas deve vir de um contrato separado, por exemplo `Clock.now()`. Tempo decorrido
e data do calendário deixam de ser a mesma responsabilidade.

### Estado do BLoC

É recomendável substituir estados vazios mais `ValueNotifier`s paralelos por um
estado imutável único:

```text
StopwatchState
  status: initial | running | paused | finished
  elapsed: Duration
  lapElapsed: Duration
  splitElapsed: Duration
  lapCount: int
  splitCount: int
```

Isso evita duas fontes de verdade e permite que `BlocBuilder`/`BlocSelector`
atualizem somente os trechos necessários.

### Papel do ViewModel

`StopwatchViewModel` compõe o BLoC e os casos de uso da sessão:

- cria e descarta uma sessão por atleta;
- expõe comandos de persistência e erros esperados;
- coordena início/registro/finalização com o repository;
- transforma domínio em dados de apresentação;
- não contém widgets.

O BLoC pode ser exposto como dependência observável do ViewModel, mas não deve
conhecer o ViewModel. Para evitar persistência baseada em listeners frágeis, as
ações públicas do ViewModel coordenam explicitamente BLoC e UseCase.

### Ordem transacional das ações

A ordem precisa ser definida para não iniciar uma medição que não possa ser
persistida:

- primeiro início: criar treino com sucesso, depois iniciar BLoC;
- parcial/volta: capturar snapshot no BLoC e persistir o valor capturado;
- falha de persistência: manter o cronômetro ativo e apresentar erro recuperável,
  sem apagar a medição;
- encerramento: capturar o snapshot final, parar e persistir;
- reset: não excluir automaticamente dados já persistidos sem uma decisão
  explícita do usuário.

Se consistência forte entre múltiplas escritas for necessária, um UseCase usa
transação SQLite por meio do repository/serviço, não do ViewModel.

## 7. Reconfiguração do estado global

Os singletons atuais não devem ser apenas movidos de pasta.

| Atual | Destino sugerido |
| --- | --- |
| `DatabaseManager.instance` | instância criada no composition root e injetada nos DAOs |
| `AppSettings.instance` | `SettingsRepository` + `AppSettingsViewModel`/estado de aplicação |
| `UserManager.instance` | `UserRepository` injetado; cache somente se necessário |
| `StopwatchPageController.instance` | `StopwatchPageViewModel` com sessões/modelos, nunca widgets |

O composition root pode seguir `go-list2/mobile` com `AutoInjector`, desde que a
dependência já aceita no projeto seja deliberadamente adotada. Também é possível
começar com factories explícitas e introduzir o container quando a base estiver
estável. O importante é preservar injeção por construtor nos consumidores.

## 8. Tratamento de erros e comandos

Adotar os mesmos contratos do projeto de referência reduz divergência entre os
projetos:

- `Result<T>`: `Success<T>` ou `Failure<T>`;
- `AppError`: código, mensagem e causa controlada;
- `Unit`: sucesso sem valor relevante;
- `Command0`/`Command1`: `idle`, `running`, `success` e `failure`.

Os ViewModels expõem Commands para operações assíncronas iniciadas pela UI.
A atualização frequente do tempo não é um Command: ela permanece como stream de
estado do BLoC.

Categorias iniciais de erro podem incluir banco indisponível, falha de migração,
registro não encontrado, dados inválidos, arquivo, imagem, relatório e
compartilhamento. Não é necessário modelar antecipadamente códigos sem uso.

## 9. Navegação

A aplicação manterá o Navigator 1.0 durante esta reestruturação. O conjunto
atual de rotas é pequeno e predominantemente linear, portanto Router API,
delegates e roteamento declarativo não oferecem benefício proporcional agora.

O padrão será:

- rotas nomeadas registradas no `MaterialApp`;
- `Navigator.pushNamed`, `pushReplacementNamed` e `pop` conforme o fluxo;
- argumentos tipados por classes próprias quando o contrato da rota exigir mais
  clareza;
- navegação, dialogs, snackbars e leitura de `BuildContext` permanecem na Page;
- ViewModels expõem resultado e estado, mas nunca chamam `Navigator`;
- Commands não retornam nomes de rotas: a Page decide o destino após o sucesso;
- nomes e paths das rotas ficam centralizados para evitar strings espalhadas.

Não será criada uma abstração genérica de router em `core`. Ela só deve ser
considerada se surgir uma necessidade concreta, como deep links, navegação web,
guards ou restauração de estado.

```text
Page executa Command
  -> ViewModel processa operação
  -> Command termina com Success
  -> Page observa Success
  -> Page chama Navigator 1.0
```

## 10. Estratégia de migração

A migração deve ocorrer de baixo para cima na base e, depois, por fluxos
verticais. Não se recomenda mover todos os arquivos de uma vez.

### Etapa 0 — registrar as decisões

- aprovar este desenho;
- usar a nomenclatura `Viewmodel`, alinhada ao projeto de referência;
- usar `AutoInjector` no composition root;
- definir plataformas que continuarão suportadas;
- preservar Navigator 1.0 e rotas nomeadas durante a reestruturação;
- congelar novas dependências arquiteturais durante a transição.

Resultado: arquitetura de destino acordada, sem mudança funcional.

### Etapa 1 — fundação em `core`

- portar/adaptar `Result`, `AppError`, `Unit` e `Command` de `go-list2/mobile`;
- criar logging e composição de dependências;
- definir contratos mínimos de clock, banco e arquivos quando forem usados;
- manter bootstrap atual funcionando por adaptadores temporários.

Testes por demanda: contratos de `Result`/`Command` e adaptações que possam
alterar tratamento de falhas.

### Etapa 2 — domínio puro

- mover cálculos de duração, velocidade e relatório para `domain`;
- substituir strings de unidades por enums/value objects com conversão nas
  bordas;
- remover dependências de Flutter dos modelos de domínio;
- separar modelos de apresentação, domínio e persistência somente onde houver
  diferença real.

Testes por demanda: cálculos e conversões afetados pela mudança.

### Etapa 3 — persistência

- transformar stores em DAOs injetáveis;
- transformar repositories em contratos orientados ao domínio;
- absorver a responsabilidade de cache dos managers no repository ou ViewModel,
  conforme o tipo de estado;
- encapsular migrations, backup e transações;
- preservar o banco existente e sua migração, sem troca destrutiva de schema.

Testes por demanda: compatibilidade com o banco atual, migrations alteradas e
operações CRUD migradas.

### Etapa 4 — feature de configurações

- migrar primeiro uma feature de risco baixo;
- criar `SettingsViewModel` com Commands e repository injetado;
- retirar acesso direto a `AppSettings.instance` da página;
- manter apenas um estado de aplicação observável para tema e idioma.

Essa etapa valida o padrão MVVM antes do cronômetro.

### Etapa 5 — usuários

- migrar cadastro, edição, exclusão e seleção;
- mover arquivos/imagens para serviços injetados;
- eliminar `UserManager.instance`;
- manter controllers de texto e imagem na Page, não no ViewModel.

### Etapa 6 — treinos e histórico

- migrar listagem e edição para ViewModels;
- criar UseCases apenas para exclusões coordenadas e relatórios compostos;
- fazer `TrainingReport` operar sobre domínio puro;
- retirar repositories concretos de `BuildPdf`.

### Etapa 7 — núcleo do cronômetro

- reescrever internamente `StopwatchBloc` sobre `dart:core Stopwatch`;
- adotar estado imutável único e remover `ValueNotifier`s do BLoC;
- separar clock civil do tempo decorrido;
- criar `StopwatchViewModel` e UseCase de sessão;
- migrar um único cronômetro antes do gerenciamento de múltiplos atletas.

Testes por demanda: transições temporais modificadas, pausa/retomada,
parcial/volta, reset e encerramento.

### Etapa 8 — múltiplos cronômetros

- substituir a lista de widgets por uma lista de `StopwatchSessionViewModel`;
- usar chaves/IDs na Page para construir widgets;
- definir claramente criação e descarte de BLoCs/tickers por atleta;
- preservar independência entre sessões simultâneas.

### Etapa 9 — relatórios e integrações

- colocar PDF, compartilhamento e e-mail atrás de serviços;
- separar montagem do conteúdo da renderização do PDF;
- centralizar arquivos temporários e sua limpeza;
- devolver falhas esperadas como `Result`.

### Etapa 10 — limpeza da arquitetura antiga

- remover managers, stores e controllers substituídos;
- remover singletons sem consumidores;
- atualizar imports, documentação e nomes;
- executar análise completa e validar manualmente os fluxos suportados;
- avaliar dependências obsoletas somente depois da migração funcional.

## 11. Ordem de entrega recomendada

```text
Fundação
  -> domínio puro
  -> persistência compatível
  -> configurações (piloto MVVM)
  -> usuários
  -> treinos/histórico
  -> BLoC com dart:core Stopwatch
  -> múltiplos cronômetros
  -> relatórios/integrações
  -> remoção da arquitetura antiga
```

Configurações funciona como piloto porque atravessa UI e banco, mas não envolve
o risco temporal do cronômetro. Migrar o BLoC somente depois de domínio e
persistência reduz a quantidade de decisões simultâneas.

## 12. Riscos da reestruturação

### Compatibilidade do banco

É o maior risco de dados. Renomear classes e pastas não exige alterar tabelas.
Mudanças de schema devem continuar incrementais e manter backup/restauração.

### Mistura de arquitetura antiga e nova

Durante a transição haverá dois caminhos. Cada feature migrada deve possuir uma
fronteira clara; código novo não deve depender de managers/singletons antigos,
salvo por adapters temporários documentados.

### Duplicidade BLoC/ViewModel

O risco é ambos passarem a controlar o mesmo estado. A regra deve ser rígida:
BLoC controla tempo; ViewModel controla operação e apresentação da sessão.

### Frequência de emissão

Emitir um novo estado a cada 66 ms pode reconstruir UI demais. Usar
`BlocSelector`, componentes pequenos e uma frequência visual configurável. A
precisão continua vindo de `Stopwatch.elapsed`, não da frequência do ticker.

### Persistência durante medição

Falhas de escrita não podem destruir o tempo já medido. Snapshots de parcial e
volta precisam ser valores imutáveis, capazes de nova tentativa ou sinalização
explícita.

### Escopo excessivo

Atualizar arquitetura, UI, banco e regras ao mesmo tempo aumenta o risco. Cada
etapa deve terminar com o aplicativo executável e sem deixar duas implementações
ativas da mesma feature por longo período.

## 13. Critérios arquiteturais de conclusão

A reestruturação estará concluída quando:

- páginas não acessarem SQLite, arquivos, repositories concretos ou singletons;
- navegação com Navigator 1.0 permanecer restrita às Pages;
- ViewModels receberem dependências por construtor e expuserem Commands/estado;
- modelos de domínio não importarem Flutter ou `sqflite`;
- repositories esconderem persistência e retornarem `Result`;
- UseCases existirem somente para coordenação real;
- o BLoC temporal usar `dart:core Stopwatch` como fonte de duração;
- o BLoC não persistir nem produzir UI/tradução;
- múltiplos cronômetros forem representados por sessões, não widgets armazenados;
- erros esperados chegarem à UI como `AppError`;
- o banco existente continuar legível após a atualização;
- testes permanecerem próximos das mudanças que protegem, sem se tornarem o
  objetivo da refatoração.

## 14. Primeira entrega sugerida

A primeira implementação deve abranger apenas:

1. fundação de `core` (`Result`, `AppError`, `Unit`, `Command`);
2. composition root mínimo;
3. contratos do novo `SettingsRepository`;
4. migração da página de configurações para `SettingsViewModel`;
5. adapter para ler e gravar o banco atual sem mudar o schema.

Essa entrega confirma o MVVM escolhido no próprio projeto antes de tocar no
cronômetro. Depois dela, as demais features podem repetir um padrão já validado.
