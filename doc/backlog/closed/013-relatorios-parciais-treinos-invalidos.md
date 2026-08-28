# 013 — Relatórios parciais com treinos inválidos

## Objetivo

Permitir que o compartilhamento de relatórios continue quando parte dos
treinos selecionados não puder ser processada, informando claramente quais
treinos foram excluídos e o motivo de cada exclusão.

## Dependências

Complementa o backlog 009, já concluído, e pode ser executado
independentemente do backlog 012.

## Contexto

Atualmente, a geração do relatório é interrompida no primeiro treino inválido.
Na tela de treinamentos, essa falha aparece apenas como a mensagem genérica
`TPError`, mesmo quando os demais treinos selecionados poderiam compor um
relatório válido.

O problema foi reproduzido com um treino que possuía apenas o registro inicial,
sem parciais e com duração total igual a zero. O cálculo da velocidade média
rejeitou a duração, o processamento foi encerrado e o compartilhamento nativo
nem chegou a ser acionado.

## Comportamento definido

- processar individualmente todos os treinos selecionados;
- acumular os problemas específicos de cada treino sem interromper os demais;
- remover da seleção os treinos que não puderem compor o relatório;
- gerar e compartilhar o relatório com todos os treinos válidos;
- mostrar uma mensagem com os treinos excluídos, identificados ao menos pela
  data e hora, acompanhados do motivo da falha;
- mostrar a mensagem antes da entrega e informar que o relatório será gerado
  somente com os treinos válidos;
- permitir que o usuário continue ou cancele a entrega do relatório parcial;
- quando nenhum treino for válido, não abrir o compartilhamento e listar todos
  os treinos rejeitados;
- aplicar o mesmo tratamento parcial ao compartilhamento e ao envio por
  e-mail;
- representar à direita de cada treino os estados não selecionado, selecionado
  e rejeitado;
- manter o treino rejeitado identificado na lista, mesmo depois de removê-lo da
  seleção, até que seus dados sejam corrigidos ou recarregados;
- preservar como falha global os erros que impedem a entrega inteira, como
  falha ao renderizar o PDF, gravar o arquivo temporário ou abrir o serviço
  nativo de compartilhamento.

## Mensagem esperada

Antes de abrir o compartilhamento ou envio por e-mail, um diálogo apresenta:

> Alguns treinos não puderam ser incluídos no relatório:
>
> - 27/08/2026 08:14 — treino sem medições
> - 27/08/2026 09:30 — histórico inconsistente
>
> O relatório será gerado com os outros 2 treinos.

Nesse cenário, o diálogo oferece as ações **Cancelar** e **Continuar**.

Quando todos falharem, a conclusão deve informar que nenhum relatório foi
gerado.

## Escopo

- representar o resultado parcial da construção do relatório, mantendo o
  conteúdo válido e os problemas associados aos respectivos treinos;
- propagar os problemas até o `TrainingsViewModel` sem reduzir o resultado a
  um `Unit` sem contexto;
- reconciliar `_selectedTrainingIds`, removendo somente os treinos rejeitados;
- apresentar na `TrainingsPage` um diálogo traduzido, com altura limitada e
  lista rolável dos problemas;
- adicionar ao `DismissibleTraining` um indicador à direita para os estados
  não selecionado, selecionado e rejeitado;
- permitir consultar pelo indicador de erro o motivo da rejeição do treino;
- limpar o estado de erro depois que o histórico for corrigido ou os treinos
  forem recarregados, permitindo uma nova validação;
- substituir o `TPError` genérico nesse fluxo por informações acionáveis;
- manter o compartilhamento e o envio por e-mail dos treinos válidos, com
  tratamento separado de falhas globais;
- cobrir combinações de seleção totalmente válida, parcialmente válida e
  totalmente inválida.

## Fora de escopo

- corrigir automaticamente históricos persistidos inconsistentes;
- excluir do banco os treinos que falharem;
- alterar medições, durações ou eventos para tornar um treino artificialmente
  válido;
- modificar os formatos de compartilhamento ou de envio por e-mail;
- redesenhar integralmente a tela de treinamentos.

## Decisões

1. A validação ocorre antes da entrega. Havendo treinos rejeitados e pelo menos
   um válido, um diálogo apresenta os problemas e solicita confirmação para
   continuar com o relatório parcial.
2. Um treino sem medições é inválido para o relatório e recebe o motivo
   traduzido **treino sem medições**. Seus dados permanecem no banco.
3. Compartilhamento e envio por e-mail adotam o mesmo resultado parcial e as
   mesmas regras de seleção e comunicação.
4. A mensagem usa um diálogo com altura limitada, conteúdo rolável e ações
   **Cancelar** e **Continuar**. Quando nenhum treino for válido, apresenta
   somente **Fechar** e não inicia a entrega.
5. O `trailing` de cada treino possui três estados visuais:
   `Icons.radio_button_unchecked` para não selecionado, `Icons.check_circle`
   para selecionado e `Icons.error` para rejeitado. Cores, tooltips e descrições
   semânticas traduzidas complementam os ícones, sem serem a única indicação.
6. Treinos rejeitados são removidos da seleção assim que a validação termina,
   mesmo que o usuário cancele a entrega. O erro permanece visível na lista e
   pode ser acionado para consultar seu motivo.
7. Ao corrigir o histórico ou recarregar os treinos, o erro registrado na
   apresentação é descartado e o treino pode ser selecionado e validado
   novamente.

## Critérios de aceite

- um treino inválido não impede o relatório dos demais treinos válidos;
- cada treino rejeitado é identificado por data e hora e possui um motivo
  compreensível;
- treinos rejeitados são removidos da seleção, sem alterar ou excluir seus
  dados persistidos;
- cada linha apresenta à direita um estado inequívoco de não selecionado,
  selecionado ou rejeitado;
- tocar no indicador de erro apresenta o motivo associado ao treino;
- os indicadores possuem tooltip e semântica traduzidos e não dependem apenas
  da cor;
- a mensagem distingue relatório parcial de relatório não gerado;
- o compartilhamento não é acionado quando nenhum treino é válido;
- compartilhamento e envio por e-mail possuem o mesmo comportamento parcial;
- falhas globais não são apresentadas como se pertencessem a um treino
  específico;
- os textos estão disponíveis em todos os idiomas suportados;
- testes cobrem resultados válidos, parciais e totalmente inválidos, além da
  atualização da seleção;
- `flutter analyze`, testes afetados e validação manual em Android e iOS
  terminam sem regressões.

## Acompanhamento

**Estado:** Pronto para implementação — decisões fechadas.

**Tasks:**
[013-relatorios-parciais-treinos-invalidos-tasks.md](013-relatorios-parciais-treinos-invalidos-tasks.md).

**Próximo passo:** executar a tarefa 1 e modelar o resultado que separa
conteúdo válido e problemas por treino.
