# 004 — Configurações em MVVM

## Objetivo

Usar configurações como primeiro fluxo vertical para validar MVVM sobre a nova
fundação e persistência, antes de alterar o núcleo do cronômetro.

## Dependência

Depende de `003-persistencia-e-repositories.md`.

## Escopo

- criar `SettingsRepository` e implementação sobre o DAO novo;
- criar `SettingsViewModel` com dependências por construtor;
- expor Commands para carregar e salvar configurações;
- separar configurações persistidas do estado observável de tema/idioma;
- remover acesso direto a `AppSettings.instance` da página migrada;
- manter controllers visuais e `BuildContext` na Page;
- manter Navigator 1.0 no fechamento e navegação da página;
- preservar valores atuais e defaults;
- manter removido o sistema de tutorial da aplicação durante a migração MVVM;
- definir adapter temporário para consumidores ainda dependentes de
  `AppSettings`.

## Fora de escopo

- redesenhar a interface de configurações;
- migrar o `StopwatchBloc`;
- remover `AppSettings` enquanto houver consumidores não migrados;
- alterar unidades ou defaults sem decisão funcional.

## Questões em aberto

Nenhuma.

## Critérios de aceite

- a Page usa `SettingsViewModel`, não repository, DAO ou singleton diretamente;
- o ViewModel não recebe `BuildContext`;
- loading, sucesso e falha são observáveis por Commands/estado;
- tema, contraste, idioma e medidas mantêm o comportamento atual;
- consumidores legados continuam funcionando durante a transição;
- a aplicação permanece no Navigator 1.0;
- testes cobrem somente comportamento alterado do repository/ViewModel;
- análise termina sem novos erros.

## Decisões

- `AppSettingsViewModel`, singleton por registro no `AutoInjector` e recebido
  por construtor pelo `MyMaterialApp`, será a única fonte observável global de
  tema, contraste e idioma.
- `SettingsRepository` permanece responsável pela persistência e pelo cache de
  domínio.
- `SettingsViewModel` sincroniza as alterações globais com o
  `AppSettingsViewModel`.
- Toda alteração válida feita na `SettingsPage` será persistida imediatamente,
  sem botão de confirmação e sem depender do fechamento da página.
- O sistema de tutorial foi removido integralmente da aplicação antes da
  migração MVVM. Seu estado deixou de fazer parte das configurações persistidas
  e da UI; a coluna legada do banco permanece apenas por compatibilidade.
- `AppSettings` permanece como adapter temporário para consumidores legados
  durante a migração.

## Acompanhamento

**Estado:** Planejado — primeiro piloto MVVM.

**Próximo backlog:** `005-usuarios-e-imagens.md`.
