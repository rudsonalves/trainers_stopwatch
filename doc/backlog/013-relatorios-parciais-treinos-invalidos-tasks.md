# 013 — Tarefas de relatórios parciais com treinos inválidos

## Objetivo

Transformar a geração de relatórios em um fluxo parcial e explícito: validar
cada treino selecionado, comunicar e desmarcar os rejeitados e entregar os
treinos válidos somente após confirmação do usuário.

## Decisões já tomadas

- a validação ocorre antes do compartilhamento ou envio por e-mail;
- treino sem medições é rejeitado com um motivo compreensível;
- Share e Email usam as mesmas regras de resultado parcial;
- havendo treinos válidos e rejeitados, um diálogo rolável oferece
  **Cancelar** e **Continuar**;
- sem treinos válidos, o diálogo oferece somente **Fechar** e não inicia a
  entrega;
- rejeitados são removidos da seleção mesmo se a entrega for cancelada;
- a lista usa ícones distintos para não selecionado, selecionado e rejeitado;
- o motivo do erro pode ser consultado pelo indicador do treino;
- falhas globais permanecem separadas dos problemas atribuíveis a um treino.

## Ordem de execução

### 1. Modelar o resultado parcial da construção

**Dependência:** decisões do backlog fechadas.

- [x] Criar um valor imutável que contenha o `TrainingReportContent` válido e
      os problemas encontrados durante a construção.
- [x] Criar um problema de relatório associado ao `Training` rejeitado e ao
      `AppError` que explica sua rejeição.
- [x] Proteger as coleções contra mutação e definir igualdade adequada aos
      testes e consumidores.
- [x] Expor quantidades e estados derivados necessários para distinguir
      resultado totalmente válido, parcial e totalmente inválido.
- [x] Manter os novos valores livres de Flutter, widgets, localização,
      repositories e plugins.

**Resultado esperado:** o domínio representa simultaneamente conteúdo válido e
falhas específicas por treino sem recorrer a exceções ou detalhes da UI.

**Entregue em 2026-08-27:** `TrainingReportIssue` associa treino e `AppError`,
enquanto `TrainingReportBuildOutcome` protege a lista de problemas, expõe
contadores e distingue resultados vazio, completo, parcial e rejeitado. Os
models mantêm igualdade por valor e não dependem de apresentação ou
infraestrutura. Os 13 testes focados passaram e a análise estática dos arquivos
afetados não encontrou problemas.

### 2. Construir cada treino sem interromper os demais

**Dependência:** tarefa 1.

- [x] Refatorar a construção de seções para que cada treino possa ser
      transformado e validado independentemente.
- [x] Fazer o `BuildTrainingReportUseCase` percorrer toda a seleção, carregando
      os históricos e acumulando problemas por treino.
- [x] Classificar treino contendo somente o marco inicial como **treino sem
      medições**, preservando o `AppError` técnico para diagnóstico.
- [x] Preservar a ordem original entre os treinos válidos e entre os problemas
      apresentados.
- [x] Manter como falhas globais as validações que impedem interpretar toda a
      solicitação, sem convertê-las em rejeição arbitrária de um treino.
- [x] Cobrir seleção totalmente válida, parcialmente válida e totalmente
      inválida, incluindo falha de carga e histórico inconsistente.

**Resultado esperado:** uma falha específica não impede a avaliação dos
demais treinos e o resultado identifica precisamente cada rejeição.

**Entregue em 2026-08-27:** o builder passou a expor a construção individual
de seções e o `BuildTrainingReportUseCase` ganhou `buildOutcome()`, que percorre
toda a seleção, preserva a ordem, acumula problemas de identidade, carga,
ausência de medições e histórico inconsistente e mantém usuário sem identidade
como falha global. O `execute()` legado permanece temporariamente preservado
até a migração do pipeline na tarefa 3. Os 21 testes focados passaram e a
análise estática não encontrou problemas.

### 3. Separar preparação e entrega do relatório

**Dependência:** tarefa 2.

- [x] Ajustar a coordenação para preparar o conteúdo e os problemas antes de
      renderizar, gravar ou chamar plugins externos.
- [x] Permitir que Share e Email recebam conteúdo já validado, evitando montar
      o mesmo relatório novamente depois da confirmação da UI.
- [x] Preservar uma única implementação para renderização, arquivo temporário,
      entrega e limpeza nos dois canais.
- [x] Não criar PDF nem arquivo temporário quando nenhum treino for válido ou
      quando o usuário cancelar o resultado parcial.
- [x] Preservar como falhas globais os erros de PDF, bundle, filesystem,
      compartilhamento, e-mail e limpeza.
- [x] Atualizar os tipos de retorno para que os problemas não sejam perdidos em
      um `Unit` antes de alcançar a apresentação.

**Resultado esperado:** a aplicação conhece as rejeições antes da entrega e
continua usando um pipeline único para os treinos aprovados.

**Entregue em 2026-08-27:** a geração ganhou uma entrada para
`TrainingReportContent` já preparado; a entrega centraliza canal externo e
limpeza em um único método; e Share e Email expõem operações equivalentes para
conteúdo validado. O fluxo legado permanece disponível durante a migração do
ViewModel. Conteúdo sem seções é rejeitado antes da renderização, criação do
arquivo ou chamada de plugin, e cancelamento não precisa iniciar a entrega. Os
50 testes de relatórios passaram e a análise estática não encontrou problemas.

### 4. Representar problemas e reconciliar a seleção no ViewModel

**Dependência:** tarefa 3.

- [ ] Armazenar no `TrainingsViewModel` os problemas atuais indexados pela
      identidade persistida do treino.
- [ ] Expor consultas para o estado visual e o motivo de cada treino sem
      entregar coleções mutáveis à página.
- [ ] Remover de `_selectedTrainingIds` todos os rejeitados assim que a
      validação terminar, preservando os selecionados válidos.
- [ ] Manter os problemas visíveis quando o usuário cancelar o diálogo.
- [ ] Limpar problemas ao trocar usuário, recarregar treinos, excluir um treino
      ou retornar da edição de seu histórico, permitindo nova validação.
- [ ] Coordenar preparação, confirmação e entrega sem permitir Share e Email
      concorrentes ou depender de `BuildContext`.
- [ ] Cobrir atualização da seleção, persistência visual do erro, limpeza e
      ausência de entrega quando não houver conteúdo válido.

**Resultado esperado:** o ViewModel oferece todo o estado necessário para a
interação, sem incorporar diálogo, tradução ou detalhes de plataforma.

### 5. Apresentar diálogo e os três estados na lista

**Dependência:** tarefa 4.

- [ ] Adicionar ao `DismissibleTraining` um `trailing` com
      `Icons.radio_button_unchecked`, `Icons.check_circle` ou `Icons.error`, de
      acordo com o estado fornecido pelo ViewModel.
- [ ] Usar cores do `ColorScheme` apenas como indicação complementar e
      fornecer tooltip e semântica traduzidos para os três estados.
- [ ] Fazer o indicador de erro abrir uma mensagem com o motivo específico do
      treino, sem selecioná-lo novamente.
- [ ] Criar um diálogo com altura limitada e lista rolável contendo data, hora
      e motivo de cada treino rejeitado.
- [ ] Exibir **Cancelar** e **Continuar** quando houver conteúdo válido; exibir
      somente **Fechar** quando todos os treinos forem rejeitados.
- [ ] Fazer Share e Email reutilizarem o mesmo diálogo e continuarem apenas
      após confirmação.
- [ ] Substituir o `TPError` genérico desse fluxo por mensagens acionáveis,
      mantendo tratamento próprio para falhas globais.
- [ ] Adicionar todos os textos aos arquivos `pt-BR`, `en-US` e `es`.

**Resultado esperado:** a lista mantém cada problema visível e o usuário sabe
exatamente o que será entregue antes de confirmar a operação parcial.

### 6. Validar e documentar a entrega

**Dependências:** tarefas 1 a 5.

- [ ] Cobrir nos testes de domínio a ordem, os problemas por treino e os três
      tipos de resultado.
- [ ] Cobrir nos testes de UseCase preparação única, entrega somente dos
      válidos, cancelamento e separação das falhas globais.
- [ ] Cobrir nos testes de ViewModel a reconciliação e limpeza da seleção e dos
      problemas.
- [ ] Cobrir nos testes de widget os três ícones, consulta do motivo, diálogo
      rolável e ações **Cancelar**, **Continuar** e **Fechar**.
- [ ] Executar `dart format`, testes afetados, suíte completa,
      `flutter analyze` e `git diff --check`.
- [ ] Validar manualmente em Android e iOS Share e Email com seleções válida,
      parcial e totalmente inválida.
- [ ] Registrar o resultado no backlog e mover backlog e tasks para `closed/`
      somente após cumprir todos os critérios de aceite.

**Resultado esperado:** o fluxo parcial funciona nos dois canais, está
traduzido e não introduz regressões no relatório ou na seleção de treinos.

## Regra de conclusão

O backlog somente pode ser encerrado quando cada treino rejeitado permanecer
identificável e desmarcado, o usuário conhecer os problemas antes da entrega,
Share e Email entregarem todos os treinos válidos, nenhuma entrega ocorrer sem
conteúdo válido e falhas globais continuarem distinguíveis de problemas
individuais.
