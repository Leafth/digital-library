
workspace "Biblioteca Digital - C4 Devoluções" "Registro de devoluções de exemplares físicos" {

    model {
        biblioteca = softwareSystem "Sistema de Biblioteca Digital" {

            api = container "API da Biblioteca" "Backend NestJS" "NestJS, TypeScript" {

                group "Adaptadores de Entrada" {
                    controller = component "DevolucaoController" "Recebe requisições de devolução e retorna o resultado." "Controller NestJS" {
                        tags "Entrada"
                    }

                    responseDto = component "DevolucaoResponseDto" "Dados da devolução, situação do exemplar e próximo leitor." "DTO" {
                        tags "Entrada"
                    }
                }

                group "Aplicação" {
                    useCase = component "RegistrarDevolucaoUseCase" "Coordena o registro de devoluções, consulta reservas e atualiza o exemplar." "Use Case" {
                        tags "Aplicacao"
                    }

                    input = component "RegistrarDevolucaoInput" "Identificador do empréstimo a devolver." "Input"
                    output = component "RegistrarDevolucaoOutput" "Resultado do registro da devolução." "Output"
                }

                group "Domínio" {
                    emprestimo = component "Emprestimo" "Registra data de devolução e altera status para DEVOLVIDO." "Entity" {
                        tags "Dominio"
                    }

                    exemplar = component "Exemplar" "Controla a disponibilidade: DISPONIVEL, EMPRESTADO, RESERVADO ou INDISPONIVEL." "Entity" {
                        tags "Dominio"
                    }

                    reserva = component "Reserva" "Representa a reserva de uma obra e sua posição na fila de prioridade." "Entity" {
                        tags "Dominio"
                    }

                    leitor = component "Leitor" "Representa o usuário associado a empréstimos e reservas." "Entity" {
                        tags "Dominio"
                    }
                }

                group "Portas de Saída" {
                    emprestimoRepo = component "EmprestimoRepository" "buscarPorId(id), salvar(emprestimo)." "Interface" {
                        tags "Porta"
                    }

                    exemplarRepo = component "ExemplarRepository" "buscarPorIdComBloqueio(id), salvar(exemplar)." "Interface" {
                        tags "Porta"
                    }

                    reservaRepo = component "ReservaRepository" "buscarProximaDaFila(obraId), salvar(reserva)." "Interface" {
                        tags "Porta"
                    }

                    unitOfWork = component "UnitOfWork" "executar(trabalho): operação transacional." "Interface" {
                        tags "Porta"
                    }

                    relogio = component "Relogio" "agora(): Date." "Interface" {
                        tags "Porta"
                    }
                }

                group "Adaptadores de Saída" {
                    prismaEmprestimo = component "PrismaEmprestimoRepository" "Implementa persistência de empréstimos." "Prisma" {
                        tags "Adaptador"
                    }

                    prismaExemplar = component "PrismaExemplarRepository" "Implementa persistência de exemplares." "Prisma" {
                        tags "Adaptador"
                    }

                    prismaReserva = component "PrismaReservaRepository" "Implementa persistência de reservas." "Prisma" {
                        tags "Adaptador"
                    }

                    prismaUow = component "PrismaUnitOfWork" "Executa operações em uma transação Prisma." "Prisma" {
                        tags "Adaptador"
                    }

                    relogioSistema = component "RelogioSistema" "Fornece a data e hora atuais." "TypeScript" {
                        tags "Adaptador"
                    }

                    prismaService = component "PrismaService" "Cliente de acesso ao PostgreSQL." "Prisma Client" {
                        tags "Infra"
                    }
                }

                controller -> useCase "Executa registrar devolução"
                controller -> responseDto "Retorna"

                useCase -> input "Recebe"
                useCase -> output "Produz"

                useCase -> emprestimo "Registra devolução"
                useCase -> exemplar "Atualiza disponibilidade"
                useCase -> reserva "Identifica próxima reserva"

                emprestimo -> exemplar "Refere-se a"
                emprestimo -> leitor "Pertence a"
                reserva -> leitor "Pertence a"
                reserva -> exemplar "Reserva obra associada ao exemplar"

                useCase -> emprestimoRepo "Busca e salva empréstimo"
                useCase -> exemplarRepo "Busca e salva exemplar"
                useCase -> reservaRepo "Consulta fila e atualiza reserva"
                useCase -> unitOfWork "Executa transação"
                useCase -> relogio "Consulta data atual"

                prismaEmprestimo -> emprestimoRepo "Implementa"
                prismaExemplar -> exemplarRepo "Implementa"
                prismaReserva -> reservaRepo "Implementa"
                prismaUow -> unitOfWork "Implementa"
                relogioSistema -> relogio "Implementa"

                prismaEmprestimo -> prismaService "Utiliza"
                prismaExemplar -> prismaService "Utiliza"
                prismaReserva -> prismaService "Utiliza"
                prismaUow -> prismaService "Utiliza"
            }
        }
    }

    views {
        component api "C4_Devolucoes" {
            title "C4 - Registro de Devoluções"
            description "Estrutura de código responsável pelo registro de devoluções e gerenciamento da disponibilidade de exemplares."

            include *

            autoLayout tb
        }

        styles {
            element "Element" {
                shape RoundedBox
                background #64748b
                color #ffffff
            }

            element "Entrada" {
                background #1d4ed8
            }

            element "Aplicacao" {
                background #0284c7
            }

            element "Dominio" {
                background #0f766e
            }

            element "Porta" {
                background #7c3aed
                shape Hexagon
            }

            element "Adaptador" {
                background #475569
            }

            element "Infra" {
                background #334155
            }

            relationship "Relationship" {
                color #64748b
                thickness 2
            }
        }
    }
}
