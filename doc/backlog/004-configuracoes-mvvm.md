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
- preservar valores atuais, defaults e comportamento do tutorial;
- definir adapter temporário para consumidores ainda dependentes de
  `AppSettings`.

## Fora de escopo

- redesenhar a interface de configurações;
- migrar o `StopwatchBloc`;
- remover `AppSettings` enquanto houver consumidores não migrados;
- alterar unidades ou defaults sem decisão funcional.

## Questões em aberto

1. Qual objeto será a fonte observável global de tema e idioma após o singleton?
2. Alterações serão salvas imediatamente ou confirmadas ao sair da página?
3. O estado do tutorial pertence às configurações persistidas ou à sessão da UI?

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

Nenhuma decisão adicional aprovada.

## Acompanhamento

**Estado:** Planejado — primeiro piloto MVVM.

**Próximo backlog:** `005-usuarios-e-imagens.md`.

