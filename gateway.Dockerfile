# =============================================================================
# Gateway — da TLS ao REST
# =============================================================================
# O REST do Protheus escuta na 8081, separado do WebApp (8080), e as duas portas
# saem do MESMO container do AppServer.
#
# O Coolify roteia dominio por SERVICO, e descarta a porta que se escreve no
# valor do dominio — ele usa o `ports_exposes` do recurso. Como as duas portas
# moram no mesmo servico, nao ha como o proxy do Coolify alcancar uma sem a
# outra. Comprovado: um PATCH com "https://host:8081" e gravado como
# "https://host", sem porta.
#
# A saida e dar ao REST um servico proprio. Este Caddy escuta na 8080 — a mesma
# porta que o Coolify usa para rotear — e entrega tudo ao appserver:8081. Assim
# o dominio protheus-api.stellvick.fun chega aqui, o proxy do Coolify termina o
# TLS, e o REST ganha certificado sem que o caminho do WebApp seja tocado.
#
# Por que imagem derivada e nao bind mount do Caddyfile: num deploy Git do
# Coolify o checkout e efemero, e bind de arquivo vindo do repositorio nao e
# confiavel. A imagem carrega a config.
# =============================================================================
FROM caddy:2-alpine

COPY resources/Caddyfile /etc/caddy/Caddyfile

EXPOSE 80 8080
