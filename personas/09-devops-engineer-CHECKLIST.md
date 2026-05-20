# Checklist Técnico — Persona 9: DevOps Engineer

## Antes do Estágio 3
- [ ] Garantir que o devcontainer estável para todos
- [ ] Preparar docker-compose para PostgreSQL e ferramentas auxiliares
- [ ] Escrever ADR de estratégia de deploy (ADR 005)
- [ ] Participar do design de infraestrutura (Terraform draft)

## Durante o Estágio 3 (Implementação)
- [ ] Manter GitHub Actions para build, lint e testes
- [ ] Publicar imagem Docker
- [ ] Manter Terraform descritivo e válido (`terraform plan` sem erro)
- [ ] Garantir que `docker compose up -d` sobe aplicação + banco em menos de 60s
- [ ] Pipeline do `main` roda lint + test + build de imagem
- [ ] Logs estruturados (JSON) e endpoint `/actuator/health` funcionando

## Durante o Estágio 4 (Evolução)
- [ ] Validar qualquer alteração do Agent no pipeline ou infraestrutura
- [ ] Garantir que o pipeline continua verde após o Agent

## Se travar
- [ ] Docker compose não sobe? Checklist: Docker Desktop rodando? Portas 5432/8080/3000 livres? `docker compose down && docker compose up -d`? `docker compose logs`?
- [ ] CI falhando? Verificar logs do GitHub Actions, versão do Java, cache.
- [ ] Terraform plan falhando? Rodou `terraform init`? Provider compatível? Variáveis obrigatórias?
- [ ] Não conhece GitHub Actions? Copie e adapte `.github/workflows/build.yml`

---

# Exemplos de Prompts para Copilot Chat

1. **Workflow CI/CD**
   > "Crie um workflow GitHub Actions .github/workflows/ci.yml que: rode em push, configure Java 21 com cache do Maven, rode testes e construa uma imagem Docker."

2. **Otimização de Dockerfile**
   > "Planeje a otimização do Dockerfile do backend: cache de dependências do Maven, imagem final menor e health check."

3. **Diagnóstico de lentidão**
   > "`docker compose up` demora 3 minutos para subir. Analise os Dockerfiles e o docker-compose.yml e proponha 3 otimizações."

---

> Dica: Use o cheat-sheet `copilot-3-modes.md` para alternar entre modos de uso do Copilot conforme a tarefa.
