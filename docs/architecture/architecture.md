# Documentação Arquitetural

Esta documentação apresenta as visões arquiteturais do **Sistema de Biblioteca Digital**, seguindo o modelo C4.

Os diagramas são desenvolvidos em **Structurizr DSL**, representando a estrutura do sistema, seus componentes e suas interações.

Os modelos, relacionamentos, visões e estilos estão definidos no arquivo [workspace.dsl](structurizr/workspace.dsl).

## C1 — Diagrama de Contexto

Apresenta o Sistema de Biblioteca Digital, seus usuários (Leitor e Bibliotecário) e as integrações com o Serviço de E-mail e o Repositório de Conteúdo Digital.

![Diagrama de Contexto](diagrams/c1-contexto.svg)

## C2 — Diagrama de Containers

Detalha os principais containers do sistema: Aplicação Web, API da Biblioteca, Banco de Dados, Processador de Notificações e Fila de Notificações, incluindo suas tecnologias e mecanismos de comunicação.

![Diagrama de Containers](diagrams/c2-containers.svg)

## C3 — Diagrama de Componentes

### API da Biblioteca

Apresenta os componentes internos da API NestJS, organizados conforme os princípios da Arquitetura Hexagonal e da Clean Architecture, incluindo adaptadores de entrada, casos de uso, domínio, portas e adaptadores de saída.

![Diagrama de Componentes da API](diagrams/c3-api.svg)

## C4 — Diagrama de Código

Os diagramas de código são diagramas de classes UML desenvolvidos em **PlantUML**, com código-fonte em [plantuml](plantuml/).

### Realização de Empréstimos

Detalha as classes, interfaces e dependências do componente **Casos de Uso: Empréstimos** da API. O `RealizarEmprestimoUseCase` aplica as regras da `PoliticaEmprestimo` (leitor ativo, limite de 3 empréstimos ativos, bloqueio por atraso e prazo de 14 dias) e respeita a prioridade da fila de reservas da obra. Ele depende apenas das portas de saída, que são implementadas pelos adaptadores Prisma.

![Diagrama de Código - Realização de Empréstimos](diagrams/c4-emprestimos.svg)
