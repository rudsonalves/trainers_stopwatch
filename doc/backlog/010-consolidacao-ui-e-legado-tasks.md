# 010 — Tarefas de consolidação da UI e remoção do legado

## Objetivo

Concluir a adoção de MVVM na apresentação, uniformizar páginas e componentes e
remover a arquitetura antiga sem alterar o comportamento aprovado nem ampliar
as plataformas suportadas nesta versão.

## Decisões já tomadas

- permanecem oficialmente suportadas as plataformas já atendidas pela versão;
- widgets somente migram para `ui/components` quando forem usados concretamente
  por duas ou mais features;
- avisos, imports obsoletos e depreciações com substituição local e simples
  entram neste backlog;
- mudanças amplas de comportamento, dependências ou plataforma nativa recebem
  backlog próprio;
- navegação, dialogs, snackbars, focus e controllers visuais permanecem nas
  Pages;
- não haverá redesenho visual completo nem abstração sem reutilização real.

## Ordem de execução

### 1. Auditar a apresentação e caracterizar a linha de base

**Dependência:** backlogs 004 a 009 concluídos e decisões deste backlog
fechadas.

- [x] Inventariar Pages, ViewModels, BLoCs, componentes, rotas e artefatos
      legados ainda presentes.
- [x] Mapear dependências de cada Page e identificar acesso direto a repository,
      serviço, plugin, singleton, manager, store ou controller de negócio.
- [x] Registrar os fluxos suportados por plataforma e os pontos que exigem
      validação manual.
- [x] Executar e registrar `flutter analyze`, testes atuais e buscas
      arquiteturais antes das remoções.
- [x] Classificar achados em correção local deste backlog ou backlog futuro,
      conforme as decisões aprovadas.

**Resultado esperado:** existe uma linha de base verificável, com consumidores
e violações identificados antes de qualquer migração ou exclusão.

**Entregue em 2026-08-26:** Pages, ViewModels, BLoC, componentes, rotas e
artefatos legados foram inventariados. Android e iOS permanecem como targets
mantidos e os fluxos dependentes de validação nativa foram registrados. A
auditoria encontrou duas violações confirmadas em `StopWatchPage` e pontos de
acoplamento a revisar, sem acesso direto de outras Pages a repositories ou ao
injetor. A linha de base passou com 351 testes, analyzer sem issues e diff
válido. Todos os achados foram classificados entre correção local e possível
backlog futuro.

**Inventário inicial:** foram identificadas sete Pages roteadas, seis
ViewModels, um BLoC e `AppAppearanceState` como estado compartilhado. Os
componentes estão distribuídos entre widgets locais de `ui/pages`, widgets
comuns em `features/widgets`, `edit_training_dialog` e `precise_stopwatch`; não
existe ainda `ui/components`. Rotas, nomes e argumentos estão concentrados em
`core/routing`. Permanecem como candidatos a legado `LegacySettingsSink`,
`AppSettings`, adapters e models em `common`, `StopwatchFunctions` e a
organização paralela entre `features` e `ui`. Não foram encontrados Managers
ou Stores. `UserController` foi registrado como controller visual de diálogo,
não como legado confirmado.

**Mapa inicial de dependências:** `AboutPage` usa somente metadados estáticos e
tema; `HistoryPage`, `SettingsPage` e `TrainingsPage` recebem uma ViewModel;
`UsersPage` recebe `UsersViewModel` e `StopwatchPageViewModel`;
`PersonalTrainingPage` recebe `StopwatchSessionViewModel` e `HistoryViewModel`.
Nenhuma dessas Pages acessa repository, injetor ou filesystem diretamente.
`StopWatchPage` é a exceção confirmada: acessa `AppSettings.instance` e chama
diretamente `FlutterNativeSplash.remove()`. Os dois pontos entram na tarefa 2.
Os casos com duas fronteiras de apresentação serão revisados como possível
acoplamento, sem classificá-los antecipadamente como violação.

**Plataformas e validação manual:** o repositório mantém projetos nativos para
Android e iOS; não existem targets Web, Linux, macOS ou Windows. Em ambas as
plataformas devem ser validados bootstrap e splash, SQLite e persistência,
configurações, seleção/compressão/armazenamento de imagens, sessões de
cronômetro, navegação, dialogs, tema, contraste, locale, unidades, geração de
PDF, compartilhamento, cancelamento, cliente de e-mail com anexo e links
externos. Os adapters automatizados continuam cobrindo regras e falhas, mas não
substituem a confirmação das integrações nativas.

**Linha de base:** `flutter analyze` terminou sem issues, a suíte completa
passou com 351 testes e `git diff --check` não encontrou problemas. As buscas
confirmaram os dois acessos diretos já registrados em `StopWatchPage`, não
encontraram Pages consultando repositories ou o injetor e mantiveram os
artefatos de `common` como candidatos à auditoria de consumidores. Avisos de
chaves de localização emitidos por testes de widget são informativos do
harness atual e não representam falha da suíte ou issue do analyzer.

**Classificação:** entram no backlog 010 a remoção de `AppSettings.instance` e
da chamada de splash em `StopWatchPage`, a revisão das Pages que recebem duas
ViewModels, a auditoria e remoção de adapters, models, singleton, helpers e
dependências sem consumidores, a migração de `training_domain_adapter.dart`, a
consolidação comprovada de widgets e os avisos locais dos arquivos e testes
migrados. Atualizações amplas de Flutter/plugins, mudanças nativas, alteração
das plataformas suportadas, redesenho visual ou mudança funcional recebem
backlog próprio caso sejam necessárias.

### 2. Consolidar as fronteiras de Pages, ViewModels e BLoCs

**Dependência:** tarefa 1.

- [x] Fazer Pages dependerem somente de ViewModels/BLoCs e componentes
      adequados ao fluxo.
- [ ] Remover `BuildContext`, widgets, focus, controllers visuais, dialogs,
      snackbars e navegação de ViewModels/BLoCs.
- [ ] Encapsular intenções assíncronas em Commands ou estados equivalentes,
      preservando erros apresentáveis.
- [ ] Impedir acesso direto de Pages a repositories, serviços de plataforma e
      singletons de negócio.
- [ ] Atualizar testes unitários das fronteiras afetadas.

**Fronteiras das Pages:** `FlutterNativeSplash.remove()` foi transferido de
`StopWatchPage` para o composition root. O acesso a `AppSettings.instance` foi
substituído por uma instância explícita de `SettingsViewModel`, que expõe e
persiste o toggle de brilho. Rotas, aplicação e testes passaram a fornecer essa
dependência. O novo comportamento possui cobertura unitária e de widget. A
busca final não encontrou Pages acessando diretamente repository, service,
plugin, injetor ou singleton de negócio.

**Resultado esperado:** apresentação coordena interação visual nas Pages e
estado/operações testáveis em ViewModels/BLoCs, sem dependências invertidas.

### 3. Revisar e uniformizar navegação e argumentos

**Dependência:** tarefa 2.

- [ ] Confirmar que nomes e paths permanecem centralizados no `go_router`.
- [ ] Substituir argumentos soltos por tipos estáveis quando houver dados
      compostos entre rotas.
- [ ] Remover rotas, argumentos, factories e dependências de navegação sem
      consumidores.
- [ ] Manter navegação exclusivamente na camada de apresentação.
- [ ] Cobrir construção, recriação e argumentos relevantes em testes de rota.

**Resultado esperado:** rotas e argumentos possuem uma fonte central e não
transportam dependências legadas ou detalhes de plataforma.

### 4. Tornar explícitos os estados e as interações de tela

**Dependências:** tarefas 2 e 3.

- [ ] Revisar loading, vazio, sucesso e erro nos fluxos relevantes.
- [ ] Preservar dialogs, snackbars, menus, seleção, focus e controllers nas
      Pages responsáveis.
- [ ] Bloquear disparos incompatíveis enquanto operações estiverem em execução.
- [ ] Garantir feedback visível para falhas esperadas sem exceções cruas.
- [ ] Adicionar ou atualizar testes de widget para os estados afetados.

**Resultado esperado:** cada fluxo importante apresenta estados previsíveis e
testáveis sem transferir responsabilidades visuais para ViewModels/BLoCs.

### 5. Consolidar componentes e tema sem redesenho

**Dependência:** tarefa 1; pode acompanhar as tarefas 2 a 4.

- [ ] Mapear widgets com uso real em duas ou mais features.
- [ ] Mover somente esses widgets para `ui/components`, preservando os demais
      junto das features consumidoras.
- [ ] Remover componentes genéricos sem consumidores e abstrações duplicadas.
- [ ] Uniformizar usos de tema e estilos nos arquivos migrados sem redesenhar a
      interface.
- [ ] Preservar acessibilidade, semântica e comportamento dos componentes
      alterados com testes proporcionais ao risco.

**Resultado esperado:** compartilhamento de UI reflete reutilização comprovada,
sem criar uma biblioteca genérica prematura ou alterar o desenho do produto.

### 6. Resolver avisos e depreciações dentro do escopo aprovado

**Dependências:** tarefas 2 a 5.

- [ ] Corrigir imports obsoletos, APIs depreciadas e avisos diretamente ligados
      aos arquivos migrados.
- [ ] Aplicar substituições locais que não alterem comportamento observável.
- [ ] Não ampliar o escopo por mensagens informativas de dependências externas.
- [ ] Registrar em backlog próprio qualquer correção que exija atualização
      ampla, mudança nativa ou redesenho arquitetural.
- [ ] Confirmar que `flutter analyze` não introduz erros ou avisos novos.

**Resultado esperado:** o código migrado usa APIs atuais quando a troca é segura,
e problemas maiores permanecem visíveis sem desviar o backlog.

### 7. Remover legado e dependências sem consumidores

**Dependências:** tarefas 2 a 6.

- [ ] Remover managers, stores, controllers, singletons e adapters temporários
      somente após confirmar ausência de consumidores.
- [ ] Migrar o consumidor remanescente de `training_domain_adapter.dart` em
      `StopwatchFunctions.speedCalc` ou documentar impedimento comprovado.
- [ ] Remover models, helpers e testes de caracterização que tenham sido
      integralmente substituídos.
- [ ] Auditar o `pubspec` e remover apenas dependências comprovadamente sem uso
      em código, testes, geração, assets ou plataformas nativas.
- [ ] Confirmar por busca que os fluxos migrados não conservam imports ou
      factories legados.

**Resultado esperado:** não existe arquitetura paralela sem consumidores e as
dependências declaradas correspondem ao produto efetivamente entregue.

### 8. Atualizar documentação e validar a entrega

**Dependências:** tarefas 1 a 7.

- [ ] Atualizar README, documentação arquitetural e acompanhamento dos
      backlogs concluídos para refletir a implementação real.
- [ ] Executar `dart format` nos arquivos alterados.
- [ ] Executar testes focados de ViewModels/BLoCs, rotas, estados e widgets.
- [ ] Executar a suíte completa com `flutter test`.
- [ ] Executar `flutter analyze` sem novos erros ou avisos.
- [ ] Executar `git diff --check` e buscas finais de fronteiras e legado.
- [ ] Validar manualmente os fluxos suportados em cada plataforma mantida.
- [ ] Registrar resultados, limitações e eventuais backlogs derivados.
- [ ] Mover o backlog 010 e suas tasks para `closed/` somente após cumprir todos
      os critérios de aceite.

**Resultado esperado:** a arquitetura documentada corresponde ao código, os
fluxos suportados permanecem funcionais e o encerramento possui evidências de
testes, análise, buscas e validação manual.

## Regra de conclusão

O backlog somente pode ser encerrado quando Pages dependerem das fronteiras de
apresentação aprovadas; ViewModels/BLoCs estiverem livres de contexto e estado
visual; navegação e argumentos permanecerem centralizados; estados importantes
forem explícitos; legado e dependências sem consumidores forem removidos; a
documentação refletir a entrega; e testes, análise, diff e validações manuais
terminarem sem novos problemas.
