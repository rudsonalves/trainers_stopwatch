# 004 — Tarefas para configurações em MVVM

## Objetivo

Organizar a migração do fluxo de configurações para MVVM conforme as decisões
registradas em
[`004-configuracoes-mvvm.md`](004-configuracoes-mvvm.md), usando a feature como
primeiro fluxo vertical sobre a fundação e a persistência já entregues.

## Decisões já tomadas

- `AppAppearanceState` será a única fonte observável global de tema,
  contraste e idioma;
- `AppAppearanceState` será singleton por registro no `AutoInjector` e
  recebido por construtor pelo `MyMaterialApp`;
- `SettingsRepository` continuará responsável pela persistência e pelo cache de
  domínio;
- `SettingsViewModel` receberá suas dependências pelo construtor e sincronizará
  o estado global por meio de `AppAppearanceState`;
- toda alteração válida da `SettingsPage` será persistida imediatamente, sem
  botão de confirmação e sem depender do fechamento da página;
- `AppSettings` permanecerá como adapter temporário para consumidores ainda não
  migrados;
- o sistema de tutorial já foi removido e não voltará a integrar settings ou a
  UI;
- `BuildContext`, controllers visuais e navegação permanecem na Page;
- Navigator 1.0 e rotas nomeadas serão preservados;
- não será criado UseCase para o fluxo direto entre ViewModel e repository.

## Ordem de execução

### 1. Revisar o contrato de settings entregue pelo backlog 003

**Dependência:** backlog 003 concluído e remoção prévia do tutorial.

- [x] Confirmar que `SettingsRepository` expõe carregamento, atualização e o
      valor atual em tipos de domínio.
- [x] Preservar o cache somente no repository, sem duplicá-lo nos ViewModels.
- [x] Confirmar que falhas de leitura e escrita chegam como
      `Result`/`AppError`.
- [x] Preservar os defaults atuais de distâncias, unidade, brilho, contraste,
      idioma e intervalo de atualização.
- [x] Manter a coluna legada `showTutorial` ignorada, sem migration ou
      reconstrução de banco apenas para removê-la.
- [x] Ajustar o contrato ou a implementação somente se houver uma necessidade
      concreta dos ViewModels deste backlog.
- [x] Não introduzir DAO adicional, novo cache ou UseCase sem coordenação real.

**Validação:** o contrato e a implementação entregues pelo backlog 003 já
atendem à tarefa, sem necessidade de alteração. Em 2026-08-13, os 20 testes de
domínio, service, repository/cache e adapters relacionados a settings foram
executados com sucesso.

**Resultado esperado:** o repository existente está pronto para ser consumido
pelos ViewModels sem expor SQLite, maps ou estado visual.

### 2. Criar o estado global observável da aplicação

**Dependência:** tarefa 1.

- [x] Criar `AppAppearanceState` na camada de UI, sem herdar de model de
      persistência.
- [x] Expor brilho, contraste e idioma como estado observável único.
- [x] Receber o estado inicial explicitamente ou inicializá-lo a partir de uma
      dependência recebida pelo construtor, sem consultar o injector.
- [x] Oferecer operações explícitas para sincronizar tema, contraste e idioma
      após carregamento ou edição.
- [x] Não armazenar distâncias, intervalo de atualização, loading, erro,
      `BuildContext`, widgets, `FocusNode`s ou navegação.
- [x] Manter tipos de Flutter restritos à camada de UI e realizar conversão para
      os tipos puros de domínio na borda apropriada.
- [x] Implementar descarte correto dos recursos observáveis que o objeto
      possuir.

**Validação:** `AppAppearanceState` foi implementado como `ChangeNotifier`
com estado único de `Brightness`, `AppContrast` e `Locale`, inicialização e
sincronização explícitas a partir de `Settings`. Em 2026-08-13, seus quatro
testes unitários passaram e `flutter analyze` terminou sem issues.

**Resultado esperado:** tema, contraste e idioma possuem uma única fonte
observável global, independente de persistência e do ciclo de vida da página de
configurações.

### 3. Criar o SettingsViewModel e seus Commands

**Dependências:** tarefas 1 e 2.

- [x] Criar `SettingsViewModel` com `SettingsRepository` e
      `AppAppearanceState` recebidos por construtor.
- [x] Expor um Command para carregar configurações.
- [x] Expor Command para persistir cada alteração válida imediatamente.
- [x] Representar no ViewModel os valores editáveis de distâncias, unidade,
      brilho, contraste, idioma e intervalo de atualização.
- [x] Converter valores de apresentação para `Settings` de domínio antes de
      chamar o repository.
- [x] Atualizar o estado global de tema, contraste e idioma de modo imediato e
      manter comportamento explícito em caso de falha de persistência.
- [x] Impedir que edições rápidas sejam descartadas quando um salvamento já
      estiver em execução, serializando alterações ou enfileirando o estado
      válido mais recente.
- [x] Expor loading, sucesso e falha pelos Commands/estado observável, sem lançar
      exceções cruas para a Page.
- [x] Manter o último estado persistido conhecido para restaurar ou reapresentar
      valores coerentes após falha.
- [x] Não receber `BuildContext`, controllers de texto, widgets, rotas ou
      callbacks de navegação.

**Validação:** `SettingsViewModel` foi implementado com estado imutável de
apresentação, Commands de carga e gravação, atualização global otimista,
serialização do estado válido mais recente e rollback para o último valor
persistido. Em 2026-08-13, os seis testes do ViewModel e os quatro testes do
estado global passaram; `flutter analyze` terminou sem issues.

**Resultado esperado:** toda operação de configurações passa por um ViewModel
testável, com persistência imediata e sem perda silenciosa de edições.

### 4. Registrar e inicializar o estado global e o ViewModel no composition root

**Dependência:** tarefa 3.

- [x] Registrar `AppAppearanceState` como singleton no `AutoInjector`.
- [x] Registrar `SettingsViewModel` com ciclo de vida compatível com a página e
      suas dependências explícitas.
- [x] Não acessar o injector dentro de ViewModels, Pages ou widgets.
- [x] Integrar o carregamento inicial ao bootstrap sem abrir uma segunda leitura
      concorrente de settings.
- [x] Garantir que o estado global esteja inicializado antes da construção do
      `MaterialApp`.
- [x] Passar `AppAppearanceState` e factories necessárias a partir de
      `main.dart`/composition root.
- [x] Testar a resolução da cadeia e a identidade singleton do estado global.

**Validação:** `AppAppearanceState` foi registrado como singleton e
`SettingsViewModel` como transient. O bootstrap sincroniza o estado global a
partir do cache preenchido pelo carregamento legado, sem nova leitura, antes de
`runApp`; `main.dart` injeta a mesma instância em `MyMaterialApp`. O teste do
composition root confirmou os ciclos de vida. Em 2026-08-13, os 11 testes
relacionados passaram e `flutter analyze` terminou sem issues.

**Resultado esperado:** a composição e a inicialização das configurações são
explícitas, ordenadas e resolvidas em um único ponto.

### 5. Migrar MyMaterialApp para o estado global

**Dependências:** tarefas 2 e 4.

- [x] Fazer `MyMaterialApp` receber `AppAppearanceState` pelo construtor.
- [x] Remover de `MyMaterialApp` o acesso a `AppSettings.instance`.
- [x] Reconstruir `MaterialApp` a partir do estado observável de brilho e
      contraste do estado global.
- [x] Sincronizar o idioma observado com `EasyLocalization` na borda de UI, sem
      colocar `BuildContext` no estado global.
- [x] Preservar temas, contrastes, locales suportados, rota inicial e tabela de
      rotas atuais.
- [x] Preservar Navigator 1.0 e não introduzir nova solução de roteamento.

**Validação:** `MyMaterialApp` observa diretamente `AppAppearanceState`, usa
seus valores para locale, brilho e contraste e sincroniza `EasyLocalization`
após o frame na borda da UI. O acesso ao singleton legado foi removido sem
alterar a rota inicial, a tabela de rotas ou o Navigator 1.0. Em 2026-08-13,
os 11 testes relacionados passaram e `flutter analyze` terminou sem issues.

**Resultado esperado:** a raiz da UI reage ao estado global injetado e deixa de
depender do singleton legado de settings.

### 6. Migrar SettingsPage para SettingsViewModel

**Dependências:** tarefas 3 a 5.

- [x] Fazer `SettingsPage` receber `SettingsViewModel` por construtor através da
      composição da rota.
- [x] Remover da Page todo acesso direto a `AppSettings.instance`, repository,
      service ou banco.
- [x] Executar o Command de carregamento no início do ciclo de vida adequado.
- [x] Renderizar loading, valores carregados e falha observável sem redesenhar a
      tela.
- [x] Encaminhar cada alteração válida ao ViewModel para persistência imediata.
- [x] Remover `_edited`, salvamento em `PopScope` e qualquer dependência do
      fechamento da página para persistir.
- [x] Manter `BuildContext`, feedback visual e controllers de texto na UI; a
      sincronização de locale permanece na raiz `MyMaterialApp`.
- [x] Desabilitar ou coordenar controles durante operações quando necessário
      para evitar comandos concorrentes e perda de edição.
- [x] Preservar a navegação atual e a classe de rota `SettingsOverlay` enquanto
      ela ainda for útil como fronteira de composição.

**Validação:** `SettingsOverlay` recebe e descarta o ViewModel transient criado
pela factory da rota; `SettingsPage` observa o ViewModel e seus Commands, exibe
progresso e falhas e encaminha alterações de aparência, idioma e refresh para
persistência imediata. Os campos de distância já leem `SettingsFormData`, mas
sua edição permanece para a tarefa 7. Em 2026-08-13, os 21 testes relacionados
passaram e `flutter analyze` terminou sem issues.

**Resultado esperado:** a página apresenta e edita configurações exclusivamente
por meio do `SettingsViewModel`.

### 7. Corrigir a edição de medidas e preservar o comportamento funcional

**Dependência:** tarefa 6.

- [x] Fazer os campos de split e lap entregarem alterações válidas ao
      `SettingsViewModel`, em vez de alterarem apenas controllers locais.
- [x] Manter `TextEditingController` e validação visual no widget/Page.
- [x] Preservar a unidade comum exigida pelo model de domínio para split e lap.
- [x] Persistir distância e unidade imediatamente após uma edição válida.
- [x] Não persistir estados intermediários inválidos enquanto o usuário digita.
- [x] Preservar os valores e defaults atuais sem introduzir novas unidades ou
      regras funcionais.
- [x] Garantir que brilho, contraste, idioma e intervalo de atualização também
      mantenham o comportamento atual após reabrir a página/aplicação.

**Validação:** `LengthLineEdit` mantém seu controller local, entrega valores
positivos após debounce de 400 ms ou submissão e ignora estados inválidos. A
seleção de unidade atualiza o único `DistanceUnit` compartilhado por split e
lap. Testes confirmam callbacks válidos e persistência de distâncias, unidade e
refresh. Em 2026-08-13, os 13 testes relacionados passaram e `flutter analyze`
terminou sem issues.

**Resultado esperado:** todos os controles exibidos na tela alteram de fato o
estado persistido, sem ampliar o escopo funcional.

### 8. Manter o adapter legado sincronizado

**Dependências:** tarefas 3, 4 e 6.

- [ ] Manter `AppSettings` apenas para consumidores ainda não migrados nos
      backlogs seguintes.
- [ ] Retirar de `AppSettings` a responsabilidade de ser a fonte observável
      global de tema, contraste e idioma.
- [ ] Fazer o adapter legado refletir cada atualização persistida com sucesso
      sem executar uma segunda escrita no repository.
- [ ] Garantir que consumidores legados de distâncias, unidade, intervalo,
      paths e demais valores continuem recebendo dados coerentes.
- [ ] Evitar ciclos de sincronização entre `SettingsViewModel`,
      `AppAppearanceState`, repository e `AppSettings`.
- [ ] Documentar no código o backlog responsável por remover cada acesso legado
      remanescente.
- [ ] Não migrar consumidores fora da feature de settings, exceto pelo ajuste
      mínimo necessário para manter compatibilidade.

**Resultado esperado:** a feature migrada usa MVVM e os fluxos ainda legados
continuam funcionais com uma ponte temporária de mão única.

### 9. Testar os comportamentos alterados

**Dependências:** tarefas 1 a 8.

- [ ] Testar carregamento bem-sucedido e falha no `SettingsViewModel`.
- [ ] Testar persistência imediata de cada grupo de configuração alterado.
- [ ] Testar conversão entre tipos de UI e tipos puros de domínio.
- [ ] Testar atualização global de tema, contraste e idioma.
- [ ] Testar o comportamento escolhido para falha após uma atualização global
      otimista.
- [ ] Testar que alterações rápidas não são perdidas durante uma escrita em
      andamento.
- [ ] Testar que falha de escrita preserva o cache anterior do repository e um
      estado observável coerente.
- [ ] Testar que o adapter legado é atualizado somente após persistência
      bem-sucedida.
- [ ] Não ampliar cobertura de widgets ou repository sem comportamento novo.

**Resultado esperado:** os limites entre Page, ViewModels, repository, estado
global e adapter legado estão cobertos nos caminhos que mudaram.

### 10. Revisar fronteiras e validar a entrega

**Dependências:** tarefas 1 a 9.

- [ ] Confirmar que `SettingsPage` não acessa singleton, repository, service,
      banco ou injector.
- [ ] Confirmar que nenhum ViewModel recebe `BuildContext`, widget, controller
      visual ou dependência obtida globalmente.
- [ ] Confirmar que o repository continua sendo o único cache de domínio.
- [ ] Confirmar que `AppAppearanceState` contém somente estado global de
      apresentação.
- [ ] Confirmar que o tutorial não reapareceu em código, dependências,
      configurações ou UI.
- [ ] Executar `dart format` nos arquivos alterados.
- [ ] Executar os testes afetados e a suíte completa com `flutter test`.
- [ ] Executar `flutter analyze` sem novas issues.
- [ ] Executar `git diff --check`.
- [ ] Validar manualmente carregamento, edição e persistência de distâncias,
      unidade, tema, contraste, idioma e intervalo de atualização.
- [ ] Validar manualmente que consumidores legados observam os novos valores
      após a alteração.
- [ ] Atualizar o acompanhamento de `004-configuracoes-mvvm.md` com limitações e
      decisões surgidas durante a implementação.
- [ ] Marcar este checklist somente após todas as verificações.
- [ ] Mover backlog e tasks concluídos para `doc/backlog/closed/`.

**Resultado esperado:** configurações validam o primeiro fluxo MVVM de ponta a
ponta, a aplicação permanece executável e o backlog 005 pode reutilizar o
padrão entregue.

## Regra de conclusão

Os testes devem acompanhar apenas o comportamento alterado. Uma tarefa só pode
ser concluída quando não houver acesso oculto a dependências, perda de edições
durante persistência imediata, segunda fonte de cache de domínio ou retorno do
tutorial removido. `Changelog.md` não faz parte deste fluxo e é atualizado por
processo externo.
