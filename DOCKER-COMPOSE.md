# 🐳 Docker Compose Variants

Existem 3 versões diferentes de `docker-compose.yml` para diferentes cenários:

## 1. **docker-compose.prod.yml** (Coolify + Traefik) ⭐ RECOMENDADO

**Use este arquivo para Coolify!**

```bash
docker-compose -f docker-compose.prod.yml up -d
```

**Características**:
- ✅ Otimizado para Coolify + Traefik
- ✅ Apenas porta 3000 exposta (app)
- ✅ Sem nginx (Traefik já é proxy reverso)
- ✅ Sem conflito de portas 80/443
- ✅ HTTPS gerenciado pelo Traefik

**Por que não tem nginx?**
- Traefik (do Coolify) já faz proxy reverso HTTPS
- Nginx seria redundante
- Evita conflito de portas

---

## 2. **docker-compose.nginx.yml** (Local com Nginx)

**Use este arquivo para desenvolvimento/testes locais com Nginx e HTTPS**

```bash
# Usar com Nginx (portas 80/443)
docker-compose -f docker-compose.nginx.yml up -d
```

**Características**:
- ✅ Nginx como proxy reverso HTTPS
- ✅ Portas 80/443 acessíveis
- ✅ HTTPS local
- ✅ Certificados auto-assinados
- ❌ Não use com Coolify (conflita com Traefik)

**Quando usar?**
- Testar HTTPS localmente
- Desenvolvimento sem Coolify
- Testes antes de deploy no Coolify

---

## 3. **docker-compose.yml** (Padrão)

**Versão original para desenvolvimento**

```bash
docker-compose up -d
```

**Características**:
- ✅ Setup básico
- ✅ Sem HTTPS
- ✅ Desenvolvimento rápido
- ❌ Não recomendado para produção

---

## 📊 Comparação

| Arquivo | Nginx | Portas | Uso |
|---------|-------|--------|-----|
| `docker-compose.prod.yml` | ❌ Não | 3000 | **Coolify** ⭐ |
| `docker-compose.nginx.yml` | ✅ Sim | 80, 443 | Local/Testes |
| `docker-compose.yml` | Integrado | 80, 443, 3000 | Dev |
| `docker-compose.dev.yml` | ❌ Não | 3000, 5432, 6379 | Dev + DB |

---

## 🚀 Guia Rápido

### Para Coolify
```bash
git push origin main
# No Coolify, selecione: docker-compose.prod.yml
```

### Para Testar Localmente com HTTPS
```bash
./generate-certs.sh  # Se não tiver certificados
docker-compose -f docker-compose.nginx.yml up -d
curl -k https://localhost/
```

### Para Desenvolvimento Rápido
```bash
docker-compose up -d
```

### Com PostgreSQL + Redis
```bash
docker-compose -f docker-compose.dev.yml up -d
```

---

## ⚠️ Importante

### Com Coolify
- ✅ Use `docker-compose.prod.yml`
- ❌ NÃO use `docker-compose.nginx.yml` (conflita com Traefik)
- ❌ NÃO mude portas 80/443 (Traefik usa)

### Sem Coolify
- ✅ Use `docker-compose.nginx.yml` para HTTPS
- ✅ Use `docker-compose.yml` para dev rápido
- ✅ Use `docker-compose.dev.yml` para com banco

---

## 🔧 Customizar

### Mudar porta do app (ex: 5252)
Edite `docker-compose.prod.yml`:
```yaml
ports:
  - "5252:3000"  # Expõe em 5252
```

### Usar Traefik labels (Coolify)
Adicione em `docker-compose.prod.yml`:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.app.rule=Host(\`seu-dominio.com\`)"
  - "traefik.http.services.app.loadbalancer.server.port=3000"
```

---

## 📚 Referência

| Cenário | Arquivo | Comando |
|---------|---------|---------|
| Coolify + Traefik | docker-compose.prod.yml | `docker-compose -f docker-compose.prod.yml up -d` |
| Local com HTTPS | docker-compose.nginx.yml | `docker-compose -f docker-compose.nginx.yml up -d` |
| Dev rápido | docker-compose.yml | `docker-compose up -d` |
| Dev + DB | docker-compose.dev.yml | `docker-compose -f docker-compose.dev.yml up -d` |

---

**Dúvidas?** Consulte os arquivos diretamente ou leia `COOLIFY.md`
