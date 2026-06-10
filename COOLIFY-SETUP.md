# 🚀 Guia Coolify - Passo a Passo

Instruções detalhadas para usar este projeto com Coolify.

## 📋 Pré-requisitos

- ✅ Coolify instalado e rodando
- ✅ Repositório Git no GitHub/GitLab/Gitea
- ✅ Acesso SSH ao servidor Coolify (opcional)

## 🔧 Passo 1: Preparar Repositório

### 1.1 Fazer Commit
```bash
cd /Users/igorrabelo/Documents/GIT/protheus_docker

# Verificar status
git status

# Adicionar tudo
git add .

# Commit
git commit -m "openSUSE Leap 15.4 Docker com suporte a Coolify"

# Push
git push origin main
```

### 1.2 Verificar Arquivo Correto
Certifique-se que está usando **`docker-compose.prod.yml`**:
```bash
ls -la docker-compose.prod.yml
```

## 🎯 Passo 2: Criar Aplicação no Coolify

### 2.1 Acessar Coolify
1. Abra seu Coolify no navegador
2. Faça login
3. Vá para **Applications** ou **Projects**

### 2.2 Criar Nova Aplicação
1. Clique em **New Application** ou **Create New**
2. Selecione **Docker Compose** como tipo

### 2.3 Configurar Repositório
```
Tipo: Docker Compose
Servidor: localhost (ou seu servidor)
Git Provider: GitHub/GitLab/Gitea
Repositório: seu-usuario/protheus_docker
Branch: main
```

### 2.4 Configurar Build
```
Dockerfile: (deixe vazio ou selecione docker-compose.prod.yml)
Compose File: docker-compose.prod.yml  ← IMPORTANTE!
Build Context: .
```

## 🌐 Passo 3: Configurar Domínio

### 3.1 Adicionar Domínio
1. Vá para **Settings** → **General**
2. Clique em **Add Domain** ou **+ Domain**
3. Digite seu domínio:
   ```
   seu-dominio.com
   www.seu-dominio.com
   ```

### 3.2 Configurar DNS
Aponte seu domínio para o IP do servidor Coolify:
```
seu-dominio.com → IP_COOLIFY
```

### 3.3 Certificado HTTPS
- Coolify oferecerá Let's Encrypt automaticamente
- Certifique está em **On** em Settings
- Renovação automática a cada 90 dias

## 🔐 Passo 4: Variáveis de Ambiente

### 4.1 Adicionar Variáveis
No Coolify, vá para **Environment**:

```
TZ=America/Sao_Paulo
NODE_ENV=production
LOG_LEVEL=info
```

### 4.2 Secrets (Senhas)
```
DATABASE_PASSWORD=sua-senha-aqui
API_KEY=sua-chave-api
```

## 💾 Passo 5: Volumes (Persistência)

### 5.1 Criar Volumes
No Coolify, vá para **Volumes**:

| Container Path | Volume Name | Type |
|---|---|---|
| `/app/data` | `app-data` | Local |
| `/app/logs` | `app-logs` | Local |

### 5.2 Permissões
```bash
# SSH no servidor
ssh user@seu-servidor

# Ajustar permissões
chmod 755 /var/lib/docker/volumes/app-data/_data
chmod 755 /var/lib/docker/volumes/app-logs/_data
```

## 🚀 Passo 6: Deploy

### 6.1 Trigger Deploy
1. Clique em **Deploy** no Coolify
2. Aguarde o build (2-5 minutos)
3. Verifique status em **Logs**

### 6.2 Verificar
```bash
# No Coolify:
1. Aplicação → Status
2. Deve mostrar "Running" em verde

# No navegador:
1. https://seu-dominio.com
2. Deve carregar com certificado HTTPS
```

## 📊 Passo 7: Monitoramento

### 7.1 Ver Logs
1. No Coolify: **Logs**
2. Ou via SSH:
   ```bash
   docker logs seu-container-id -f
   ```

### 7.2 Metrics
- CPU Usage
- Memory
- Disk Space
- Network

### 7.3 Health Status
```
Health: Healthy ✅
ou
Health: Starting (aguarde 40s)
```

## 🔄 Passo 8: Auto-Deploy (Webhook)

### 8.1 Habilitar Webhook
1. No Coolify: **Settings** → **Webhooks**
2. Copie a URL do webhook

### 8.2 Configurar GitHub
1. Repository → Settings → Webhooks
2. Add webhook
3. Payload URL: `<URL do Coolify>`
4. Events: `Push events`
5. Save

### 8.3 Próximas Mudanças
```bash
# Fazer mudança
echo "# Teste" >> README.md

# Commit
git add .
git commit -m "Teste de auto-deploy"
git push origin main

# Coolify deteta e faz deploy automaticamente!
```

## 🛑 Troubleshooting

### Problema: "Deployment Failed"

**Verifiços**:
1. Certifique de estar usando `docker-compose.prod.yml`
2. Verifique logs no Coolify
3. Git tem as mudanças? `git log`

**Solução**:
```bash
# Reset local
git status
git fetch origin
git reset --hard origin/main

# ou trigger manual no Coolify
```

### Problema: "Container reiniciando"

✅ **Resolvido!** O novo `start.sh` mantém o container rodando permanentemente.

Se ainda reiniciar:
1. Ver logs: `docker logs seu-container-id`
2. Procure por erros
3. Restart no Coolify

### Problema: "Não consigo ver logs"

Veja [LOGS.md](./LOGS.md) para instruções detalhadas.

```bash
# Rápido
docker logs seu-container-id -f --tail 100
```

### Problema: "Domínio não resolve"

**Verificações**:
1. DNS aponta para Coolify? `nslookup seu-dominio.com`
2. Firewall permite 443? `curl -I https://seu-dominio.com`
3. Certificado gerado? Check em Coolify → Domínio

## 🔐 Segurança

### Boas Práticas
- ✅ Use Secrets para senhas (não em .env)
- ✅ Atualize Coolify regularmente
- ✅ Monitore logs regularmente
- ✅ Faça backups dos volumes
- ✅ Use SSH keys, não senhas

### Backup
```bash
# SSH no servidor
docker volume ls | grep seu-app

# Backup manual
docker run --rm -v app-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/app-data.tar.gz -C /data .
```

## 📈 Scaling (Avançado)

### Replicar Container
Edite `docker-compose.prod.yml`:
```yaml
deploy:
  replicas: 2  # Executar 2 instâncias
```

Coolify fará load balance automático.

## 🆚 Versões

### Qual Compose Usar?

| Arquivo | Cenário |
|---------|---------|
| **docker-compose.prod.yml** | ✅ Coolify |
| docker-compose.nginx.yml | Local HTTPS |
| docker-compose.yml | Dev rápido |
| docker-compose.dev.yml | Dev + DB |

## 📞 Suporte

### Se Algo Não Funcionar

1. **Logs**: Veja [LOGS.md](./LOGS.md)
2. **Coolify**: [coolify.io/docs](https://docs.coolify.io)
3. **Docker**: [docs.docker.com](https://docs.docker.com)

### SSH no Servidor

```bash
# Listar containers
docker ps

# Ver logs
docker logs seu-container-id

# Entrar no container
docker exec -it seu-container-id /bin/bash

# Status de saúde
docker inspect seu-container-id | grep -A10 "Health"
```

## ✅ Checklist Final

- [ ] Repositório tem todos os arquivos
- [ ] `git push origin main` feito
- [ ] `docker-compose.prod.yml` selecionado no Coolify
- [ ] Domínio configurado
- [ ] DNS aponta para Coolify
- [ ] Variáveis de ambiente definidas
- [ ] Deploy sem erros
- [ ] Aplicação acessível em https://seu-dominio.com
- [ ] Logs visíveis em Coolify
- [ ] Webhook configurado (opcional)
- [ ] Health check OK

## 🎉 Sucesso!

Se tudo deu certo:
- ✅ Aplicação rodando
- ✅ HTTPS ativado
- ✅ Logs disponíveis
- ✅ Auto-deploy configurado
- ✅ Domínio acessível

**Parabéns! 🎊 Seu deploy no Coolify está completo!**

---

**Última atualização**: 2026-06-10  
**Versão**: 1.0.0
