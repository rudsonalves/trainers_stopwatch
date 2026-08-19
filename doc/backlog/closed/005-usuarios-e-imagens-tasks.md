# 005 — Tarefas concluídas de usuários e imagens

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

- [x] Coordenar cadastro com promoção da imagem e inserção no repository.
- [x] Remover a imagem promovida se a inserção falhar.
- [x] Coordenar edição preservando imagem e referência anteriores até o sucesso.
- [x] Remover a imagem promovida se a atualização falhar.
- [x] Após atualização bem-sucedida, remover a imagem anterior somente se não
      estiver referenciada.
- [x] Persistir exclusão antes de limpar sua imagem sem referência.
- [x] Preservar o cache anterior quando repository ou compensação principal
      falhar.
- [x] Avaliar a complexidade da coordenação antes de implementá-la no
      `UsersViewModel`.
- [x] Criar um UseCase específico se houver acesso a mais de um repository ou
      se as regras de compensação tornarem o ViewModel complexo.
- [x] Quando criado, fazer o UseCase receber repositories e serviços por
      construtor e devolver `Result`/`AppError` ao ViewModel.
- [x] Não criar UseCase que seja apenas encaminhamento sem coordenação ou regra
      própria.

**Resultado esperado:** banco nunca referencia uma imagem que não chegou ao
armazenamento definitivo, e falhas não destroem a imagem vigente.

**Entregue em 2026-08-19:** `UsersUseCase`, em `domain/usecases/users`, coordena
o repository e o serviço de armazenamento. Promoção falha antes de alcançar
banco e cache; falha de escrita remove a imagem nova; falha da própria
compensação preserva como detalhe o erro primário; edição e exclusão limpam
somente depois da persistência e usando a lista atual de referências. Falha na
limpeza posterior é devolvida ao consumidor, embora a mutação principal já
esteja persistida. Modelos compartilhados de imagem ficam em `domain/models`.

### 4. Criar UsersViewModel e Commands

**Dependências:** tarefas 1 a 3 e padrão do backlog 004.

- [x] Criar `UsersViewModel` com dependências recebidas por construtor,
      consumindo o UseCase quando a tarefa 3 indicar sua necessidade.
- [x] Expor Commands para carregar, adicionar, editar e excluir usuários.
- [x] Expor models de domínio a partir do cache do `UserRepository`.
- [x] Representar loading e último `AppError` sem estados paralelos legados.
- [x] Inicializar a seleção com os IDs dos atletas ativos.
- [x] Expor seleção como coleção não modificável.
- [x] Implementar seleção, desseleção e consulta de seleção.
- [x] Impedir exclusão de usuário selecionado.
- [x] Não armazenar `BuildContext`, widgets ou `TextEditingController`.

**Resultado esperado:** operações e estado de apresentação da página ficam em
um ViewModel testável.

**Entregue em 2026-08-19:** `UsersViewModel` recebe `UsersUseCase` e os IDs
inicialmente ativos, expõe Commands de carga, cadastro, edição e exclusão,
reflete o cache de domínio sem duplicá-lo, consolida loading e último
`AppError`, mantém seleção imutável para consumidores e bloqueia exclusão de
qualquer usuário selecionado.

### 5. Migrar formulário e página

**Dependência:** tarefa 4.

- [x] Manter controllers de texto e validação no formulário visual.
- [x] Remover `File` e `AppSettings.instance.imagePath` de `UserController`.
- [x] Fazer o formulário distinguir imagem persistida de imagem preparada.
- [x] Manter preview sem apagar ou substituir antecipadamente o arquivo antigo.
- [x] Fazer `UsersPage` consumir o `UsersViewModel` e seus Commands.
- [x] Remover `_selectedUsers` e outros estados duplicados da Page.
- [x] Manter dialogs, picker visual e Navigator 1.0 na Page.
- [x] Entregar a seleção final ao cronômetro legado ao sair.
- [x] Preservar layout, campos e mensagens atuais.

**Resultado esperado:** a UI coordena interação visual, mas não acessa
persistência nem sistema de arquivos.

**Entregue em 2026-08-19:** formulário e lista operam com `User` de domínio e
`UsersViewModel`; controllers e validação permanecem visuais; a câmera é
acionada pela interação do diálogo através do ViewModel e do UseCase; preview
temporário permanece separado da referência persistida e é descartado ao ser
substituído ou cancelado; seleção pertence somente ao ViewModel e é convertida
para o adapter legado ao retornar ao cronômetro. A rota nomeada e a composição
visual foram preservadas.

### 6. Atualizar injeção e remover o adapter legado

**Dependência:** tarefa 5.

- [x] Registrar serviços e implementações de imagem no `AutoInjector`.
- [x] Registrar factory de `UsersViewModel` com ciclo de vida da página.
- [x] Atualizar a criação da rota de usuários.
- [x] Remover `UsersPageController` quando ficar sem consumidores.
- [x] Verificar `UserManager`: mantê-lo e manter seu registro somente para o
      consumidor legado `TrainingsPageController`, com remoção atribuída ao
      backlog 006.
- [x] Confirmar que somente o composition root acessa o injector.

**Resultado esperado:** a feature usa diretamente contratos injetáveis e não
possui adapter intermediário do backlog 003.

**Entregue em 2026-08-19:** serviços de seleção, compressão e armazenamento são
singletons injetados; `UsersUseCase` é transient; `UsersViewModelFactory` é
singleton e cria um ViewModel descartável por abertura da rota, recebendo os
IDs ativos naquele momento. A rota usa a factory registrada,
`UsersPageController` e seus estados foram removidos e a feature de usuários
não passa por `UserManager`. O adapter permanece registrado exclusivamente
porque treinos ainda o consome e será removido pelo backlog 006. Apenas
`dependencies.dart` e `main.dart`, as duas partes do composition root, acessam
o injector.

### 7. Testar compensações e comportamento migrado

**Dependências:** tarefas 2 a 6.

- [x] Testar carregamento e preservação do cache em falhas.
- [x] Testar seleção, desseleção e bloqueio de exclusão.
- [x] Testar cadastro e edição sem nova imagem.
- [x] Testar cadastro e edição com nova imagem.
- [x] Testar cancelamento da seleção.
- [x] Testar falha de compressão e de promoção do arquivo.
- [x] Testar remoção compensatória da imagem nova quando o banco falhar.
- [x] Testar preservação da imagem anterior quando a edição falhar.
- [x] Testar remoção da imagem anterior após sucesso.
- [x] Testar que arquivo ainda referenciado nunca é removido.
- [x] Testar limpeza de arquivo órfão e remoção idempotente.

**Resultado esperado:** caminhos modificados e limites entre arquivo e banco
possuem cobertura proporcional ao risco.

**Entregue em 2026-08-19:** 40 testes focados cobrem ViewModel, formulário,
UseCase, cache, serviços de imagem e composition root. Um cenário integrado com
filesystem real confirma que a edição bem-sucedida preserva a nova referência
e remove o arquivo anterior somente depois da atualização.

### 8. Validar e documentar a entrega

**Dependência:** tarefas 1 a 7.

- [x] Executar `dart format` nos arquivos alterados.
- [x] Executar os testes próximos da feature, services e repositories.
- [x] Executar a suíte completa com `flutter test`.
- [x] Executar `flutter analyze` sem novas issues.
- [x] Executar `git diff --check`.
- [x] Registrar a dispensa da validação manual de cadastro, edição, exclusão e
      seleção nesta etapa, pois não havia dispositivo iOS/Android conectado e a
      sessão não opera interativamente câmera e diálogos no simulador.
- [x] Registrar limitações mantidas para os backlogs 006 e 008.
- [x] Atualizar o acompanhamento de `005-usuarios-e-imagens.md`.
- [x] Mover backlog e tasks concluídos para `doc/backlog/closed/`.

**Resultado esperado:** o fluxo de usuários funciona em MVVM, operações de
imagem são recuperáveis e o backlog 006 pode consumir a seleção preservada.

**Entregue em 2026-08-19:** `dart format` não alterou os 181 arquivos
verificados; os 210 testes da suíte completa passaram; `flutter analyze`
terminou sem issues; `git diff --check` passou. Para o backlog 006 permanece o
`UserManager` consumido exclusivamente por `TrainingsPageController`. Para o
backlog 008 permanece a conversão temporária da seleção de domínio para
`UserModel` ao alimentar os cronômetros legados.

## Regra de conclusão

O backlog só pode ser encerrado quando nenhuma referência persistida apontar
para arquivo inexistente, nenhuma limpeza remover arquivo referenciado e o
fluxo migrado deixar de depender de `UserManager`.
