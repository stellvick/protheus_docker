#!/bin/sh
# Criar o arquivo vazio (ou esvaziar se já existir) e dar permissão
true > /opt/totvs/appserver/language.ini
chmod 666 /opt/totvs/appserver/language.ini

cd /opt/totvs/appserver
exec ./appsrvlinux "$@"
