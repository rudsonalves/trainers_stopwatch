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
| 003 | [Persistência e repositories](closed/003-persistencia-e-repositories.md) | data | concluído |
| 004 | [Configurações em MVVM](closed/004-configuracoes-mvvm.md) | data + ui piloto | concluído |
| 005 | [Usuários e imagens](closed/005-usuarios-e-imagens.md) | data + ui | concluído |
| 006 | [Treinos e históricos](closed/006-treinos-e-historicos.md) | domain + data + ui | concluído |
| 007 | [Núcleo temporal do cronômetro](closed/007-nucleo-cronometro-bloc.md) | BLoC | concluído |
| 008 | [Sessões e múltiplos cronômetros](closed/008-sessoes-multiplos-cronometros.md) | ui | concluído |
| 009 | [Relatórios e compartilhamento](closed/009-relatorios-e-compartilhamento.md) | domain + data + ui | concluído |
| 010 | [Consolidação da UI e legado](closed/010-consolidacao-ui-e-legado.md) | ui | concluído |
| 011 | [Ajustes de interface e interação](closed/011-ajustes-interface-e-interacao.md) | ui | concluído |
| 012 | [Ajuda contextual por página](012-ajuda-contextual.md) | ui | 010 concluído |
| 013 | [Relatórios parciais com treinos inválidos](013-relatorios-parciais-treinos-invalidos.md) | domain + ui | 009 concluído |

## Regras de execução

- `go_router` centraliza paths e nomes; Pages iniciam navegação e ViewModels não
  recebem `BuildContext`.
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
