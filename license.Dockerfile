# =============================================================================
# License Server — Protheus 12.1.2510
# =============================================================================
# Esta é a imagem onde o dmidecode falso mais importa: é o License Server que
# lê os identificadores de hardware para validar a licença.
#
# A imagem oficial empacota o AppServer rodando como License Server:
# appserver.ini com [LICENSESERVER] Port=5555.
#
# NÃO usamos o TOTVSLICENSE_3.7.1_LINUX.tar.gz do Portal do Cliente: ele é um
# instalador Java (installer.jar + script `install`) que instala em
# /totvs/totvslicensevirtual — caminho diferente, e exigiria um JDK no build
# para reproduzir um layout que não dá para verificar sem executá-lo.
# =============================================================================
FROM totvsengpro/license-dev:3.7.0

USER root

COPY resources/dmidecode /usr/sbin/dmidecode
RUN chmod +x /usr/sbin/dmidecode && ln -sf /usr/sbin/dmidecode /usr/bin/dmidecode

EXPOSE 5555 2234 8020
