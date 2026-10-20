# =============================================================================
# PostgreSQL 15.2 — Protheus 12.1.2510
# =============================================================================
# A tag 12.1.2510_bra é a RELEASE do Protheus, e casa exatamente com o RPO
# (25-10-06-..._12_1_2510_TTTM120.RPO) e com o dicionário da mesma data.
#
# O cluster já vem INICIALIZADO dentro da imagem (PGDATA em
# /var/lib/postgresql/data), com os bancos postgres, protheus, template0 e
# template1 — e o `protheus` já criado em WIN1252. Por isso NÃO existem
# variáveis POSTGRES_* aqui: o docker-entrypoint encontra dados e pula o
# initdb, então elas seriam inertes.
#
# Superusuário: postgres / postgres. Confirmado lendo o verificador
# SCRAM-SHA-256 em global/1260 (pg_authid) dentro da própria imagem.
# =============================================================================
FROM totvsengpro/postgres-dev:12.1.2510_bra

USER root

COPY resources/dmidecode /usr/sbin/dmidecode
RUN chmod +x /usr/sbin/dmidecode && ln -sf /usr/sbin/dmidecode /usr/bin/dmidecode

EXPOSE 5432
