# 005 — Tarefas para usuários e imagens

## Objetivo

Migrar cadastro, edição, exclusão e seleção de usuários para MVVM e retirar da
UI o acesso a banco, diretórios, arquivos, seleção e compressão de imagens.

## Decisões já tomadas

- a seleção é estado do `UsersViewModel` durante o ciclo de vida da página;
- a seleção inicial vem dos atletas ativos e retorna ao fluxo legado na saída;
- selecionar ou comprimir uma imagem não remove a imagem persistida;
- a imagem nova é preparada temporariamente e promovida antes da escrita no
  banco;
- falha no banco remove a imagem nova e preserva a anterior;
- a imagem anterior só é removida após sucesso no banco e se não houver outra
  referência;
- exclusão persiste primeiro e executa a limpeza segura depois;
- `TextEditingController`, dialogs, picker visual e navegação permanecem na UI;
- o repository mantém o cache de dados, enquanto o ViewModel mantém apenas
  estado de apresentação.
- se o ViewModel precisar coordenar mais de um repository ou ficar complexo,
  criar um UseCase para preservar a cadeia
  `repositories -> UseCase -> ViewModel -> UI`.

## Ordem de execução

### 1. Definir contratos e erros de imagem

**Dependência:** backlog 003 concluído.

- [x] Definir contratos para selecionar, comprimir, promover e remover imagens.
- [x] Representar uma imagem preparada sem confundi-la com referência
      persistida.
- [x] Definir caminhos temporário e definitivo sem expor `Directory` à UI.
- [x] Mapear falhas de seleção, compressão e arquivo para `AppError`
      distinguível.
- [x] Manter cancelamento do picker como resultado esperado, não como erro.

**Resultado esperado:** operações de imagem possuem fronteiras injetáveis e não
dependem de widgets ou controllers.

**Entregue em 2026-08-19:** contratos separados de seleção, compressão e
armazenamento; tipos distintos para seleção cancelada, imagem selecionada,
imagem temporária preparada e imagem persistida; referências opacas sem tipos
de filesystem; códigos próprios de `AppError` para seleção, compressão, leitura,
escrita e remoção de imagens.

### 2. Implementar serviços de imagem em data

**Dependência:** tarefa 1.

- [x] Encapsular `image_picker` em uma implementação de seleção.
- [x] Encapsular `flutter_image_compress` em uma implementação de compressão.
- [x] Encapsular `path_provider`, diretórios e arquivos em serviço de
      armazenamento.
- [x] Criar diretórios sob demanda.
- [x] Preparar imagens em localização temporária.
- [x] Promover imagens para nomes definitivos sem sobrescrever arquivo vigente.
- [x] Remover arquivos de forma idempotente quando apropriado.
- [x] Listar e limpar somente imagens não referenciadas.

**Resultado esperado:** nenhum fluxo de usuários fora de `data` acessa APIs de
arquivo, diretório ou compressão.

**Entregue em 2026-08-19:** implementações substituíveis para galeria e
compressão, preparação em diretório temporário, armazenamento definitivo sob o
diretório de documentos, nomes resistentes a colisão, promoção sem sobrescrita,
remoção idempotente e limpeza por referências persistidas.

### 3. Implementar a coordenação de persistência e compensação

**Dependências:** tarefas 1 e 2.

- [ ] Coordenar cadastro com promoção da imagem e inserção no repository.
- [ ] Remover a imagem promovida se a inserção falhar.
- [ ] Coordenar edição preservando imagem e referência anteriores até o sucesso.
- [ ] Remover a imagem promovida se a atualização falhar.
- [ ] Após atualização bem-sucedida, remover a imagem anterior somente se não
      estiver referenciada.
- [ ] Persistir exclusão antes de limpar sua imagem sem referência.
- [ ] Preservar o cache anterior quando repository ou compensação principal
      falhar.
- [ ] Avaliar a complexidade da coordenação antes de implementá-la no
      `UsersViewModel`.
- [ ] Criar um UseCase específico se houver acesso a mais de um repository ou
      se as regras de compensação tornarem o ViewModel complexo.
- [ ] Quando criado, fazer o UseCase receber repositories e serviços por
      construtor e devolver `Result`/`AppError` ao ViewModel.
- [ ] Não criar UseCase que seja apenas encaminhamento sem coordenação ou regra
      própria.

**Resultado esperado:** banco nunca referencia uma imagem que não chegou ao
armazenamento definitivo, e falhas não destroem a imagem vigente.

### 4. Criar UsersViewModel e Commands

**Dependências:** tarefas 1 a 3 e padrão do backlog 004.

- [ ] Criar `UsersViewModel` com dependências recebidas por construtor,
      consumindo o UseCase quando a tarefa 3 indicar sua necessidade.
- [ ] Expor Commands para carregar, adicionar, editar e excluir usuários.
- [ ] Expor models de domínio a partir do cache do `UserRepository`.
- [ ] Representar loading e último `AppError` sem estados paralelos legados.
- [ ] Inicializar a seleção com os IDs dos atletas ativos.
- [ ] Expor seleção como coleção não modificável.
- [ ] Implementar seleção, desseleção e consulta de seleção.
- [ ] Impedir exclusão de usuário selecionado.
- [ ] Não armazenar `BuildContext`, widgets ou `TextEditingController`.

**Resultado esperado:** operações e estado de apresentação da página ficam em
um ViewModel testável.

### 5. Migrar formulário e página

**Dependência:** tarefa 4.

- [ ] Manter controllers de texto e validação no formulário visual.
- [ ] Remover `File` e `AppSettings.instance.imagePath` de `UserController`.
- [ ] Fazer o formulário distinguir imagem persistida de imagem preparada.
- [ ] Manter preview sem apagar ou substituir antecipadamente o arquivo antigo.
- [ ] Fazer `UsersPage` consumir o `UsersViewModel` e seus Commands.
- [ ] Remover `_selectedUsers` e outros estados duplicados da Page.
- [ ] Manter dialogs, picker visual e Navigator 1.0 na Page.
- [ ] Entregar a seleção final ao cronômetro legado ao sair.
- [ ] Preservar layout, campos e mensagens atuais.

**Resultado esperado:** a UI coordena interação visual, mas não acessa
persistência nem sistema de arquivos.

### 6. Atualizar injeção e remover o adapter legado

**Dependência:** tarefa 5.

- [ ] Registrar serviços e implementações de imagem no `AutoInjector`.
- [ ] Registrar factory de `UsersViewModel` com ciclo de vida da página.
- [ ] Atualizar a criação da rota de usuários.
- [ ] Remover `UsersPageController` quando ficar sem consumidores.
- [ ] Remover `UserManager` e seu registro quando ficar sem consumidores.
- [ ] Confirmar que somente o composition root acessa o injector.

**Resultado esperado:** a feature usa diretamente contratos injetáveis e não
possui adapter intermediário do backlog 003.

### 7. Testar compensações e comportamento migrado

**Dependências:** tarefas 2 a 6.

- [ ] Testar carregamento e preservação do cache em falhas.
- [ ] Testar seleção, desseleção e bloqueio de exclusão.
- [ ] Testar cadastro e edição sem nova imagem.
- [ ] Testar cadastro e edição com nova imagem.
- [ ] Testar cancelamento da seleção.
- [ ] Testar falha de compressão e de promoção do arquivo.
- [ ] Testar remoção compensatória da imagem nova quando o banco falhar.
- [ ] Testar preservação da imagem anterior quando a edição falhar.
- [ ] Testar remoção da imagem anterior após sucesso.
- [ ] Testar que arquivo ainda referenciado nunca é removido.
- [ ] Testar limpeza de arquivo órfão e remoção idempotente.

**Resultado esperado:** caminhos modificados e limites entre arquivo e banco
possuem cobertura proporcional ao risco.

### 8. Validar e documentar a entrega

**Dependência:** tarefas 1 a 7.

- [ ] Executar `dart format` nos arquivos alterados.
- [ ] Executar os testes próximos da feature, services e repositories.
- [ ] Executar a suíte completa com `flutter test`.
- [ ] Executar `flutter analyze` sem novas issues.
- [ ] Executar `git diff --check`.
- [ ] Validar manualmente cadastro, edição, exclusão e seleção.
- [ ] Registrar limitações mantidas para os backlogs 006 e 008.
- [ ] Atualizar o acompanhamento de `005-usuarios-e-imagens.md`.
- [ ] Mover backlog e tasks concluídos para `doc/backlog/closed/`.

**Resultado esperado:** o fluxo de usuários funciona em MVVM, operações de
imagem são recuperáveis e o backlog 006 pode consumir a seleção preservada.

## Regra de conclusão

O backlog só pode ser encerrado quando nenhuma referência persistida apontar
para arquivo inexistente, nenhuma limpeza remover arquivo referenciado e o
fluxo migrado deixar de depender de `UserManager`.
