# 011 — Tarefas de ajustes de interface e interação

## Objetivo

Entregar os ajustes aprovados para idioma, ações protegidas e espaçamento do
cronômetro com alterações locais e proporcionais ao problema observado.

## Decisões já tomadas

- `context.locale` será a única fonte efetivamente usada pelo `MaterialApp` e
  pelas traduções;
- `AppAppearanceState.locale` continuará representando o locale desejado e
  persistido;
- o seletor exibirá bandeira e nome legível, sem expor `es_null`;
- toque comum em **Reset** e **Finalizar** abre confirmação; pressão longa
  executa diretamente;
- um `SnackBar` contextual explica o atalho na primeira pausa e sua exibição
  fica registrada nas configurações;
- **Reset** preserva o treino e seus registros sem adicionar finalização;
- as cores atuais dos botões são mantidas;
- o espaçamento usa `Column(spacing: 4)` e a orientação permanece fixa.

## Ordem de execução

### 1. Identificar a causa da defasagem de idioma

**Dependência:** backlog 010 concluído.

- [x] Comparar o locale selecionado, o estado do `AppAppearanceState`, o locale
      do `MaterialApp` e o locale do `easy_localization`.
- [x] Confirmar que o `MaterialApp` usa imediatamente
      `appearanceState.locale`, enquanto as traduções usam `context.locale` e
      recebem a atualização somente no callback pós-frame.
- [x] Confirmar que a fila de persistência do `SettingsViewModel` não causa a
      defasagem observada.
- [x] Identificar que `AppLanguage.localeCode` interpola um `countryCode` nulo e
      produz `es_null`.

**Resultado:** a causa foi localizada na aplicação concorrente de dois locales;
o rótulo espanhol possui um segundo defeito, independente da sincronização.

**Entregue em 2026-08-27:** a inspeção do fluxo confirmou que o seletor e o
`MaterialApp` avançam pelo `AppAppearanceState`, enquanto os textos permanecem
no `context.locale` anterior até a sincronização posterior. Não foi necessário
criar testes de caracterização para localizar o problema.

### 2. Corrigir a seleção e a apresentação do idioma

**Dependência:** tarefa 1 concluída.

- [x] Fazer o `MaterialApp` consumir `context.locale` em vez de
      `appearanceState.locale`.
- [x] Preservar a sincronização do locale desejado por
      `context.setLocale(appearanceState.locale)`.
- [x] Exibir no seletor a bandeira e `AppLanguage.language`.
- [x] Tornar `AppLanguage.localeCode` seguro para locales sem `countryCode`, se
      o getter continuar necessário.
- [x] Confirmar manualmente que cada seleção atualiza imediatamente seletor,
      textos e valor persistido para o mesmo idioma.

**Resultado esperado:** interface e seletor exibem sempre o mesmo idioma, sem
defasagem e sem rótulos contendo `null`.

**Entregue em 2026-08-27:** o `MaterialApp` passou a consumir
`context.locale`, mantendo a sincronização do locale desejado pelo
`AppAppearanceState`. O seletor agora apresenta bandeira e nome legível, e
`AppLanguage.localeCode` não interpola mais um país nulo. A seleção direta e a
sincronização visual foram confirmadas manualmente pelo usuário.

### 3. Persistir a exibição da dica contextual

**Dependência:** decisões do backlog fechadas; independente da tarefa 2.

- [ ] Adicionar às configurações um booleano que informe se a dica das ações
      protegidas já foi apresentada.
- [ ] Atualizar model, form data, mapper e armazenamento, usando `false` como
      padrão compatível com bancos existentes.
- [ ] Expor no `SettingsViewModel` uma operação idempotente para marcar a dica
      como apresentada.
- [ ] Cobrir leitura, persistência e compatibilidade do novo campo nos testes
      existentes de configurações.

**Resultado esperado:** a dica aparece apenas uma vez e permanece dispensada
depois que o aplicativo é reiniciado.

### 4. Implementar as ações protegidas

**Dependência:** tarefa 3.

- [ ] Ligar o toque comum de **Reset** e **Finalizar** a confirmações mantidas
      na apresentação.
- [ ] Informar no **Reset** que os registros permanecem salvos sem finalização
      e, em **Finalizar**, que tempo e registros pendentes serão salvos.
- [ ] Fazer confirmação e pressão longa chamarem os mesmos métodos da sessão,
      sem duplicar regras.
- [ ] Preservar a execução direta por pressão longa e adicionar feedback
      tátil.
- [ ] Exibir o `SnackBar` na primeira pausa, marcar a dica como apresentada e
      evitar repetição na mesma execução se a persistência falhar.
- [ ] Preservar bloqueios durante operações pendentes, cores atuais, rótulos,
      tooltips e semântica acessível.
- [ ] Cobrir toque, cancelamento, confirmação e pressão longa nos testes de
      widget afetados.

**Resultado esperado:** o toque torna as ações descobríveis e seguras, enquanto
a pressão longa permanece como atalho para usuários experientes.

### 5. Aplicar o espaçamento do cronômetro

**Dependência:** independente das tarefas 2 a 4.

- [ ] Aplicar `spacing: 4` à `Column` que organiza `StopwatchDisplay` e
      `StopwatchButtonBar` no `PreciseStopwatch`.
- [ ] Não inserir `SizedBox`, margens nos filhos ou alteração da orientação
      para produzir o espaçamento.
- [ ] Confirmar ausência de overflow e preservação das dimensões do componente.

**Resultado esperado:** mostrador e botões ficam separados por 4 pixels sem
outras mudanças de layout.

### 6. Traduzir e validar a entrega

**Dependências:** tarefas 2 a 5.

- [ ] Adicionar dica, confirmações, botões, tooltips e semântica aos três
      arquivos de tradução.
- [ ] Atualizar o backlog e a documentação afetada com o resultado entregue.
- [ ] Executar `dart format`, testes afetados, suíte completa,
      `flutter analyze` e `git diff --check`.
- [ ] Validar manualmente em Android e iOS: idiomas, reinicialização, toque,
      cancelamento, confirmação, pressão longa, feedback tátil, dica única e
      espaçamento.
- [ ] Registrar resultados e mover backlog e tasks para `closed/` somente após
      cumprir os critérios de aceite.

**Resultado esperado:** os ajustes estão traduzidos, verificados e documentados
sem regressões conhecidas.

## Regra de conclusão

O backlog somente pode ser encerrado quando o idioma selecionado, aplicado e
persistido for o mesmo; nenhum rótulo contiver `null`; toque e pressão longa
possuírem os comportamentos aprovados; a dica for persistida e não recorrente;
o espaçamento de 4 pixels estiver aplicado pela `Column`; e as validações
automatizadas e manuais terminarem sem novos problemas.
