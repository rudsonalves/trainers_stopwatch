# 001 — Fundação arquitetural

## Objetivo

Criar a infraestrutura mínima compartilhada pela arquitetura MVVM, sem migrar
páginas nem alterar regras funcionais da aplicação.

## Dependência

Nenhuma. Este é o primeiro backlog da reestruturação.

## Escopo

- criar a estrutura inicial de `lib/core`;
- adaptar `Result<T>`, `Success`, `Failure`, `AppError`, `Unit`, `Command0` e
  `Command1` a partir de `go-list2/mobile`;
- definir categorias iniciais de erro apenas para necessidades já existentes;
- estabelecer logging transversal sem dados sensíveis;
- criar o composition root com `AutoInjector` e registrar dependências por
  construtor;
- adotar `Viewmodel` como nomenclatura padrão para classes e arquivos;
- manter a inicialização atual do banco por adapter temporário;
- documentar regras de dependência entre `core`, `domain`, `data` e `ui`;
- manter Navigator 1.0 fora dos Viewmodels.

## Fora de escopo

- migrar models, repositories, páginas ou cronômetro;
- alterar schema SQLite;
- introduzir Router API/Navigator 2.0;
- criar contratos genéricos sem consumidor concreto.

## Erros da primeira etapa

`AppError` será o erro esperado que atravessa as novas fronteiras. Ele terá, no
mínimo, `code`, `message` e `details` opcional para diagnóstico. `details` não
será exibido diretamente ao usuário nem poderá carregar conteúdo sensível.

Os códigos iniciais serão:

| `AppErrorCode` | Quando usar nesta etapa |
| --- | --- |
| `databaseUnavailable` | não foi possível localizar ou abrir o banco existente |
| `databaseCreationFailed` | criação inicial de tabelas ou índices falhou |
| `migrationFailed` | um script ou atualização da versão lógica falhou |
| `backupFailed` | não foi possível criar a cópia de segurança anterior à migration |
| `restoreFailed` | a tentativa de restaurar um backup não terminou com consistência confirmada |
| `storageReadFailed` | leitura local necessária ao bootstrap falhou |
| `storageWriteFailed` | gravação local necessária ao bootstrap falhou |
| `invalidData` | dado persistido obrigatório está ausente, inválido ou incompatível |
| `unexpected` | falha não classificada capturada na fronteira de um Command/bootstrap |

As categorias representam o significado para o aplicativo, não classes de
exceção do `sqflite`, `dart:io` ou plugins. O adapter responsável converte a
falha de infraestrutura para o código correspondente e mantém a causa técnica
somente em `details`/log.

Não entram ainda códigos de usuário, imagem, relatório, compartilhamento ou
cronômetro. Eles devem nascer nos backlogs que introduzirem seus consumidores.

### Comportamento esperado no bootstrap

| Situação atual | Comportamento a preparar |
| --- | --- |
| abertura do banco falha e chama `exit(1)` | devolver `databaseUnavailable` sem encerrar o processo abruptamente |
| criação das tabelas falha | devolver `databaseCreationFailed` preservando a causa |
| backup retorna `null` e a inicialização continua | devolver `backupFailed` quando houver migration pendente |
| migration falha | devolver `migrationFailed` e iniciar restauração |
| restauração falha ou não confirma consistência | devolver `restoreFailed` como falha crítica distinta |
| leitura de settings falha e é tratada como registro ausente | devolver `storageReadFailed`; ausência legítima continua sendo ausência |
| criação dos settings iniciais falha | devolver `storageWriteFailed` |
| valor persistido não pode ser convertido | devolver `invalidData` |
| exceção não prevista atravessa um Command | converter para `unexpected` |

Este backlog cria os contratos e prepara o bootstrap para essas distinções. A
conversão completa de todos os DAOs e repositories ocorrerá no backlog 003.

## Questões em aberto

Nenhuma questão permanece aberta nesta etapa. As decisões de bootstrap estão
registradas abaixo.

## Critérios de aceite

- `core` não depende de `data`, `domain` ou `ui`;
- `Result` e `Command` possuem contratos equivalentes aos do projeto de
  referência;
- `AutoInjector` resolve o grafo e `setupDependencies()` é idempotente;
- dependências podem ser resolvidas sem usar novos singletons;
- classes e arquivos novos usam a nomenclatura `Viewmodel`;
- o bootstrap atual continua abrindo a aplicação e o banco;
- os códigos iniciais de `AppError` estão implementados e documentados;
- Commands convertem falhas não previstas em `unexpected`;
- o novo caminho de bootstrap não usa `exit(1)` como tratamento de erro;
- ausência legítima de settings não é confundida com falha de leitura;
- falhas inesperadas não chegam cruas à futura UI pelos Commands;
- nenhuma mudança funcional é introduzida;
- análise e testes afetados terminam sem novos erros.

## Decisões

### 2026-08-13 — Navigator 1.0 preservado

**Decisão:** manter rotas nomeadas e Navigator 1.0 durante a reestruturação.

**Motivo:** os fluxos atuais são pequenos e lineares; roteamento declarativo não
traz benefício proporcional neste momento.

**Consequências:** navegação, dialogs e `BuildContext` permanecem nas Pages;
Viewmodels expõem estado e resultados, nunca ações de navegação.

### 2026-08-13 — AutoInjector no composition root

**Decisão:** usar `AutoInjector`, seguindo `go-list2/mobile`.

**Motivo:** manter o mesmo mecanismo de composição dos projetos atuais e
centralizar a construção do grafo sem transformar consumidores em service
locators.

**Consequências:** `setupDependencies()` será idempotente, fará todos os
registros antes de `commit()` e o injector será consultado apenas no composition
root/factories de Page. Classes de domínio, repositories e Viewmodels continuarão
recebendo dependências pelo construtor.

### 2026-08-13 — Nomenclatura `Viewmodel`

**Decisão:** usar `Viewmodel` nos nomes de classes e `viewmodel` em arquivos e
diretórios.

**Motivo:** alinhar o projeto à nomenclatura já usada em `go-list2/mobile`.

**Consequências:** novos tipos seguirão exemplos como `SettingsViewmodel` e
`settings_viewmodel.dart`. Renomeações do legado ocorrerão junto da migração da
feature, sem alteração mecânica antecipada de todo o projeto.

### 2026-08-13 — Catálogo mínimo de erros

**Decisão:** iniciar `AppErrorCode` apenas com falhas de banco/bootstrap,
leitura/gravação, dados inválidos e erro inesperado descritas neste backlog.

**Motivo:** a fundação precisa distinguir falhas já presentes sem antecipar uma
taxonomia extensa para features ainda não migradas.

**Consequências:** adapters traduzirão exceções técnicas; códigos específicos de
imagem, relatório, compartilhamento e cronômetro serão acrescentados por demanda.

### 2026-08-13 — Fallback mínimo de bootstrap

**Decisão:** falha de inicialização abre uma tela mínima com o código do erro,
sem nova tentativa nesta etapa.

**Motivo:** o bootstrap precisa parar de encerrar o processo abruptamente, mas o
fluxo visual recuperável pertence à futura reorganização da UI.

**Consequências:** o usuário recebe um estado explícito; retry e localização da
mensagem permanecem adiados para um backlog de UI.

### 2026-08-13 — Backup obrigatório antes de migration

**Decisão:** migration pendente não será executada se o backup falhar.

**Motivo:** continuar sem uma cópia válida aumenta o risco de perda de dados.

**Consequências:** o bootstrap retorna `backupFailed` e mantém o banco original
sem executar scripts.

### 2026-08-13 — Falha de migration interrompe o bootstrap

**Decisão:** mesmo quando a restauração for bem-sucedida, a falha da migration
interrompe a inicialização atual.

**Motivo:** abrir silenciosamente a versão anterior esconderia uma atualização
incompleta e repetiria a migration sem apresentar o problema.

**Consequências:** restauração bem-sucedida retorna `migrationFailed`;
restauração sem consistência confirmada retorna `restoreFailed`.

## Acompanhamento

**Estado:** Concluído em 2026-08-13.

**Implementação entregue:**

- contratos `Result`, `AppError`, `Unit`, `Command0` e `Command1`;
- catálogo inicial de erros da aplicação;
- logging transversal de desenvolvimento;
- composition root idempotente com `AutoInjector`;
- bootstrap resolvido pelo injector e representado por `AsyncResult<Unit>`;
- abertura do banco sem `exit(1)`;
- distinção entre abertura, criação, settings, backup, migration e restauração;
- fallback visual mínimo para falha de inicialização;
- 8 testes novos de resultado, Commands e composição;
- suíte completa com 11 testes aprovada;
- `flutter analyze` aprovado sem issues.

**Limitações e itens adiados:**

- `DatabaseManager` e `AppSettings` continuam singletons registrados como
  adapters temporários;
- a conversão completa dos stores/DAOs ocorrerá no backlog 003;
- a tela de erro ainda não possui localização nem nova tentativa;
- erros específicos de features serão criados somente por demanda.

**Próximo backlog:** [`002-dominio-puro.md`](002-dominio-puro.md).
