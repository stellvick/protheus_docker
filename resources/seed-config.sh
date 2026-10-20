#!/usr/bin/env bash
# =============================================================================
# seed-config.sh — gera os arquivos de configuração do Protheus
# =============================================================================
# Roda no container `seed-config`, na imagem do DbAccess (é ela que traz o
# dbaccesscfg).
#
# Por que este script é um ARQUIVO e não um script inline no docker-compose:
# o Compose interpola $VAR e ${VAR} no arquivo inteiro, inclusive dentro de
# `command:`. Num script inline, cada variável de shell teria de ser escrita
# com cifrão dobrado ($${VAR}) — e uma dobra esquecida grava um valor VAZIO no
# appserver.ini, em silêncio. Como arquivo, o bash é bash e nada mais.
#
# Autoridade: o appserver.ini aponta as chaves de acesso ao banco para o
# serviço do DbAccess, e o dbaccess.ini é GERADO pelo dbaccesscfg — nunca
# escrito à mão, que é a recomendação do fabricante.
# =============================================================================
set -euo pipefail

: "${PROTHEUS_SPECIALKEY:?defina a variável PROTHEUS_SPECIALKEY nas variáveis do recurso}"

cd /seed

# --- appserver.ini -----------------------------------------------------------
# REGERADO a cada execução, de propósito: o repositório é a fonte da verdade.
# Um arquivo preservado esconde mudança de configuração — foi exatamente assim
# que a chave app_environment ficou na seção errada sem ninguém perceber.
echo "==> [seed-config] escrevendo appserver.ini"
cat > appserver.ini <<INI
; GERADO por resources/seed-config.sh — NÃO EDITE À MÃO; a edição se perde.
; Conformidade com a release 12.1.2510 (TDN DFRM1-37254):
;   [DRIVERS] MultiProtocolPort=1        [GENERAL] app_environment=<ambiente>
[environment]
rpodb=top
rpoversion=120
rpolanguage=multi
sourcepath=/opt/totvs/protheus/apo
rootpath=/opt/totvs/protheus/protheus_data
RPOCustom=/opt/totvs/protheus/apo/custom.rpo
startpath=/system
dbdatabase=POSTGRES
dbalias=protheus
dbserver=dbaccess-postgres
dbport=7890
topmemomega=10
specialkey=${PROTHEUS_SPECIALKEY}

[general]
buildkillusers=1
consolelog=1
consolefile=/opt/totvs/appserver/console.log
maxstringsize=10
; Obrigatorio a partir da release 12.1.2510 (TDN DFRM1-37254): nome do ambiente
; habilitado no REST. O TDN exige esta chave na secao [GENERAL] — nao em
; [environment]. Sem ela o servico pode recusar acesso com a mensagem
; "Porta Multiprotocolo - Nao foi possivel identificar a configuracao do ambiente".
app_environment=environment

[drivers]
active=tcp
; Porta Multiprotocolo: obrigatoria a partir da release 12.1.2510 (TDN DFRM1-37254).
MultiProtocolPort=1
; Comunicacao segura DESLIGADA — e isso e deliberado, nao um esquecimento.
;
; Com MultiProtocolPortSecure=1 o AppServer apresenta, na porta 1234, o
; certificado padrao que acompanha o produto: valido SOMENTE para localhost
; (SAN: DNS:localhost, IP:127.0.0.1). Verificado por sondagem TLS — a 1234
; responde com CN="TOTVS certificate CA - localhost".
;
; Acessando o WebApp por um nome real, o navegador recusa o certificado, a
; sessao nao abre e o WebApp reporta "server unknown status" ao selecionar o
; programa. O TDN descreve exatamente este cenario.
;
; Para religar a comunicacao segura e preciso um certificado que contemple o
; nome usado (TDN: "Porta Multiprotocolo - Geracao de Certificado") e apontar
; [MPP] SSL_Certificate / SSL_Key para ele. Enquanto isso, o trafego da MPP
; vai em claro — aceitavel num ambiente de desenvolvimento, que nao e
; homologado para producao de qualquer forma.
MultiProtocolPortSecure=0

[tcp]
type=tcpip
port=1234

[webapp]
enable=1
EnvServer=environment
port=8080

[lockserver]
enable=0
server=NOCONFIG
port=1234

[licenseclient]
server=license
port=5555

[webapp/webapp]
mpp=

[HTTPV11]
ENABLE=1
SOCKETS=HTTPREST

[ONSTART]
JOBS=HTTPJOB
REFRESHRATE=30

[HTTPURI]
URL=/REST
INSTANCES=1,2
PREPAREIN=ALL

[HTTPREST]
SECURITY=1
PORT=8081
URIS=HTTPURI

[HTTPJOB]
MAIN=HTTP_START
ENVIRONMENT=environment
INI
chmod 0640 appserver.ini

# --- language.ini ------------------------------------------------------------
# Regerado pelo mesmo motivo do appserver.ini.
printf '[languageenvironment]\ncurrentlanguage=pt-br\n' > language.ini
chmod 0640 language.ini

# --- dbaccess.ini ------------------------------------------------------------
# -a protheus  == dbalias no appserver.ini == nome do alias
# -d postgres  == dbdatabase no appserver.ini == TIPO de banco
# SERVERNAME   == nome do serviço do Postgres na rede do recurso, não localhost
echo "==> [seed-config] gerando dbaccess.ini"
/opt/totvs/dbaccess/tools/dbaccesscfg \
  -u postgres \
  -p postgres \
  -a protheus \
  -d postgres \
  -c '/usr/lib64/libodbc.so' \
  -o 'ConnectionMode=2;ConnectionString=DRIVER!{PostgreSQL}@SERVERNAME!postgres-iniciado@PORT!5432@DATABASE!protheus@USERNAME!postgres@PASSWORD!postgres' \
  -g 'LicenseServer=license;LicensePort=5555'

# A saída usa '!' e '@' como separadores e precisa virar '=' e ';'.
sed -e 's/!/=/g' -e 's/@/;/g' dbaccess.ini > dbaccess2.ini
mv -f dbaccess2.ini dbaccess.ini
chmod 0640 dbaccess.ini

echo "==> [seed-config] pronto"
