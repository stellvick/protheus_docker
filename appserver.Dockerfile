# =============================================================================
# AppServer — Protheus 12.1.2510
# =============================================================================
# Imagem derivada da oficial, por um motivo só: instalar o dmidecode falso que
# estabiliza a identidade de hardware vista pela licença (ver resources/dmidecode).
#
# O que NÃO é copiado aqui, de propósito:
#   - appserver.ini  -> gerado em runtime pelo serviço seed-config (o specialkey
#                       não pode virar constante no Git)
#   - tttm120.rpo, sxsbra.txt, sx2.unq, *.xnu, hlp*.txt
#                    -> 1,2 GB em artefatos licenciados; o GitHub recusa acima
#                       de 100 MB por arquivo e o LFS gratuito dá 1 GB.
#                       Ficam na pasta do host, montados por bind.
#
# A tag é FIXADA. `latest` anda entre as linhas 12.1.XXXX / 24.x e muda
# silenciosamente o que o RPO precisa casar.
# =============================================================================
FROM totvsengpro/appserver-dev:24.3.1.1

USER root

COPY resources/dmidecode /usr/sbin/dmidecode
RUN chmod +x /usr/sbin/dmidecode && ln -sf /usr/sbin/dmidecode /usr/bin/dmidecode

# Diretórios que o bind mount do host preenche (o Docker os cria se faltarem,
# mas deixá-los explícitos torna o contrato visível na imagem).
RUN mkdir -p /opt/totvs/protheus/apo \
             /opt/totvs/protheus/protheus_data/system \
             /opt/totvs/protheus/protheus_data/systemload

EXPOSE 1234 8080 8081
