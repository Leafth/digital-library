
workspace "Biblioteca Digital" "Arquitetura C4" {

    model {
        leitor = person "Leitor" "Consulta livros, realiza reservas e acompanha seu histórico."

        bibliotecario = person "Bibliotecário" "Gerencia o acervo e registra empréstimos e devoluções."

        biblioteca = softwareSystem "Sistema de Biblioteca Digital" "Gerencia acervo físico e digital, empréstimos, devoluções, reservas, históricos e notificações." {

            // Aplicação Web
            web = container "Aplicação Web" "Interface utilizada por leitores e bibliotecários." "React, TypeScript" {
                tags "Frontend"
            }

            // API
            api = container "API da Biblioteca" "Backend principal organizado como monólito modular." "NestJS, TypeScript, Prisma, JWT" {
                tags "Backend"

                group "Adaptadores de Entrada" {
                    controllers = component "REST Controllers" "Endpoints e DTOs." "NestJS" {
                        tags "Entrada"
                    }

                    guards = component "Auth Guards" "Autenticação JWT e autorização RBAC." "NestJS" {
                        tags "Entrada"
                    }
                }

                group "Aplicação" {
                    acervo = component "Casos de Uso: Acervo" "Gerenciar e consultar livros." {
                        tags "Aplicacao"
                    }

                    emprestimos = component "Casos de Uso: Empréstimos" "Registrar empréstimos de exemplares." {
                        tags "Aplicacao"
                    }

                    devolucoes = component "Casos de Uso: Devoluções" "Registrar devoluções e atualizar disponibilidade." {
                        tags "Aplicacao"
                    }

                    reservas = component "Casos de Uso: Reservas" "Gerenciar reservas por obra e fila de prioridade." {
                        tags "Aplicacao"
                    }

                    historico = component "Casos de Uso: Histórico" "Consultar e registrar histórico de leitura." {
                        tags "Aplicacao"
                    }
                }

                group "Domínio" {
                    dominio = component "Modelo de Domínio" "Entidades, políticas e invariantes de negócio." {
                        tags "Dominio"
                    }
                }

                group "Portas de Saída" {
                    repos = component "Repository Ports" "Contratos de persistência." {
                        tags "Porta"
                    }

                    filaPort = component "Notification Queue Port" "Contrato para publicação de tarefas de notificação." {
                        tags "Porta"
                    }

                    arquivoPort = component "Digital Content Port" "Contrato de acesso aos arquivos digitais." {
                        tags "Porta"
                    }
                }

                group "Adaptadores de Saída" {
                    prisma = component "Prisma Repositories" "Implementação dos contratos de persistência." "Prisma" {
                        tags "Adaptador"
                    }

                    bullmq = component "BullMQ Adapter" "Publicação de tarefas assíncronas." "BullMQ" {
                        tags "Adaptador"
                    }

                    http = component "HTTP Content Adapter" "Integração com o repositório digital." "HTTP" {
                        tags "Adaptador"
                    }
                }
            }

            // Persistência
            banco = container "Banco de Dados" "Armazena usuários, obras, exemplares, empréstimos, reservas e históricos." "PostgreSQL" {
                tags "Database"
            }

            // Fila
            fila = container "Fila de Notificações" "Armazena e gerencia os jobs de notificações assíncronas." "Redis, BullMQ" {
                tags "Queue"
            }

            // Processamento assíncrono
            worker = container "Processador de Notificações" "Consome jobs, envia notificações e agenda lembretes de devolução." "NestJS, TypeScript, BullMQ, Scheduler" {
                tags "Worker"

                group "Adaptadores de Entrada" {
                    agendador = component "Agendador de Lembretes" "Dispara periodicamente a busca de empréstimos próximos do vencimento." "NestJS Scheduler (@Cron)" {
                        tags "Entrada"
                    }

                    consumidor = component "Consumidor de Tarefas" "Consome os jobs da fila e aciona o caso de uso correspondente." "BullMQ Processor" {
                        tags "Entrada"
                    }
                }

                group "Aplicação" {
                    ucLembretes = component "Caso de Uso: Agendar Lembretes" "Identifica empréstimos a vencer e gera as tarefas de lembrete." {
                        tags "Aplicacao"
                    }

                    ucNotificar = component "Caso de Uso: Processar Notificação" "Reúne os dados do leitor e da obra e dispara o envio." {
                        tags "Aplicacao"
                    }

                    mensagens = component "Montador de Mensagens" "Monta assunto e corpo do e-mail a partir de templates." {
                        tags "Aplicacao"
                    }
                }

                group "Portas de Saída" {
                    dadosPort = component "Notification Data Port" "Contrato de consulta a leitores, obras e empréstimos." {
                        tags "Porta"
                    }

                    publicarPort = component "Job Publisher Port" "Contrato de publicação de tarefas." {
                        tags "Porta"
                    }

                    emailPort = component "Email Sender Port" "Contrato de envio de e-mail." {
                        tags "Porta"
                    }
                }

                group "Adaptadores de Saída" {
                    prismaLeitura = component "Prisma Read Repositories" "Consultas de leitura com Prisma." "Prisma" {
                        tags "Adaptador"
                    }

                    bullPublisher = component "BullMQ Publisher" "Publicação de jobs na fila." "BullMQ" {
                        tags "Adaptador"
                    }

                    smtp = component "SMTP Email Adapter" "Integração com o serviço de e-mail." "Nodemailer" {
                        tags "Adaptador"
                    }
                }
            }
        }

        email = softwareSystem "Serviço de E-mail" "Envia notificações de reservas e lembretes de devolução." {
            tags "External"
        }

        conteudo = softwareSystem "Repositório de Conteúdo Digital" "Armazena arquivos PDF e EPUB." {
            tags "External,Files"
        }


        leitor -> web "Consulta livros, realiza reservas e acompanha histórico" "HTTPS"

        bibliotecario -> web "Gerencia o acervo, empréstimos e devoluções" "HTTPS"

        web -> api "Consome endpoints REST" "HTTPS/JSON"

        api -> banco "Consulta e persiste informações" "Prisma/PostgreSQL"

        api -> fila "Publica tarefas de notificação" "BullMQ/Redis"

        api -> conteudo "Acessa arquivos digitais" "HTTPS"

        worker -> fila "Consome e agenda tarefas" "BullMQ/Redis"

        worker -> banco "Consulta empréstimos e prazos de devolução" "Prisma/PostgreSQL"

        worker -> email "Solicita envio de notificações" "SMTP"

        web -> controllers "Envia requisições" "HTTPS/JSON"

        guards -> controllers "Protege endpoints autenticados"

        controllers -> acervo "Executa"
        controllers -> emprestimos "Executa"
        controllers -> devolucoes "Executa"
        controllers -> reservas "Executa"
        controllers -> historico "Executa"

        // Aplicação -> Domínio
        acervo -> dominio "Aplica regras"
        emprestimos -> dominio "Aplica regras"
        devolucoes -> dominio "Aplica regras"
        reservas -> dominio "Aplica regras"
        historico -> dominio "Aplica regras"

        // Aplicação -> Portas de persistência
        acervo -> repos "Utiliza"
        emprestimos -> repos "Utiliza"
        devolucoes -> repos "Utiliza"
        reservas -> repos "Utiliza"
        historico -> repos "Utiliza"

        // Aplicação -> Portas de integração
        emprestimos -> filaPort "Solicita notificações"
        devolucoes -> filaPort "Solicita notificações"
        reservas -> filaPort "Solicita notificações"

        acervo -> arquivoPort "Acessa arquivos"

        // Adaptadores -> Contratos
        prisma -> repos "Implementa"
        bullmq -> filaPort "Implementa"
        http -> arquivoPort "Implementa"

        // Adaptadores -> Infraestrutura
        prisma -> banco "Lê e grava" "Prisma"

        bullmq -> fila "Publica jobs" "BullMQ"

        http -> conteudo "Obtém arquivos" "HTTPS"

        // Processador de Notificações (C3)
        consumidor -> fila "Consome tarefas" "BullMQ"
        agendador -> ucLembretes "Dispara periodicamente"
        consumidor -> ucNotificar "Executa"

        ucLembretes -> dadosPort "Busca empréstimos a vencer"
        ucLembretes -> publicarPort "Publica tarefas de lembrete"
        ucNotificar -> dadosPort "Consulta leitor e obra"
        ucNotificar -> mensagens "Monta a mensagem"
        ucNotificar -> emailPort "Envia a notificação"

        prismaLeitura -> dadosPort "Implementa"
        bullPublisher -> publicarPort "Implementa"
        smtp -> emailPort "Implementa"

        prismaLeitura -> banco "Lê dados" "Prisma"
        bullPublisher -> fila "Publica jobs" "BullMQ"
        smtp -> email "Envia e-mails" "SMTP"
    }

    views {

        systemContext biblioteca "C1_Contexto" {
            title "C1 - Contexto do Sistema de Biblioteca Digital"
            include *
            autoLayout lr
        }

        container biblioteca "C2_Containers" {
            title "C2 - Containers do Sistema de Biblioteca Digital"
            include *
            autoLayout lr
        }

        component api "C3_API_Componentes" {
            title "C3 - Componentes da API da Biblioteca"
            include *
            autoLayout lr
        }

        component worker "C3_Processador_Notificacoes" {
            title "C3 - Componentes do Processador de Notificações"
            include *
            autoLayout tb
        }

        styles {

            element "Person" {
                shape Person
                background #08427b
                color #ffffff
                fontSize 20
            }

            element "Software System" {
                shape RoundedBox
                background #1168bd
                color #ffffff
            }

            // Sistemas externos
            element "External" {
                shape RoundedBox
                background #737373
                color #ffffff
            }

            element "Files" {
                shape Folder
                background #64748b
                color #ffffff
            }

            element "Container" {
                shape RoundedBox
                background #438dd5
                color #ffffff
            }

            element "Frontend" {
                shape WebBrowser
                background #2563eb
                color #ffffff
            }

            element "Backend" {
                shape Hexagon
                background #1168bd
                color #ffffff
            }

            element "Worker" {
                shape RoundedBox
                background #7c3aed
                color #ffffff
            }

            element "Database" {
                shape Cylinder
                background #334155
                color #ffffff
            }

            element "Queue" {
                shape Pipe
                background #b45309
                color #ffffff
            }

            element "Component" {
                shape RoundedBox
                background #438dd5
                color #ffffff
            }

            element "Entrada" {
                background #1d4ed8
                color #ffffff
            }

            element "Aplicacao" {
                background #0284c7
                color #ffffff
            }

            element "Dominio" {
                background #0f766e
                color #ffffff
            }

            element "Porta" {
                shape Hexagon
                background #7c3aed
                color #ffffff
            }

            element "Adaptador" {
                background #475569
                color #ffffff
            }

            relationship "Relationship" {
                color #64748b
                thickness 2
            }
        }
    }
}
