# Data services

Data services encapsulam a fonte local de dados.

## Responsabilidades

- receber suas dependências por parâmetros nomeados e obrigatórios no
  construtor;
- conhecer SQLite, SQL, tabelas, colunas e `Map<String, Object?>`;
- executar CRUD e transações;
- converter registros em models antes de devolvê-los ao repository;
- converter falhas esperadas em `Result` e `AppError`.

Services não mantêm o cache compartilhado da aplicação e não acessam o
`AutoInjector`. Um service não instancia o serviço de banco, outro service ou
um repository dentro de sua implementação.

## Contextos previstos

- `database`: ciclo de vida, schema e backup;
- `settings`: configurações persistidas;
- `users`: usuários e referências de imagem;
- `trainings`: treinos por usuário;
- `histories`: registros e transações de histórico.

Cada diretório será criado junto da primeira classe concreta correspondente.
Não haverá uma camada DAO adicional.
