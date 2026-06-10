# 📋 Ver Logs no Coolify

Guia para acessar os logs da sua aplicação no Coolify.

## 🔍 No Painel Coolify

### 1. Acessar Aplicação
- Vá para **Applications**
- Selecione sua aplicação
- Clique em **Logs**

### 2. Ver Logs em Tempo Real
- Você verá a saída do container
- Logs são atualizados automaticamente
- Scroll down para ver os mais recentes

## 🖥️ Via Terminal SSH

Se não conseguir ver logs no Coolify, conecte via SSH:

```bash
# SSH no servidor Coolify
ssh user@seu-servidor

# Listar containers rodando
docker ps | grep seu-app-id

# Ver logs do container
docker logs seu-container-id -f

# Ver apenas últimas 100 linhas
docker logs seu-container-id -n 100

# Ver com timestamps
docker logs seu-container-id --timestamps
```

## 📊 Formato de Logs

Agora o container envia logs assim:

```
[2026-06-10 13:40:15] Starting openSUSE Leap 15.4 container...
[2026-Jun-10 13:40:16] System Information:
[2026-Jun-10 13:40:16]   Hostname: myapp
[2026-Jun-10 13:40:16]   Timezone: America/Sao_Paulo
[2026-Jun-10 13:40:16] Starting HTTP server on port 3000...
[2026-Jun-10 13:40:16] Serving HTTP on 0.0.0.0 port 3000 (http://0.0.0.0:3000/)
```

## 🛠️ Troubleshooting

### Problema: "Sem logs visíveis"

**Solução 1: Restartar aplicação**
1. No Coolify: Aplicação → Restart
2. Aguarde 30 segundos
3. Abra Logs

**Solução 2: Verificar status**
```bash
# Container está rodando?
docker ps | grep seu-app

# Se não aparecer, veja os parados:
docker ps -a | grep seu-app

# Ver último erro:
docker logs seu-container-id -n 50
```

**Solução 3: Verificar espaço em disco**
```bash
docker system df
docker system prune
```

### Problema: "Container fica reiniciando"

Isso deve estar resolvido agora pois o `start.sh` roda um servidor HTTP permanente.

Se ainda reiniciar:
```bash
docker logs seu-container-id

# Procure por erros como:
# - "command not found"
# - "port already in use"
# - "permission denied"
```

## 📝 Arquivo de Log Local

Os logs também são salvos em:
```
/app/logs/server.log
```

Para acessar:
1. Via SSH no servidor
2. Dentro do container: `cat /app/logs/server.log`

## 🔧 Aumentar Verbosidade (Opcional)

No `.env` adicione:
```env
DEBUG=true
LOG_LEVEL=debug
```

Depois restart a aplicação.

## 📡 Exportar Logs

### Via Coolify
- Aplicação → Logs → Ícone de download
- Salva em arquivo local

### Via SSH
```bash
# Salvar logs
docker logs seu-container-id > logs.txt

# Salvar com data
docker logs seu-container-id > logs-$(date +%Y%m%d).txt

# Com tail (últimas 500 linhas)
docker logs seu-container-id | tail -500 > recent-logs.txt
```

## 📊 Monitoramento Contínuo

### Ver logs em tempo real
```bash
docker logs seu-container-id -f --timestamps
```

### Gravar em arquivo enquanto segue
```bash
docker logs seu-container-id -f | tee -a logs-$(date +%Y%m%d).txt
```

## ✅ Health Check

O container agora tem um health check que:
- Verifica a cada 30s
- Timeout de 10s
- Requer 3 falhas para marcar como unhealthy

Para ver status:
```bash
docker inspect seu-container-id | grep -A5 "Health"
```

Deve mostrar:
```
"Health": {
    "Status": "healthy",
    "FailingStreak": 0,
    "Log": [...]
}
```

## 🎯 Resumo Rápido

| Ação | Comando |
|------|---------|
| Ver logs ao vivo | `docker logs seu-container-id -f` |
| Últimas 100 linhas | `docker logs seu-container-id -n 100` |
| Com timestamps | `docker logs seu-container-id -tf` |
| Salvar em arquivo | `docker logs seu-container-id > file.txt` |
| Listar containers | `docker ps` |
| Status da app | `docker inspect seu-container-id` |

## 📞 Dúvidas?

- [Docker Logs Documentation](https://docs.docker.com/engine/reference/commandline/logs/)
- [Coolify Logs Guide](https://docs.coolify.io)
- Ver `README.md` para overview

---

**Criado**: 2026-06-10  
**Status**: ✅ Pronto
