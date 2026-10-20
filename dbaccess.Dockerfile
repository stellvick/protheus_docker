# =============================================================================
# DbAccess (ponte ODBC) — Protheus 12.1.2510
# =============================================================================
# Mesmo motivo da imagem do AppServer: o dmidecode falso.
# O dbaccess.ini é gerado em runtime pelo serviço seed-config, com o
# dbaccesscfg que vive nesta própria imagem.
# =============================================================================
FROM totvsengpro/dbaccess-postgres-dev:24.1.1.0

USER root

COPY resources/dmidecode /usr/sbin/dmidecode
RUN chmod +x /usr/sbin/dmidecode && ln -sf /usr/sbin/dmidecode /usr/bin/dmidecode

EXPOSE 7890
