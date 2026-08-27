# 011 — Ajustes de interface e interação

## Objetivo

Consolidar ajustes identificados durante a validação manual: tornar as ações
protegidas do cronômetro descobríveis, refinar seu espaçamento visual e
restabelecer uma seleção de idioma previsível nas configurações.

## Dependências

Depende da conclusão e validação final do backlog 010.

## Frente 1 — Ações protegidas do cronômetro

### Contexto

Quando uma sessão está pausada, os botões **Reset** e **Finalizar** aparecem
habilitados, mas respondem somente a uma pressão longa. A diferença de cor dos
ícones não comunica esse gesto de maneira suficiente, e um toque comum sem
resposta pode ser interpretado como falha da interface.

A pressão longa existe para evitar que um toque acidental abandone ou finalize
uma medição. Essa proteção deve ser preservada, mas não deve ser o único caminho
disponível nem depender de uma instrução apresentada fora de contexto.

### Comportamento definido

| Ação | Toque comum | Pressão longa |
| --- | --- | --- |
| Continuar | executar imediatamente | sem atalho adicional |
| Reset | solicitar confirmação | executar diretamente |
| Finalizar | solicitar confirmação | executar diretamente |

- o primeiro contato contextual com essas ações deve informar que a pressão
  longa executa a operação sem confirmação;
- a orientação deve aparecer quando os controles se tornarem relevantes pela
  primeira vez, e não na inicialização genérica do aplicativo;
- o reconhecimento da pressão longa deve produzir feedback tátil quando
  suportado pela plataforma;
- **Reset** e **Finalizar** devem ter mensagens de confirmação específicas,
  coerentes com as consequências reais de cada operação;
- a interface não deve depender apenas da cor para comunicar a diferença entre
  as ações.

### Escopo

- ligar o toque comum de **Reset** e **Finalizar** a confirmações contextuais;
- preservar a pressão longa como atalho de execução direta;
- apresentar uma dica contextual, curta e não recorrente sobre o atalho;
- adicionar feedback tátil ao acionamento por pressão longa;
- revisar ícones, cores, rótulos e estados sem depender exclusivamente da cor;
- adicionar e traduzir os textos necessários nos idiomas suportados;
- cobrir os dois caminhos de acionamento e o controle de exibição da dica.

## Frente 2 — Espaçamento do cronômetro

- adicionar um espaçamento vertical de 4 pixels entre o mostrador do
  cronômetro e a barra de botões;
- usar o atributo `spacing` da `Column` que organiza os dois componentes, sem
  inserir um `SizedBox` dedicado;
- preservar as dimensões e o alinhamento dos demais elementos do componente;
- confirmar que o novo espaçamento não provoca overflow nas larguras e escalas
  de texto suportadas; a orientação do aplicativo permanece fixa.

## Frente 3 — Seleção de idioma

O seletor de idioma na página de configurações aparenta percorrer ou alternar
idiomas em vez de aplicar diretamente a opção escolhida.

A validação visual demonstrou que a seleção exibida fica um passo à frente do
idioma aplicado aos textos:

| Seleção exibida | Idioma ainda aplicado à página |
| --- | --- |
| `pt_BR` | inglês |
| `es_null` | português do Brasil |
| `en_US` | espanhol |

O valor `es_null` revela ainda um problema de apresentação independente: um
locale sem `countryCode` não deve interpolar `null` no rótulo. O seletor deve
exibir o nome legível do idioma, acompanhado da bandeira, mantendo o código do
locale apenas como identificação interna quando necessário.

- reproduzir e diagnosticar o comportamento antes de alterar a implementação;
- garantir que selecionar uma opção aplique exatamente o locale correspondente;
- manter a opção selecionada visível e sincronizada com a configuração
  persistida;
- exibir nomes legíveis como **Português Brasil**, **Español** e **US English**,
  sem sufixos nulos;
- impedir mudanças intermediárias ou múltiplas atualizações durante uma única
  seleção;
- verificar o comportamento ao reiniciar o aplicativo e ao alternar
  repetidamente entre todos os idiomas suportados.

## Fora de escopo

- criar uma preferência para alternar entre diálogo e pressão longa;
- remover a pressão longa;
- alterar as regras temporais ou de persistência do cronômetro;
- redesenhar integralmente o componente do cronômetro;
- apresentar um tutorial obrigatório na primeira inicialização do aplicativo;
- adicionar novos idiomas;
- substituir a infraestrutura de localização sem evidência de necessidade.

## Decisões

1. A orientação sobre as ações protegidas será apresentada por `SnackBar` na
   primeira vez em que os controles se tornarem disponíveis no estado pausado.
2. A exibição da dica será registrada nas configurações persistidas para que
   ela não reapareça após reiniciar o aplicativo.
3. O **Reset** manterá o comportamento atual: o treino permanece salvo com os
   registros já realizados, sem receber um registro de finalização. A
   confirmação deve descrever essa consequência explicitamente. **Finalizar**
   deve informar que o tempo atual e os registros pendentes serão salvos.
4. As cores atuais dos botões serão preservadas como indicação complementar de
   seu comportamento diferente. Cor, ícone e rótulo atuarão em conjunto; a cor
   não será a única forma de comunicação.
5. A evidência visual confirma duas fontes de locale em momentos diferentes:
   a seleção reflete imediatamente o `AppAppearanceState`, enquanto os textos
   traduzidos pelo `easy_localization` permanecem no locale anterior até a
   sincronização posterior. A implementação deve adotar uma única aplicação
   efetiva do locale, mantendo `AppAppearanceState` como estado desejado e
   `context.locale` como locale usado pelo `MaterialApp` e pelas traduções.
6. Não há evidência atual de que a fila de persistência percorra idiomas
   intermediários. Ela será preservada e receberá um teste de alternância rápida
   para comprovar que somente o último locale permanece aplicado e persistido.
7. O espaçamento será aplicado com `Column(spacing: 4)` no
   `PreciseStopwatch`, que possui a relação entre o mostrador e a barra de
   botões. A orientação fixa do aplicativo será preservada.

## Critérios de aceite

- tocar em **Reset** ou **Finalizar** sempre produz uma resposta visível;
- cancelar uma confirmação não altera a sessão, o BLoC nem a persistência;
- confirmar executa exatamente a mesma operação usada pela pressão longa;
- a pressão longa continua protegida contra disparos duplicados e fornece
  feedback tátil;
- a dica contextual aparece somente conforme a regra definida e pode ser
  compreendida quando os botões estão visíveis;
- existe exatamente 4 pixels de espaçamento vertical entre o mostrador e os
  botões, sem overflow nos dispositivos e escalas de texto suportados;
- cada idioma pode ser selecionado diretamente em uma única interação, sem
  percorrer outras opções;
- o rótulo do idioma é legível e nunca contém `null`;
- o seletor e a aplicação permanecem sincronizados depois da persistência e da
  reinicialização;
- rótulos e mensagens estão disponíveis em todos os idiomas suportados;
- controles permanecem acessíveis e distinguíveis sem depender somente da cor;
- testes cobrem toque, cancelamento, confirmação, pressão longa, espaçamento e
  seleção de idioma;
- `flutter analyze`, testes afetados e validação manual em Android e iOS
  terminam sem regressões.

## Acompanhamento

**Estado:** Pronto para implementação — decisões fechadas e tasks definidas.

**Tasks:**
[011-ajustes-interface-e-interacao-tasks.md](011-ajustes-interface-e-interacao-tasks.md).

**Próximo passo:** executar a tarefa 3 e persistir a exibição da dica
contextual das ações protegidas.
