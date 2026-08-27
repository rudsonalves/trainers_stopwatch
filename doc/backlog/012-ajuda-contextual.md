# 012 — Ajuda contextual por página

## Objetivo

Disponibilizar ajuda contextual acessível por um botão com o símbolo **?** no
canto superior direito do aplicativo, apresentando imagens e orientações
específicas para a página ativa.

## Dependências

Depende da conclusão e validação final do backlog 010. Pode ser planejado e
executado independentemente do backlog 011, observando os comportamentos de
interface definidos por ele.

## Contexto

O aplicativo possui fluxos com gestos, estados e operações que nem sempre são
autoexplicativos. Uma ajuda genérica e distante do ponto de uso exige que o
usuário descubra onde procurar e identifique sozinho qual trecho se aplica à
tela atual.

A ajuda deve partir do contexto visível: ao acionar **?**, o usuário recebe o
conteúdo referente à página em que está, sem precisar navegar por um manual
completo.

## Comportamento definido

- páginas que possuam conteúdo de ajuda exibem uma ação **?** no canto superior
  direito da `AppBar`;
- o acionamento abre diretamente a ajuda correspondente à página ativa;
- o conteúdo pode combinar título, seções curtas, imagens, legendas e instruções
  passo a passo;
- retornar da ajuda restaura a página e seu estado anterior;
- páginas sem conteúdo publicado não exibem um botão sem função;
- o ícone possui tooltip e descrição semântica traduzidos, não dependendo
  apenas do símbolo **?** para ser compreendido.

## Escopo

- definir um modelo consistente para identificar e apresentar a ajuda de cada
  página;
- integrar a ação de ajuda às `AppBar`s sem duplicar regras de navegação e
  layout;
- criar uma apresentação responsiva para texto e imagens em diferentes tamanhos
  de tela e orientações;
- preparar o conteúdo inicial das páginas prioritárias;
- armazenar imagens como assets otimizados e declarar somente os recursos
  necessários no `pubspec.yaml`;
- traduzir títulos, textos, legendas, tooltips e descrições semânticas nos
  idiomas suportados;
- cobrir navegação, associação entre página e conteúdo, rolagem e ausência de
  ajuda.

## Conteúdo inicial proposto

1. **Cronômetros:** adicionar atletas, iniciar, pausar, continuar, registrar
   parcial/volta, finalizar, reiniciar e compreender as ações protegidas.
2. **Usuários:** criar, editar, selecionar imagem e remover um atleta.
3. **Treinamentos:** filtrar, selecionar, editar, excluir e gerar relatórios.
4. **Histórico:** interpretar eventos e estatísticas e editar comentários.
5. **Configurações:** distâncias padrão, unidade, tema, contraste, idioma e
   intervalo de atualização.

## Fora de escopo

- criar suporte remoto, chat ou atendimento dentro do aplicativo;
- baixar conteúdo de ajuda da internet;
- produzir vídeos ou animações nesta primeira entrega;
- substituir dicas contextuais curtas que sejam necessárias no momento exato de
  uma interação;
- redesenhar as funcionalidades descritas pela ajuda.

## Questões para a implementação

1. A ajuda deve abrir como nova rota, página modal ou painel adaptativo?
2. Quais páginas entram na primeira entrega e qual é a ordem de prioridade?
3. As imagens serão capturas reais, ilustrações anotadas ou uma combinação das
   duas?
4. Como evitar que imagens fiquem desatualizadas quando a interface mudar?
5. O conteúdo será modelado em Dart, arquivos estruturados locais ou widgets
   específicos por página?
6. Como o botão de ajuda conviverá com outras ações no canto direito em telas
   estreitas e com escala de texto elevada?

## Critérios de aceite

- o botão de ajuda aparece no canto superior direito de cada página contemplada;
- cada botão abre diretamente o conteúdo correto para a página ativa;
- fechar ou voltar da ajuda preserva o estado anterior da página;
- textos e imagens permanecem legíveis, roláveis e sem overflow nos dispositivos
  e escalas de texto suportados;
- imagens possuem legenda ou descrição alternativa quando necessário;
- todo o conteúdo e os elementos de acessibilidade estão traduzidos nos idiomas
  suportados;
- páginas sem ajuda não exibem uma ação inoperante;
- testes comprovam a associação entre rota/página e conteúdo de ajuda;
- `flutter analyze`, testes afetados e validação manual em Android e iOS
  terminam sem regressões.

## Acompanhamento

**Estado:** Planejado.

**Próximo passo:** definir as páginas prioritárias e o formato visual do
conteúdo antes de criar o arquivo de tasks.
