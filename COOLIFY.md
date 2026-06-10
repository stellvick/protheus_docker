# 🚀 Guia de Integração com Coolify

Este documento descreve como usar este projeto Docker com **Coolify**.

## O que é Coolify?

Coolify é uma plataforma open-source para deploy e gerenciamento de aplicações Docker. Oferece:

- ✅ Deploy automático via Git
- ✅ Gerenciamento de SSL/TLS
- ✅ Monitoramento e logs
- ✅ Integração com domínios
- ✅ Backup automático
- ✅ Escalabilidade

[Saiba mais em coolify.io](https://coolify.io)

## 📋 Pré-requisitos

1. **Servidor com Coolify instalado**
   - Self-hosted ou cloud
   - Acesso SSH ao servidor

2. **Repositório Git**
   - GitHub, GitLab ou Gitea
   - Público ou com SSH key configurada

3. **Domínio (opcional)**
   - Para HTTPS automático via Let's Encrypt

## 🔧 Configuração no Coolify

### 1. Preparar o Repositório

```bash
# Certifique-se de que seu repositório está limpo
git status
git add .
git commit -m "Initial Docker setup for Coolify"
git push origin main
```

### 2. No Painel do Coolify

#### Passo 1: Criar Aplicação
1. Acesse seu Coolify
2. Vá para **Applications**
3. Clique em **New Application**
4. Selecione **Docker Compose**

#### Passo 2: Conectar Repositório
- **Git Provider**: Selecione GitHub/GitLab/Gitea
- **Repository**: `seu-usuario/protheus_docker`
- **Branch**: `main`
- **Root Directory**: `/` (deixar vazio se for raiz)

#### Passo 3: Configurar Build
- **Dockerfile**: `Dockerfile`
- **Compose File**: `docker-compose.yml`
- **Build Context**: `.`

```yaml
# Configuração sugerida:
Build Strategy: Docker Compose
Compose File Path: docker-compose.yml
Network: bridge
```

#### Passo 4: Variáveis de Ambiente
Adicione as mesmas variáveis do `.env`:

```
TZ=America/Sao_Paulo
NODE_ENV=production
LOG_LEVEL=info
```

#### Passo 5: Portas
Configure as portas expostas:
- **Container Port 80**: Host Port 80 (HTTP)
- **Container Port 443**: Host Port 443 (HTTPS)
- **Container Port 3000**: Host Port 3000 (App)

#### Passo 6: Volumes
Crie volumes persistentes:

| Container Path | Volume | Tipo |
|---|---|---|
| `/app/data` | `app-data` | Local |
| `/app/logs` | `app-logs` | Local |

#### Passo 7: Configurar Domínio

1. Vá para **Settings** → **General**
2. Clique em **+ Add Domain**
3. Digite seu domínio (ex: `myapp.example.com`)
4. Coolify oferecerá:
   - Certificado Let's Encrypt automático
   - Redirecionamento HTTP → HTTPS
   - Renovação automática (90 dias)

#### Passo 8: SSL/TLS

Coolify gerencia automaticamente:
- ✅ Geração de certificado
- ✅ Renovação automática
- ✅ HSTS headers
- ✅ Redirecionamento seguro

**NÃO é necessário gerar certificados manualmente!**

### 3. Deploy

#### Primeira vez
1. Clique em **Deploy**
2. Aguarde o build (5-10 minutos)
3. Verifique logs em **Logs**
4. Teste a aplicação em `https://seu-dominio.com`

#### Atualizações futuras
Coolify deploy automaticamente quando você faz push:

```bash
git push origin main
# Coolify detecta mudanças e redeploy automaticamente
```

## 📊 Monitoramento

### Logs em Tempo Real
1. Vá para **Logs**
2. Selecione o serviço
3. Veja logs em tempo real

### Métricas
- **CPU Usage**: Consumo de processador
- **Memory**: Uso de RAM
- **Disk**: Espaço em disco
- **Network**: Tráfego de rede

### Health Checks
Coolify verifica automaticamente a saúde:
- Endpoint: `http://localhost:3000/`
- Intervalo: 30 segundos
- Timeout: 10 segundos

## 🔄 Webhooks Git

### Auto-Deploy
Coolify pode fazer deploy automático em cada push:

1. Vá para **Settings** → **Webhooks**
2. Copie a URL do webhook
3. No GitHub/GitLab:
   - Repository Settings → Webhooks
   - Paste a URL do Coolify
   - Selecione "Push events"

## 🛑 Troubleshooting

### Problema: Build falha

**Verificar:**
1. Logs do build: `Logs` → `Build`
2. Dockerfile sintaxe
3. Espaço em disco no servidor
4. Permissões de arquivo

**Solução:**
```bash
# No servidor Coolify
docker system prune -a -f
```

### Problema: Aplicação não inicia

**Verificar:**
1. Health check falha
2. Variáveis de ambiente
3. Volumes montados corretamente
4. Portas disponíveis

**Solução:**
```bash
# Entrar no container
docker exec -it <container-id> /bin/bash

# Ver logs
docker logs <container-id>
```

### Problema: HTTPS não funciona

**Verificar:**
1. Domínio configurado em Coolify
2. DNS aponta para Coolify
3. Porta 443 está aberta
4. Certificado gerado (aguardar ~2 minutos)

**Solução:**
```bash
# Renew certificado manualmente
coolify certificate-renew <app-name>
```

### Problema: Volume não persiste

**Verificar:**
1. Volume configurado em docker-compose.yml
2. Montagem correta
3. Permissões de arquivo

**Solução:**
1. Vá para **Settings** → **Volumes**
2. Verifique se o volume está listado
3. Clique em **Verify** para testar

## 🔐 Segurança

### Boas Práticas

1. **Repositório Privado**: Use repositório privado no Git
2. **SSH Keys**: Configure SSH keys em Coolify
3. **Secrets**: Use Coolify Secrets para senhas:
   ```
   Database password: use ${POSTGRES_PASSWORD}
   API keys: use ${API_KEY}
   ```

4. **Firewall**: Restrinja acesso às portas
5. **Updates**: Mantenha imagem base atualizada

### Secrets no Coolify

1. Vá para **Settings** → **Secrets**
2. Crie nova secret: `POSTGRES_PASSWORD`
3. Valor: sua senha (criptografada)
4. Referencie em variáveis: `${POSTGRES_PASSWORD}`

## 📈 Escalar Aplicação

### Aumentar Recursos

No `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '4'      # Aumentar de 2
      memory: 4G     # Aumentar de 2G
```

Push e Coolify redeploy automaticamente.

### Replicar Serviço

```yaml
deploy:
  replicas: 2        # Executar 2 instâncias
```

Load balancer automático via nginx.

## 📚 Referências

- [Coolify Docs](https://docs.coolify.io)
- [Docker Compose Docs](https://docs.docker.com/compose)
- [Let's Encrypt](https://letsencrypt.org)

## 🆘 Suporte

### Problemas no Coolify
- [Coolify Discord](https://discord.gg/coolify)
- [Issues GitHub](https://github.com/coollabsio/coolify/issues)

### Problemas com Docker
- [Docker Community](https://www.docker.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/docker)

## ✅ Checklist de Deployment

- [ ] Repositório Git preparado
- [ ] Coolify instalado e acessível
- [ ] Domínio DNS configurado
- [ ] Firewall permite portas 80 e 443
- [ ] Variáveis de ambiente definidas
- [ ] Volumes criados
- [ ] Build sem erros
- [ ] Health checks passando
- [ ] HTTPS funciona
- [ ] Auto-deploy configurado

---

**Versão**: 1.0.0  
**Atualizado**: 2024
