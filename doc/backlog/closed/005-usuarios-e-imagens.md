# 005 — Usuários e imagens

## Objetivo

Migrar cadastro, edição, exclusão e seleção de atletas para MVVM, isolando banco,
sistema de arquivos, seleção e compressão de imagens.

As tarefas concluídas estão registradas em
[`005-usuarios-e-imagens-tasks.md`](005-usuarios-e-imagens-tasks.md).

## Dependências

- [`003-persistencia-e-repositories.md`](003-persistencia-e-repositories.md), concluído;
- padrão validado em
  [`004-configuracoes-mvvm.md`](004-configuracoes-mvvm.md), concluído.

## Escopo

- criar/adequar `UserRepository` orientado ao domínio;
- criar `UsersViewModel` e Commands de carregar, adicionar, editar e excluir;
- manter seleção de usuários como estado de apresentação do ViewModel;
- eliminar `UserManager.instance` do fluxo migrado;
- criar contratos para selecionar, comprimir, salvar e remover imagens;
- mover acesso a diretórios e arquivos para implementações de `data`;
- manter `TextEditingController`, dialogs, picker visual e navegação na Page;
- preservar limpeza de imagens não utilizadas sem apagar arquivos referenciados;
- preservar o fluxo de seleção que alimenta os cronômetros enquanto a feature
  antiga ainda existir.

## Fora de escopo

- alterar layout ou campos de usuário;
- armazenar bytes de imagem no SQLite;
- migrar múltiplos cronômetros;
- criar cache global de usuários sem consumidor concreto.

## Questões em aberto

Nenhuma questão permanece aberta nesta etapa.

## Critérios de aceite

- a UI não acessa diretórios, compressor, DAO ou repository concreto;
- o ViewModel não mantém widgets nem controllers de texto;
- repository e serviços são injetados;
- falhas de arquivo e banco chegam como `AppError` distinguível;
- atualização não deixa referência para arquivo inexistente;
- limpeza não remove imagens ainda utilizadas;
- cadastro, edição, exclusão e seleção preservam o comportamento atual;
- testes acompanham apenas caminhos modificados e compensações de arquivo;
- análise termina sem novos erros.

## Decisões

### 2026-08-19 — Seleção como estado do UsersViewModel

**Decisão:** a seleção de usuários pertence ao `UsersViewModel` durante o ciclo
de vida da página. Ela é inicializada com os atletas ativos no cronômetro e
entregue ao fluxo legado ao sair da página.

**Motivo:** a seleção é estado de apresentação da feature de usuários. Não há
consumidor que justifique criar um estado global adicional antes da migração de
sessões do backlog 008.

**Consequências:**

- a Page deixa de manter `_selectedUsers` como segunda fonte de verdade;
- o repository continua armazenando somente o cache de usuários;
- usuários já ativos permanecem protegidos contra exclusão;
- a integração temporária com o cronômetro ocorre apenas na entrada e na saída
  da página.

### 2026-08-19 — Substituição de imagem somente após persistência

**Decisão:** selecionar ou comprimir uma imagem não remove a imagem anterior. A
imagem antiga só pode ser removida depois que a nova referência for persistida
com sucesso.

**Motivo:** a referência vigente precisa continuar apontando para um arquivo
existente quando seleção, compressão, cópia ou atualização do banco falhar.

**Consequências:**

- o formulário pode exibir uma imagem temporária sem promovê-la a persistida;
- a atualização mantém a referência e o arquivo anteriores até a confirmação
  do banco;
- a remoção posterior verifica se o arquivo antigo ainda é referenciado.

### 2026-08-19 — Compensação entre arquivo e banco

**Decisão:** imagens novas são preparadas em arquivo temporário, promovidas para
o armazenamento definitivo antes da escrita da referência no banco e removidas
como compensação se a escrita falhar. Depois do sucesso no banco, a imagem
anterior é removida somente quando não estiver mais referenciada.

**Motivo:** banco e sistema de arquivos não compartilham transação. Uma ordem
explícita com compensações evita referências quebradas e reduz arquivos órfãos.

**Consequências:**

- falha de seleção ou compressão não altera banco nem imagem vigente;
- falha ao promover o arquivo não inicia a escrita no banco;
- falha no banco remove o novo arquivo e preserva o anterior;
- cadastro usa a mesma compensação, sem imagem anterior;
- exclusão persiste primeiro e limpa imagens não referenciadas depois;
- falhas de arquivo e banco são convertidas em `AppError` distinguível.

### 2026-08-19 — UseCase para coordenação complexa

**Decisão:** o `UsersViewModel` pode acessar diretamente um repository enquanto
a operação permanecer simples. Se a coordenação tornar o ViewModel complexo ou
exigir mais de um repository, será criado um UseCase específico para a página.

**Motivo:** o ViewModel deve concentrar estado e operações de apresentação, sem
absorver regras de coordenação entre fontes de dados ou compensações extensas.

**Consequências:**

- a direção de chamadas será `UI -> ViewModel -> UseCase -> repositories`;
- vista pelo fornecimento dos dados, a cadeia será
  `repositories -> UseCase -> ViewModel -> UI`;
- o UseCase recebe repositories e demais serviços necessários por construtor;
- a UI e o ViewModel não acessam repositories concretos;
- um UseCase não será criado apenas como encaminhamento sem regra própria;
- a decisão de introduzi-lo será tomada antes de concentrar múltiplas
  dependências ou compensações extensas no `UsersViewModel`.

## Acompanhamento

**Estado:** Concluído em 2026-08-19. As oito tasks foram entregues; os 40 testes
focados e os 210 testes da suíte completa passaram, `flutter analyze` terminou
sem issues e `git diff --check` passou. A validação manual foi dispensada para
este encerramento por indisponibilidade de dispositivo móvel interativo.

**Limitações transferidas:** `UserManager` permanece apenas para o fluxo legado
de treinos e será removido no backlog 006. A seleção ainda é convertida para
`UserModel` na fronteira com os cronômetros legados até o backlog 008.

**Próximo backlog:** [`006-treinos-e-historicos.md`](../006-treinos-e-historicos.md).
