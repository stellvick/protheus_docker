#!/usr/bin/env bash
# =============================================================================
# 99-verify.sh — verificacao pos-deploy
# =============================================================================
# Le a estado real dos containers e testa cada caminho da topologia.
# Nao altera nada.
#
# Uso:  bash 99-verify.sh [dominio-webapp] [dominio-rest]
# =============================================================================
set -uo pipefail

WEBAPP_URL="${1:-}"
REST_URL="${2:-}"
fail=0

find_c() {
  docker ps -q --filter "label=com.docker.compose.service=$1" | head -1
}

echo "==> containers"
for s in license postgres-iniciado dbaccess-postgres appserver; do
  cid="$(find_c "$s")"
  if [ -z "$cid" ]; then
    printf '    FALTA  %-20s container nao encontrado\n' "$s"; fail=1; continue
  fi
  printf '    %-6s %-20s %s\n' "$(docker inspect -f '{{.State.Status}}' "$cid")" "$s" "$(docker inspect -f '{{.State.Health.Status}}' "$cid" 2>/dev/null)"
done

echo
echo "==> banco"
pg="$(find_c postgres-iniciado)"
if [ -n "$pg" ]; then
  docker exec -i "$pg" psql -U postgres -d postgres -tAc \
    "SELECT datname||' ('||pg_encoding_to_char(encoding)||')' FROM pg_database WHERE datname='protheus'" \
    | sed 's/^/    /' || fail=1
  [ -n "$(docker exec -i "$pg" psql -U postgres -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='protheus'")" ] \
    || { echo "    FALTA  banco 'protheus' (rode 03-create-database.sh)"; fail=1; }
fi

echo
echo "==> DbAccess: alias 'protheus' via isql"
db="$(find_c dbaccess-postgres)"
if [ -n "$db" ]; then
  if docker exec -i "$db" /bin/bash -lc 'echo "select 1;" | isql protheus 2>&1 | grep -qE "1 rows|rows affected|SQL>"'; then
    echo "    ok    isql conectou pelo alias 'protheus'"
  else
    echo "    FALHA isql nao conectou"
    echo "          confira SERVERNAME em dbaccess.ini (deve ser 'postgres-iniciado')"
    echo "          e se o usuario/senha do banco batem"
    fail=1
  fi
fi

echo
echo "==> AppServer: porta 1234 (TDS/SmartClient)"
ap="$(find_c appserver)"
if [ -n "$ap" ]; then
  if docker exec -i "$ap" /bin/bash -c 'timeout 2 bash -c "</dev/tcp/127.0.0.1/1234"' 2>/dev/null; then
    echo "    ok    1234 escutando"
  else
    echo "    FALHA 1234 nao escuta"
    fail=1
  fi
  echo "    --- ultimas linhas do console.log ---"
  docker exec -i "$ap" /bin/bash -c 'tail -n 25 /opt/totvs/appserver/console.log 2>/dev/null || echo "(sem console.log)"' | sed 's/^/    /'
fi

if [ -n "$WEBAPP_URL" ]; then
  echo
  echo "==> WebApp: $WEBAPP_URL"
  code="$(curl -s -o /dev/null -w '%{http_code}' -k -m 20 "$WEBAPP_URL" || echo 000)"
  echo "    HTTP $code"
  [ "$code" = "000" ] && fail=1
fi

if [ -n "$REST_URL" ]; then
  echo
  echo "==> REST: $REST_URL"
  # SECURITY=1 no appserver.ini: sem credenciais o esperado e 401, nao 200.
  code="$(curl -s -o /dev/null -w '%{http_code}' -k -m 20 "$REST_URL" || echo 000)"
  echo "    HTTP $code  (401/403 = endpoint vivo e exigindo autenticacao)"
  case "$code" in 401|403|200) ;; *) fail=1 ;; esac
fi

echo
if [ "$fail" -eq 0 ]; then echo "RESULTADO: tudo verificado"; else echo "RESULTADO: ha pendencias acima"; fi
exit "$fail"
