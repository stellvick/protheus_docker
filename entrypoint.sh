#!/bin/sh
rm -f /opt/totvs/appserver/language.ini
cd /opt/totvs/appserver
exec ./appsrvlinux "$@"
