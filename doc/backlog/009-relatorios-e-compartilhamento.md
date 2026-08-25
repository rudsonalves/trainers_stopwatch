# 009 — Relatórios e compartilhamento

## Objetivo

Separar o conteúdo do relatório de sua renderização e colocar PDF, arquivos,
e-mail e compartilhamento atrás de serviços injetáveis.

## Dependência

Depende do backlog
[`006-treinos-e-historicos.md`](closed/006-treinos-e-historicos.md), concluído,
e do domínio puro do backlog 002.

## Escopo

- manter a montagem de linhas e totais do relatório no domínio;
- criar serviço de renderização PDF que receba dados prontos;
- impedir `BuildPdf` de instanciar repository diretamente;
- criar contratos para arquivo temporário, compartilhamento e e-mail;
- criar UseCase para carregar históricos e montar o relatório completo;
- expor Commands no ViewModel da página de treinos;
- tratar falhas esperadas como `AppError`;
- garantir limpeza previsível dos arquivos temporários;
- manter textos localizados na fronteira de apresentação/renderização.
- fazer relatório e compartilhamento receberem apenas `User`, `Training`,
  `HistoryEntry` e eventos de domínio, removendo suas dependências dos adapters
  e models legados ainda compartilhados com o cronômetro;

## Fora de escopo

- redesenhar visualmente o PDF sem requisito próprio;
- fazer repository conhecer plugins de compartilhamento;
- colocar widgets ou `BuildContext` nos serviços;
- alterar a configuração central do `go_router`.

## Questões em aberto

Nenhuma.

## Critérios de aceite

- conteúdo do relatório pode ser produzido sem plugin ou bundle Flutter;
- renderer PDF não consulta banco;
- ViewModel não acessa arquivo, e-mail ou compartilhamento diretamente;
- arquivos temporários possuem ownership e limpeza definidos;
- falhas são apresentáveis sem exceções cruas;
- conteúdo e compartilhamento preservam o comportamento atual;
- testes acompanham conteúdo e coordenação modificados; plugins usam fakes;
- análise termina sem novos erros.

## Decisões

- Nesta versão, o PDF mantém o comportamento atual de uma página por treino.
- O UseCase é responsável pelo ciclo de vida do arquivo temporário e deve
  garantir sua limpeza após o compartilhamento, inclusive em caso de falha.
- Nesta versão, o corpo do e-mail permanece em HTML e localizado; o serviço de
  e-mail recebe assunto e corpo já preparados na fronteira de apresentação.
- Nesta versão, relatórios vazios e treinos sem parciais mantêm a representação
  atual, protegida por testes de caracterização antes da refatoração.

## Acompanhamento

**Estado:** Em execução.

**Plano de tarefas:**
[`009-relatorios-e-compartilhamento-tasks.md`](009-relatorios-e-compartilhamento-tasks.md).

**Próximo backlog:** `010-consolidacao-ui-e-legado.md`.
