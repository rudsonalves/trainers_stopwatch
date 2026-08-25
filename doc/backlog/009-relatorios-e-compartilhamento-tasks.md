# 009 — Tarefas de relatórios e compartilhamento

## Objetivo

Separar conteúdo, renderização PDF, arquivos temporários, e-mail e
compartilhamento em fronteiras injetáveis, migrando a página de treinos para
Commands sem alterar o formato e o comportamento observável desta versão.

## Decisões já tomadas

- o PDF mantém uma página por treino;
- o UseCase é proprietário do arquivo temporário e garante sua limpeza após a
  operação, inclusive em caso de falha;
- o corpo do e-mail permanece HTML e localizado, mas o serviço de e-mail recebe
  assunto e corpo já preparados;
- relatório vazio e treino sem parciais mantêm a representação atual;
- textos localizados pertencem à fronteira de apresentação/renderização, não ao
  domínio;
- serviços e UseCases não recebem `BuildContext`, widgets ou repositories
  concretos criados internamente.

## Ordem de execução

### 1. Caracterizar o comportamento atual

**Dependência:** backlog 006 concluído e decisões deste backlog fechadas.

- [x] Registrar em testes a estrutura atual de uma página por treino, linhas,
      totais, unidades, comentários e ordem dos eventos.
- [x] Caracterizar relatório sem treinos e treino sem parciais, sem introduzir
      uma nova regra visual nesta versão.
- [x] Caracterizar assunto, corpo HTML localizado, destinatário, anexo e dados
      entregues ao compartilhamento.
- [x] Identificar falhas atualmente originadas por carga, conteúdo, PDF,
      arquivo, e-mail e compartilhamento para orientar sua conversão em
      `AppError`.

**Resultado esperado:** a refatoração possui uma linha de base executável que
protege o comportamento aprovado.

**Entregue em 2026-08-25:** os testes de caracterização exercitam o PDF real
com filesystem temporário e substituem somente as plataformas de e-mail e
compartilhamento por fakes. A linha de base cobre ordem de treinos e eventos,
rótulos, unidades, durações, velocidades, comentários, quantidade vazia de
páginas, HTML, assunto, destinatário, anexo e metadados de compartilhamento. O
comportamento atual observado é: lista de treinos vazia gera um PDF sem páginas;
um treino contendo somente o marco inicial falha com `zeroElapsedTime`; e-mail
apaga o anexo após sucesso; compartilhamento deixa o arquivo presente. O corpo
do e-mail é HTML, usa o locale na data e mantém os demais rótulos fixos em
inglês. A auditoria também confirmou que falhas de repository e regras de
conteúdo propagam `AppError`, enquanto bundle/PDF/I/O e compartilhamento ainda
propagam exceções da implementação e o e-mail as embrulha em `Exception`; sua
normalização permanece nas tarefas 4 a 6.

Validação da tarefa: 9 testes focados e a suíte completa com 293 testes
passaram; `flutter analyze` e `git diff --check` terminaram sem issues.

### 2. Modelar o conteúdo do relatório

**Dependência:** tarefa 1.

- [x] Criar valores imutáveis de relatório para cabeçalho, resumo por treino,
      linhas e totais usando apenas `User`, `Training`, `HistoryEntry` e eventos
      de domínio.
- [x] Centralizar a montagem das linhas e o cálculo de duração, distância,
      voltas e velocidade média em código independente de Flutter, plugins,
      bundle e persistência.
- [x] Reutilizar `TrainingEventGenerator` e os value objects de unidades, sem
      duplicar a semântica de parciais e voltas.
- [x] Manter no conteúdo valores sem tradução e sem formatação específica de
      PDF ou HTML.
- [x] Retornar `Result`/`AppError` para dados inválidos em vez de lançar
      exceções cruas.

**Resultado esperado:** o relatório completo pode ser produzido e testado como
dados de domínio, sem renderer ou plataforma.

**Entregue em 2026-08-25:** foram criados models imutáveis para o conteúdo
completo, seções por treino, linhas baseadas em `TrainingEvent` e totais de
distância, duração, voltas e velocidade média. `TrainingReportContentBuilder`
recebe somente `User`, `Training` e `HistoryEntry`, preserva a ordem dos
treinos, reutiliza `TrainingEventGenerator` e `SpeedCalculator` e retorna
`Result`/`AppError` sem depender de Flutter, plugins, bundle, localização,
persistência ou formatação. Relatório sem treinos permanece válido; treino
somente com o marco inicial preserva `zeroElapsedTime`; dados vazios ou
inválidos falham sem retornar conteúdo parcial. Os testes cobrem igualdade por
valor, imutabilidade, cálculos, eventos, ordem e falhas.

### 3. Criar o UseCase de montagem do relatório

**Dependências:** tarefa 2 e repositories do backlog 006.

- [x] Criar um UseCase que receba `HistoryRepository` por construtor, carregue
      os históricos de cada treino selecionado e monte o relatório completo.
- [x] Preservar a ordem dos treinos recebidos e a ordem de eventos definida no
      domínio.
- [x] Interromper a montagem com `AppError` identificável quando uma carga ou
      transformação falhar, sem produzir relatório parcial silenciosamente.
- [x] Fazer a saída conter somente dados prontos para renderização, sem models
      SQLite, adapters legados, strings localizadas ou objetos de plugin.

**Resultado esperado:** carregar históricos e montar conteúdo torna-se uma
operação coordenada única, independente da geração de PDF.

**Entregue em 2026-08-25:** `BuildTrainingReportUseCase` recebe
`HistoryRepository` por construtor, valida as identidades do usuário e dos
treinos e rejeita treinos pertencentes a outro usuário. Os históricos são
carregados sequencialmente na ordem dos treinos recebidos e transformados por
`TrainingReportContentBuilder`. A primeira falha de carga ou transformação
interrompe a operação sem consultar treinos posteriores e sem expor conteúdo
parcial. A saída contém somente models de relatório e entidades de domínio, sem
dependências de SQLite, adapters legados, localização, PDF, arquivos ou
plugins. Os testes cobrem relatório vazio, ordem, validações, falha de
repository e falha posterior do builder.

### 4. Definir contratos de renderização e plataforma

**Dependências:** tarefas 2 e 3.

- [ ] Definir contrato de renderer PDF que receba relatório e textos já
      preparados e devolva bytes, sem consultar repository ou criar arquivo.
- [ ] Definir contrato de armazenamento temporário para criar/gravar e excluir
      um arquivo, usando uma referência abstrata adequada aos demais serviços.
- [ ] Definir contrato de compartilhamento que receba arquivo e metadados e não
      assuma sua ownership ou exclusão.
- [ ] Definir contrato de e-mail com destinatários, assunto, corpo HTML e
      anexos, sem dependência de localização ou Flutter na interface.
- [ ] Fazer todos os contratos devolverem `Result`/`AppError` com categorias
      apresentáveis para falhas esperadas.

**Resultado esperado:** PDF, sistema de arquivos e plugins externos podem ser
substituídos por fakes determinísticos.

### 5. Implementar os adapters de PDF, arquivo, e-mail e compartilhamento

**Dependência:** tarefa 4.

- [ ] Migrar a composição visual de `BuildPdf` para o renderer, preservando uma
      página por treino e o layout caracterizado.
- [ ] Carregar o ícone e aplicar textos e formatos localizados somente na
      fronteira de renderização.
- [ ] Implementar armazenamento no diretório temporário sem nome global que
      permita colisão entre operações concorrentes.
- [ ] Encapsular `share_plus` e `flutter_email_sender` nos respectivos adapters,
      sem acesso a repository ou exclusão de arquivo.
- [ ] Mapear exceções de bundle, PDF, I/O e plugins para `AppError`, preservando
      causa e contexto úteis para diagnóstico.

**Resultado esperado:** integrações concretas ficam isoladas e o renderer não
conhece banco nem coordenação do fluxo.

### 6. Coordenar geração, envio e limpeza em UseCases

**Dependências:** tarefas 3 a 5.

- [ ] Criar operações de compartilhamento e envio por e-mail que componham
      montagem, renderização, gravação e canal externo, recebendo os textos já
      preparados pela fronteira de apresentação/renderização.
- [ ] Fazer o UseCase manter a ownership da referência temporária desde sua
      criação até a conclusão da operação.
- [ ] Garantir a exclusão em `finally` após sucesso ou falha do canal externo,
      sem tentar excluir um arquivo que não chegou a ser criado.
- [ ] Definir como reportar falha de limpeza junto de uma falha primária, sem
      ocultar nenhuma delas nem converter sucesso em silêncio.
- [ ] Impedir que e-mail e compartilhamento dupliquem a mesma sequência de
      montagem, renderização e limpeza.

**Resultado esperado:** cada operação possui ciclo de vida previsível e não
deixa arquivos temporários sob responsabilidade dos plugins.

### 7. Expor Commands no `TrainingsViewModel`

**Dependência:** tarefa 6.

- [ ] Injetar as operações de e-mail e compartilhamento no ViewModel da página
      de treinos.
- [ ] Expor Commands tipados que usem o usuário e os treinos selecionados, sem
      acessar arquivo, renderer, plugin ou repository concreto diretamente.
- [ ] Rejeitar seleção ou usuário inválido com `AppError` apresentável.
- [ ] Consolidar estado de execução e último erro com os Commands existentes,
      bloqueando disparos concorrentes incompatíveis.
- [ ] Manter destinatário, assunto, corpo HTML e textos localizados preparados
      na fronteira de apresentação definida para o fluxo.

**Resultado esperado:** a UI dispara intenções e observa estado, enquanto o
ViewModel permanece livre de detalhes de plataforma.

### 8. Migrar UI, rotas e injeção de dependências

**Dependência:** tarefa 7.

- [ ] Fazer `TrainingsPage` chamar somente os Commands do ViewModel para e-mail
      e compartilhamento.
- [ ] Apresentar progresso e falhas esperadas sem exceções não tratadas e
      preservar seleção, menus e layout atuais.
- [ ] Registrar renderer, serviços e UseCases no composition root com ciclos de
      vida adequados.
- [ ] Remover `AppShare` dos argumentos da Page, das rotas, de `MyMaterialApp` e
      da composição de `main.dart` quando não houver consumidores.
- [ ] Manter Pages responsáveis por interação e localização, sem passar
      `BuildContext` para ViewModel, UseCase ou serviço.

**Resultado esperado:** apresentação e navegação dependem apenas do ViewModel e
de tipos estáveis da aplicação.

### 9. Remover a implementação e os adapters legados

**Dependências:** tarefas 5 a 8.

- [ ] Remover `BuildPdf`, `AppShare` e helpers substituídos quando todos os
      consumidores estiverem migrados.
- [ ] Migrar ou remover `TrainingReport` e `HistoryIndex`, mantendo somente
      abstrações que representem o novo conteúdo.
- [ ] Retirar do fluxo de relatório as conversões para `UserModel`,
      `TrainingModel`, `HistoryModel` e `MessagesModel`.
- [ ] Remover `training_domain_adapter.dart` e
      `history_domain_adapter.dart` se a busca confirmar ausência de outros
      consumidores; caso contrário, documentar precisamente o consumidor
      restante para o backlog 010.
- [ ] Confirmar por busca que renderer, serviços e ViewModel não consultam
      repository fora da coordenação prevista.

**Resultado esperado:** relatório e compartilhamento não conservam uma
arquitetura paralela baseada nos models legados.

### 10. Testar conteúdo, coordenação e apresentação

**Dependências:** tarefas 2 a 9.

- [ ] Testar conteúdo com múltiplos treinos, unidades, comentários, parciais,
      voltas derivadas, lista vazia e treino sem parciais.
- [ ] Testar que o UseCase carrega cada histórico, preserva ordem e propaga
      falhas sem renderizar ou compartilhar resultado parcial.
- [ ] Testar renderer com dados prontos e comprovar que ele não consulta banco.
- [ ] Testar sucesso e falhas de renderização, criação, gravação, e-mail,
      compartilhamento e exclusão usando fakes.
- [ ] Comprovar que o arquivo é excluído exatamente uma vez após sucesso ou
      falha e que falhas primária e de limpeza permanecem diagnosticáveis.
- [ ] Testar Commands, bloqueio concorrente, estado de carregamento, sucesso e
      `AppError` no `TrainingsViewModel`.
- [ ] Testar em widget habilitação dos menus, disparo dos Commands e feedback
      visível, sem acessar plugins reais.

**Resultado esperado:** comportamento e ownership ficam comprovados sem bundle,
filesystem real ou plugins nos testes de coordenação.

### 11. Validar e documentar a entrega

**Dependência:** tarefas 1 a 10.

- [ ] Executar `dart format` nos arquivos alterados.
- [ ] Executar os testes focados de conteúdo, UseCases, serviços, ViewModel e
      widgets migrados.
- [ ] Executar a suíte completa com `flutter test`.
- [ ] Executar `flutter analyze` sem novas issues.
- [ ] Executar `git diff --check`.
- [ ] Validar manualmente PDF, e-mail e compartilhamento em uma plataforma com
      os plugins disponíveis, incluindo falha/cancelamento e limpeza.
- [ ] Confirmar por busca que não restam dependências legadas ou acessos a
      plugin/repository fora das fronteiras definidas.
- [ ] Atualizar o acompanhamento do backlog 009 com resultados e limitações e
      movê-lo para `closed/` somente após cumprir os critérios de aceite.

**Resultado esperado:** a entrega permanece executável, testada e documentada,
com validação manual das integrações de plataforma registrada.

## Regra de conclusão

O backlog só pode ser encerrado quando o conteúdo do relatório for produzido
sem Flutter ou plugins; o renderer receber dados prontos e não consultar banco;
ViewModel, arquivo, e-mail e compartilhamento estiverem separados por contratos;
o UseCase garantir a limpeza do temporário; os comportamentos aprovados forem
preservados; adapters legados não tiverem consumidores no fluxo; e testes,
análise e verificação do diff terminarem sem novos erros.
