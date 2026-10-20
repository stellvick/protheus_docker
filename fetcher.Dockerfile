# =============================================================================
# Fetcher — baixa os artefatos licenciados no boot
# =============================================================================
# Imagem mínima: só um bash, um curl e um unzip. O trabalho de verdade está em
# resources/fetch-artifacts.sh, que é versionado e legível — e roda tanto aqui
# quanto à mão no host.
#
# Alpine porque a imagem inteira fica em dezenas de MB e o único tráfego é o
# download em si.
# =============================================================================
FROM alpine:3.20

RUN apk add --no-cache bash curl unzip ca-certificates

COPY resources/fetch-artifacts.sh /usr/local/bin/fetch-artifacts.sh
RUN chmod +x /usr/local/bin/fetch-artifacts.sh

# DATA_DIR e FETCH_ARTIFACTS vêm do docker-compose.
ENTRYPOINT ["/usr/local/bin/fetch-artifacts.sh"]
