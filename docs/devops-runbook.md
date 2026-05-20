# Runbook DevOps — SIFAP 2.0 (Hackathon Team 02 VD)

> Persona 9 · DevOps Engineer — referência rápida para resolver problemas durante o hackathon.

---

## Docker Compose

### `docker compose up` não sobe

```bash
# 1. Verificar se o Docker está rodando
docker info

# 2. Verificar portas ocupadas
ss -tlnp | grep -E '5432|8080|3001'

# 3. Limpar containers antigos e subir novamente
docker compose down --remove-orphans
docker compose up -d

# 4. Ver logs de um serviço específico
docker compose logs backend
docker compose logs postgres
docker compose logs frontend
```

### Backend não passa no healthcheck

```bash
# Verificar se o endpoint /actuator/health responde
curl -s http://localhost:8080/actuator/health | python3 -m json.tool

# Ver logs do backend em tempo real
docker compose logs -f backend
```

### PostgreSQL não aceita conexões

```bash
# Verificar se o postgres está saudável
docker compose ps postgres

# Conectar diretamente ao banco para testar
docker exec -it sifap-postgres psql -U sifap -d sifap -c "SELECT 1;"
```

---

## GitHub Actions

### CI falhando — como diagnosticar

1. Abrir a aba **Actions** no GitHub e clicar no job que falhou.
2. Expandir o step com erro e ler a mensagem.
3. Erros mais comuns:

| Erro | Causa | Solução |
|------|-------|---------|
| `./mvnw: Permission denied` | mvnw sem execute | `git update-index --chmod=+x backend/mvnw` |
| `Cache miss pnpm` | lock file mudou | Normal — o pnpm reinstala automaticamente |
| `terraform fmt -check failed` | Arquivo .tf com formatação errada | `terraform fmt -recursive infra/` |
| `Gitleaks: secret found` | Secret acidentalmente commitado | Remover do código, revogar credencial, usar `git filter-repo` |
| `Trivy: CRITICAL vulnerability` | Dependência com CVE crítica | Atualizar versão da dependência ou adicionar exceção justificada |

### Workflow não dispara

- Verificar se o branch name bate com os filtros em `on.push.branches`.
- Branches válidos: `main`, `develop`, `spec/**`, `impl/**`.

---

## Terraform

### `terraform init` falha

```bash
cd infra

# Limpar cache e reinicializar
rm -rf .terraform .terraform.lock.hcl
terraform init -backend=false

# Verificar versão instalada
terraform version
```

### `terraform validate` mostra erro

```bash
# Formatar arquivos antes de validar
terraform fmt -recursive

# Validar sem backend
terraform init -backend=false
terraform validate
```

### Erros comuns

| Erro | Solução |
|------|---------|
| `Provider version conflict` | Atualizar `required_providers` no `main.tf` |
| `Variable not defined` | Adicionar variável em `variables.tf` ou passar via `-var` |
| `Missing required argument` | Verificar se todos os campos obrigatórios do módulo foram passados |

---

## Checklist rápido pré-demo

- [ ] `docker compose up -d` sobe em menos de 60s
- [ ] `curl http://localhost:8080/actuator/health` retorna `{"status":"UP"}`
- [ ] `curl http://localhost:3001` carrega o frontend
- [ ] GitHub Actions pipeline `main` está verde
- [ ] `terraform fmt -check -recursive infra/` passa sem erro
- [ ] Nenhum `.env` com secrets reais commitado no repositório
