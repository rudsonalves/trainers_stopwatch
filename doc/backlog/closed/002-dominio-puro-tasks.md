# 002 — Tarefas para extrair o domínio puro

## Objetivo

Organizar a implementação das decisões registradas em
[`002-dominio-puro.md`](002-dominio-puro.md), isolando regras estáveis em Dart
puro sem migrar persistência, BLoC ou páginas neste backlog.

## Decisões já tomadas

- models de domínio não dependem de Flutter, SQLite, plugins ou localização;
- cor é estado visual transitório e não será persistida;
- o sistema métrico usa `m` e `m/s` como padrões;
- unidades imperiais já disponíveis continuam suportadas;
- a matriz atual de combinações de distância e velocidade será preservada;
- duração zero no cálculo de velocidade produz `zeroElapsedTime`;
- relatórios de domínio produzem eventos neutros;
- adapters temporários manterão o código antigo funcionando durante a migração.

## Ordem de execução

### 1. Preparar a estrutura do domínio

**Dependência:** backlog 001 concluído.

- [x] Criar `lib/domain/common` sem arquivos agregadores prematuros.
- [x] Criar contextos somente conforme forem usados: `user`, `training`,
      `history`, `settings` e `stopwatch`.
- [x] Documentar que `domain` pode depender apenas de Dart, `core/result` e
      outros tipos de domínio.
- [x] Confirmar que `domain` não importa `flutter`, `sqflite`,
      `easy_localization`, paths, repositories ou widgets.
- [x] Adicionar `zeroElapsedTime` a `AppErrorCode`.
- [x] Não acrescentar novos códigos de erro sem consumidor neste backlog.

**Resultado esperado:** existe uma fronteira de domínio mínima, com direção de
dependências explícita e o erro necessário ao cálculo de velocidade.

### 2. Modelar unidades

**Dependência:** tarefa 1.

- [x] Criar `DistanceUnit` para metro, quilômetro, jarda e milha.
- [x] Criar `SpeedUnit` para metros por segundo, quilômetros por hora, jardas
      por segundo e milhas por hora.
- [x] Definir `m` como unidade padrão de distância.
- [x] Definir `m/s` como unidade padrão de velocidade.
- [x] Implementar conversão explícita entre enum e os valores persistidos
      atuais (`m`, `km`, `yd`, `mi`, `m/s`, `km/h`, `yd/s`, `mph`).
- [x] Converter valor desconhecido em `Failure` com `invalidData`, sem fallback
      silencioso.
- [x] Representar no domínio a matriz atual de velocidades permitidas para cada
      unidade de distância.
- [x] Expor uma operação para validar a combinação escolhida.
- [x] Testar parsing e serialização de todas as unidades.
- [x] Testar valor desconhecido e todas as combinações válidas e inválidas.

**Resultado esperado:** strings de unidade ficam restritas às bordas e o domínio
trabalha com tipos válidos.

### 3. Criar valores de distância e velocidade

**Dependência:** tarefa 2.

- [x] Criar um valor de distância imutável com quantidade e `DistanceUnit`.
- [x] Definir como inválidos valores de distância negativos ou não finitos.
- [x] Preservar distância zero onde ela representar ausência de deslocamento,
      sem usá-la silenciosamente como parcial válida.
- [x] Criar um valor de velocidade imutável com quantidade e `SpeedUnit`.
- [x] Impedir velocidade `NaN` ou infinita.
- [x] Implementar normalização de distância para metros.
- [x] Implementar conversão de velocidade em `m/s` para cada unidade suportada.
- [x] Evitar arredondamento dentro do domínio; arredondar somente na
      apresentação/renderização.
- [x] Testar fatores de conversão usados atualmente pela aplicação.
- [x] Testar valores negativos, zero, `NaN` e infinitos conforme o contrato de
      cada tipo.

**Resultado esperado:** cálculos deixam de transportar `double` e unidade como
valores desconectados.

### 4. Implementar o cálculo de velocidade

**Dependências:** tarefas 2 e 3.

- [x] Criar uma operação de domínio que receba distância, duração e unidade de
      velocidade desejada.
- [x] Normalizar o cálculo internamente para metros e segundos.
- [x] Rejeitar `Duration.zero` com `AppErrorCode.zeroElapsedTime` antes da
      divisão.
- [x] Rejeitar duração negativa com `invalidData`.
- [x] Rejeitar combinação incompatível de unidades com `invalidData`.
- [x] Garantir que o resultado seja finito antes de devolver `Success`.
- [x] Não transformar duração zero em velocidade zero.
- [x] Testar os resultados equivalentes para `m/s`, `km/h`, `yd/s` e `mph`.
- [x] Testar duração zero, duração negativa e combinação inválida.
- [x] Comparar os casos normais com o comportamento atual de
      `StopwatchFunctions.speedCalc`.

**Resultado esperado:** existe uma única regra tipada de velocidade, protegida
contra divisão por zero e independente de `TrainingModel`.

### 5. Criar os models de domínio

**Dependências:** tarefas 2 e 3.

- [x] Criar o model imutável de usuário apenas com dados significativos ao
      domínio.
- [x] Criar o model imutável de treino com usuário, data, comentários,
      distâncias, limite de voltas e unidades tipadas.
- [x] Não incluir `Color` no treino de domínio.
- [x] Criar o model imutável de histórico com treino, duração e comentários.
- [x] Permitir `Duration.zero` no registro que representa início da sessão.
- [x] Criar o model de configurações de domínio somente com valores persistidos
      que não sejam estado visual de widgets.
- [x] Não incluir `ValueNotifier`, `FocusNode`, paths ou estado de tutorial da
      sessão nos models de domínio.
- [x] Manter IDs opcionais somente quando necessários para representar uma
      entidade ainda não persistida.
- [x] Não adicionar `toMap`, `fromMap`, JSON ou nomes de colunas aos models.
- [x] Testar invariantes e defaults métricos introduzidos pelos models.

**Resultado esperado:** entidades relevantes podem circular entre futuros
repositories, UseCases e Viewmodels sem dependência de infraestrutura ou UI.

### 6. Modelar snapshots e eventos temporais

**Dependências:** tarefas 3 a 5.

- [x] Criar snapshots imutáveis para parcial, volta e encerramento.
- [x] Representar duração acumulada, índices e contadores sem `ValueNotifier`.
- [x] Criar uma hierarquia selada de eventos neutros de relatório.
- [x] Criar evento de início sem cálculo de velocidade.
- [x] Criar evento de parcial com índice, duração, velocidade e comentário.
- [x] Criar evento de volta com índice, duração acumulada, velocidade e
      comentário.
- [x] Manter cor, ícone, label traduzida e nome de rota fora dos eventos.
- [x] Definir igualdade ou propriedades suficientes para comparação previsível
      nos testes, sem adicionar biblioteca apenas para isso.
- [x] Testar construção e invariantes dos snapshots/eventos modificados.

**Resultado esperado:** o futuro BLoC e os relatórios compartilham valores
temporais neutros sem compartilhar estado visual.

### 7. Extrair a regra de parcial e volta

**Dependências:** tarefas 4 a 6.

- [x] Criar o gerador de relatório/eventos recebendo treino e histórico de
      domínio.
- [x] Preservar o cálculo atual de parciais por volta.
- [x] Preservar a ordem: início, parcial e eventual volta.
- [x] Acumular a duração correta de todas as parciais que formam uma volta.
- [x] Fazer o evento de volta carregar a duração acumulada da volta, não apenas
      a duração da última parcial.
- [x] Garantir que chamadas repetidas não acumulem estado de uma execução
      anterior.
- [x] Definir comportamento previsível para histórico vazio.
- [x] Tratar o primeiro registro como início, sem cálculo de velocidade.
- [x] Propagar `zeroElapsedTime` quando uma parcial inválida exigir cálculo.
- [x] Não chamar `.tr()` nem criar `MessagesModel` dentro do domínio.
- [x] Testar uma volta completa, várias voltas, volta incompleta, histórico
      vazio e execução repetida.
- [x] Testar índices nas fronteiras de parcial e volta.

**Resultado esperado:** identificação e cálculo de eventos de treino possuem uma
única implementação neutra e reutilizável.

### 8. Separar formatação de apresentação

**Dependências:** tarefas 4 e 7.

- [x] Identificar consumidores atuais de `formatDuration`, labels e
      `SpeedValue.toString()`.
- [x] Manter no domínio apenas valores e cálculos, sem textos localizados.
- [x] Criar mapper/formatter temporário fora de `domain` para preservar o texto
      atualmente exibido.
- [x] Fazer labels `Split[n]` e `Lap[n]` nascerem no mapper de apresentação.
- [x] Fazer mensagens localizadas continuarem usando `easy_localization` fora
      do domínio.
- [x] Manter arredondamento visual em duas casas onde já for exibido assim.
- [x] Não redesenhar mensagens, PDF ou widgets neste backlog.
- [x] Testar somente a compatibilidade de formatação que for alterada.

**Resultado esperado:** a aplicação mantém os textos atuais, mas o domínio não
conhece strings prontas nem localização.

### 9. Criar adapters temporários para o legado

**Dependências:** tarefas 2 a 8.

- [x] Mapear `UserModel` para o novo usuário de domínio e vice-versa somente
      onde houver consumidor real.
- [x] Mapear `TrainingModel` preservando IDs, data, medidas, limite e strings de
      persistência por meio dos enums.
- [x] Ignorar `TrainingModel.color` na conversão para domínio.
- [x] Mapear `HistoryModel` preservando duração e comentários.
- [x] Manter `SettingsModel` compatível sem levar `Brightness`, `Contrast` ou
      notifiers para o domínio quando forem conceitos de apresentação.
- [x] Fazer `StopwatchFunctions.speedCalc` delegar ao novo cálculo ou criar um
      adapter equivalente para consumidores ainda não migrados.
- [x] Fazer `TrainingReport` antigo delegar ao gerador neutro e mapear eventos
      para `MessagesModel`, se isso puder ser feito sem mudar sua API pública.
- [x] Evitar duas implementações independentes das mesmas regras.
- [x] Marcar adapters temporários e seus consumidores para remoção nos backlogs
      de persistência/UI correspondentes.
- [x] Testar compatibilidade nos caminhos efetivamente conectados.

**Resultado esperado:** o aplicativo continua compilando e funcionando enquanto
o domínio novo passa a ser a fonte das regras migradas.

### 10. Revisar fronteiras e remover duplicação

**Dependências:** tarefas 1 a 9.

- [x] Verificar com busca que `lib/domain` não importa Flutter ou infraestrutura.
- [x] Verificar que `Color`, `ValueNotifier`, `MessagesModel` e `.tr()` não
      aparecem no domínio.
- [x] Verificar que conversões de unidade não permanecem duplicadas em funções
      antigas.
- [x] Verificar que nenhuma migration ou coluna de cor foi criada.
- [x] Não criar UseCase se nenhuma coordenação concreta surgiu nesta etapa.
- [x] Atualizar o documento de arquitetura com os tipos efetivamente entregues.

**Resultado esperado:** o domínio extraído respeita as decisões do backlog sem
camadas ou abstrações adicionais sem uso.

### 11. Validar e documentar a entrega

**Dependências:** tarefas 1 a 10.

- [x] Executar `dart format` nos arquivos alterados.
- [x] Executar testes de unidades, valores, velocidade, eventos e adapters
      modificados.
- [x] Executar a suíte completa com `flutter test`.
- [x] Executar `flutter analyze` sem novas issues.
- [x] Executar `git diff --check`.
- [x] Validar o bootstrap manualmente no emulador Android e o fluxo de treino
      com parcial e volta pelo teste integrado do adapter legado. A interação
      manual completa foi impedida pela permissão do ambiente e está registrada
      no acompanhamento.
- [x] Registrar limitações e adapters adiados.
- [x] Atualizar o acompanhamento de `002-dominio-puro.md`.
- [x] Marcar este checklist somente após todas as verificações.
- [x] Mover o backlog e as tasks concluídas para `doc/backlog/closed/`.

**Resultado esperado:** regras de domínio estão isoladas, o aplicativo mantém o
comportamento e o backlog 003 pode migrar persistência sobre os novos tipos.

## Regra de conclusão

Uma tarefa só deve ser marcada como concluída junto das validações próximas à
regra alterada. O backlog não exige cobertura ampla da aplicação, mas não pode
deixar cálculo duplicado, dependência de Flutter no domínio ou quebra de
compatibilidade silenciosa.
