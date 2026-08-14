# Backlog da reestruturação

Este diretório organiza a migração incremental do Trainer's Stopwatch para
MVVM, tomando `go-list2/mobile` como referência e preservando BLoC no núcleo
temporal do cronômetro.

A execução começa na base e sobe até a interface. Cada backlog deve deixar a
aplicação executável e só pode remover a implementação antiga quando o fluxo
migrado estiver funcional.

## Ordem de execução

| Ordem | Backlog | Camada principal | Dependência |
| --- | --- | --- | --- |
| 001 | [Fundação arquitetural](closed/001-fundacao-arquitetural.md) | core | concluído |
| 002 | [Domínio puro](closed/002-dominio-puro.md) | domain | concluído |
| 003 | [Persistência e repositories](003-persistencia-e-repositories.md) | data | 001 e 002 concluídos |
| 004 | [Configurações em MVVM](closed/004-configuracoes-mvvm.md) | data + ui piloto | concluído |
| 005 | [Usuários e imagens](005-usuarios-e-imagens.md) | data + ui | 003 e 004 |
| 006 | [Treinos e históricos](006-treinos-e-historicos.md) | domain + data + ui | 003 e 005 |
| 007 | [Núcleo temporal do cronômetro](007-nucleo-cronometro-bloc.md) | BLoC | 002 e 003 |
| 008 | [Sessões e múltiplos cronômetros](008-sessoes-multiplos-cronometros.md) | application + ui | 006 e 007 |
| 009 | [Relatórios e compartilhamento](009-relatorios-e-compartilhamento.md) | domain + data + ui | 006 |
| 010 | [Consolidação da UI e legado](010-consolidacao-ui-e-legado.md) | ui | 004 a 009 |

## Regras de execução

- Navigator 1.0 e rotas nomeadas serão mantidos.
- ViewModels não recebem `BuildContext` nem armazenam widgets.
- Dependências novas são recebidas por construtor.
- UseCases só são criados quando coordenam operações relevantes.
- O banco existente deve permanecer compatível.
- O BLoC controla tempo; ViewModels controlam operação e apresentação.
- Testes acompanham o comportamento alterado em cada backlog; cobertura não é
  o objetivo da reestruturação.
- Decisões tomadas durante a implementação devem ser registradas no backlog
  correspondente.

## Ciclo de um backlog

1. revisar questões em aberto e fechar decisões necessárias;
2. criar um arquivo `NNN-...-tasks.md` apenas quando o backlog entrar em
   execução;
3. implementar em incrementos pequenos;
4. validar análise, testes afetados e fluxo manual correspondente;
5. registrar limitações e mover os documentos concluídos para
   `doc/backlog/closed/`.
