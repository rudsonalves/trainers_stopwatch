# 011 — Tarefas de ajustes de interface e interação

## Objetivo

Entregar os ajustes aprovados para as ações protegidas do cronômetro, o
espaçamento entre mostrador e botões e a seleção de idioma, preservando as
regras temporais, a persistência existente e a orientação fixa do aplicativo.

## Decisões já tomadas

- toque comum em **Reset** e **Finalizar** abre uma confirmação; pressão longa
  executa diretamente;
- um `SnackBar` contextual explica o atalho quando as ações aparecem pela
  primeira vez;
- a exibição da dica é registrada nas configurações persistidas;
- **Reset** preserva o treino e seus registros sem adicionar finalização;
- as cores atuais dos botões são mantidas como indicação complementar;
- `AppAppearanceState` representa o locale desejado, mas `context.locale` é a
  única fonte efetivamente usada pelo `MaterialApp` e pelas traduções;
- a fila de persistência das configurações é preservada;
- o espaçamento usa `Column(spacing: 4)` no `PreciseStopwatch`;
- a orientação do aplicativo permanece fixa.

## Ordem de execução

### 1. Caracterizar os comportamentos atuais e a linha de base

**Dependência:** backlog 010 concluído e decisões do backlog 011 fechadas.

- [ ] Reproduzir em teste de widget a defasagem entre a opção selecionada e o
      idioma aplicado aos textos da página de configurações.
- [ ] Caracterizar a sequência observada `pt_BR` com textos em inglês,
      `es_null` com textos em português e `en_US` com textos em espanhol.
- [ ] Adicionar teste que exponha o rótulo incorreto `es_null` sem consolidá-lo
      como comportamento esperado da entrega.
- [ ] Caracterizar toque comum e pressão longa atuais em **Reset** e
      **Finalizar**, incluindo bloqueio durante operação pendente.
- [ ] Registrar a linha de base de testes focados, `flutter analyze` e
      `git diff --check` antes das alterações.

**Resultado esperado:** os defeitos e comportamentos protegidos possuem
reprodução automatizada suficiente para orientar as correções sem regressão.

### 2. Corrigir a aplicação e a apresentação do idioma

**Dependência:** tarefa 1.

- [ ] Eliminar a dupla aplicação do locale entre `MaterialApp`,
      `AppAppearanceState` e `easy_localization`.
- [ ] Manter `AppAppearanceState` como estado desejado e fazer o
      `MaterialApp`/traduções consumirem `context.locale` como locale efetivo.
- [ ] Garantir que uma seleção atualize diretamente os textos, o valor exibido
      e o estado persistido para o mesmo locale.
- [ ] Exibir bandeira e nome legível do idioma no seletor, sem interpolar
      `countryCode` nulo nem expor código interno como rótulo principal.
- [ ] Preservar a fila atual de persistência e testar alternância rápida entre
      os três idiomas, comprovando que somente o último permanece aplicado e
      salvo.
- [ ] Testar carga inicial, mudança individual, falha com rollback e
      reinicialização com cada locale suportado.

**Resultado esperado:** seletor, textos, `AppAppearanceState`,
`easy_localization` e repository permanecem sincronizados sem transições por
idiomas intermediários ou rótulos nulos.

### 3. Persistir a descoberta das ações protegidas

**Dependência:** tarefa 1; pode ser executada depois ou em paralelo à tarefa 2.

- [ ] Adicionar às configurações um estado explícito que registre se a dica
      das ações protegidas já foi apresentada.
- [ ] Atualizar model, form data, mapper, service/schema e repository somente
      nos pontos necessários, mantendo compatibilidade com bancos existentes.
- [ ] Definir `false` como valor padrão para instalações e bancos que ainda não
      possuam o campo.
- [ ] Expor no `SettingsViewModel` uma operação idempotente para marcar a dica
      como apresentada, reutilizando a fila e o tratamento de falha existentes.
- [ ] Testar valor padrão, leitura, persistência, idempotência, migração e
      rollback em caso de falha.

**Resultado esperado:** a apresentação da dica sobrevive à reinicialização do
aplicativo sem introduzir uma segunda tecnologia de persistência.

### 4. Implementar toque, confirmação, atalho e orientação contextual

**Dependência:** tarefa 3.

- [ ] Ligar o toque comum de **Reset** e **Finalizar** a confirmações visuais,
      mantendo dialogs e `SnackBar` na apresentação e fora do ViewModel/BLoC.
- [ ] Usar textos específicos: **Reset** informa que os registros permanecem
      salvos sem finalização; **Finalizar** informa que tempo e registros
      pendentes serão salvos.
- [ ] Fazer a confirmação executar os mesmos métodos de sessão usados pelo
      atalho, sem duplicar regras temporais ou de persistência.
- [ ] Preservar a pressão longa como execução direta e emitir feedback tátil
      quando reconhecida pela plataforma.
- [ ] Apresentar o `SnackBar` somente na primeira transição relevante para o
      estado pausado e marcar a dica como apresentada.
- [ ] Definir comportamento recuperável se a persistência da dica falhar, sem
      bloquear os controles do cronômetro nem repetir disparos na mesma tela.
- [ ] Manter botões desabilitados durante escritas e operações incompatíveis.
- [ ] Adicionar semântica e tooltips traduzidos para toque, confirmação e
      atalho de pressão longa.

**Resultado esperado:** usuários iniciantes descobrem as ações pelo toque e
pela dica contextual, enquanto usuários experientes preservam o atalho seguro
por pressão longa.

### 5. Ajustar espaçamento e validar a apresentação do cronômetro

**Dependência:** tarefa 1; pode acompanhar as tarefas 2 a 4.

- [ ] Aplicar `spacing: 4` à `Column` que organiza `StopwatchDisplay` e
      `StopwatchButtonBar` no `PreciseStopwatch`.
- [ ] Não inserir `SizedBox`, margens internas nos filhos ou alteração da
      orientação fixa para produzir esse espaçamento.
- [ ] Preservar as cores atuais de **Reset** e **Finalizar**.
- [ ] Confirmar que cor, ícone, rótulo, tooltip e semântica distinguem as
      ações sem depender exclusivamente da cor.
- [ ] Atualizar testes de layout para comprovar o espaçamento e ausência de
      overflow nas larguras e escalas de texto suportadas.

**Resultado esperado:** mostrador e botões possuem separação visual consistente
sem alterar dimensões, orientação ou identidade visual aprovada.

### 6. Traduzir, documentar e validar a entrega

**Dependências:** tarefas 2 a 5.

- [ ] Adicionar os textos de dica, confirmação, botões, tooltips e semântica a
      todos os arquivos de tradução suportados.
- [ ] Atualizar o backlog e a documentação afetada para refletir a
      implementação efetivamente entregue.
- [ ] Executar `dart format` nos arquivos alterados.
- [ ] Executar testes focados de configurações, aparência, localização,
      sessão, botões e widgets do cronômetro.
- [ ] Executar a suíte completa com `flutter test`.
- [ ] Executar `flutter analyze` sem novos erros ou avisos.
- [ ] Executar `git diff --check` e buscas finais por `es_null`, aplicações
      concorrentes de locale e textos não traduzidos.
- [ ] Validar manualmente em Android e iOS: seleção dos três idiomas,
      persistência após reiniciar, espaçamento, toque/cancelamento/confirmação,
      pressão longa, feedback tátil e exibição única da dica.
- [ ] Registrar resultados, limitações e eventuais backlogs derivados.
- [ ] Mover o backlog 011 e suas tasks para `closed/` somente depois de cumprir
      todos os critérios de aceite.

**Resultado esperado:** as três frentes estão traduzidas, testadas, documentadas
e verificadas nas plataformas mantidas, sem regressões conhecidas.

## Regra de conclusão

O backlog somente pode ser encerrado quando toque e pressão longa possuírem os
comportamentos aprovados; a dica for contextual, persistida e não recorrente; o
espaçamento de 4 pixels estiver aplicado pela `Column`; o seletor, os textos e a
persistência compartilharem o mesmo locale; nenhum rótulo contiver `null`; e
testes, análise, diff e validações manuais terminarem sem novos problemas.
