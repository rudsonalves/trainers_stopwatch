# 005 — Usuários e imagens

## Objetivo

Migrar cadastro, edição, exclusão e seleção de atletas para MVVM, isolando banco,
sistema de arquivos, seleção e compressão de imagens.

## Dependências

- `003-persistencia-e-repositories.md`;
- padrão validado em `004-configuracoes-mvvm.md`.

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

1. A seleção pertence apenas à página ou deve sobreviver durante toda a sessão?
2. A imagem nova só deve substituir a anterior depois da atualização do banco?
3. Qual política de rollback será aplicada se compressão, arquivo ou banco falhar?

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

Nenhuma decisão adicional aprovada.

## Acompanhamento

**Estado:** Planejado.

**Próximo backlog:** `006-treinos-e-historicos.md`.

