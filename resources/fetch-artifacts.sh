#!/usr/bin/env bash
# =============================================================================
# fetch-artifacts.sh — baixa os artefatos licenciados do Google Drive
# =============================================================================
# Roda em DOIS lugares, com o mesmo código:
#
#   - no container `fetch-artifacts`, no boot      (DATA_DIR=/seed)
#   - à mão, no host:  DATA_DIR=/srv/protheus bash resources/fetch-artifacts.sh
#
# Os arquivos são baixados para os nomes que o Protheus espera — o Drive
# entrega nomes longos em maiúsculas, o container quer caminhos fixos.
#
# IDEMPOTENTE. Só baixa o que falta ou o que está com tamanho errado. Um
# segundo boot não gasta um byte de download.
#
# Pegadinha do Google: acima de ~25 MB ele devolve uma página de aviso
# ("Virus scan warning") em vez do arquivo. É preciso repetir a requisição com
# o token de confirmação (uuid) que vem dentro dessa página.
# =============================================================================
set -euo pipefail

DATA_DIR="${DATA_DIR:-/srv/protheus}"
FETCH_ARTIFACTS="${FETCH_ARTIFACTS:-1}"

# IDs na pasta pública do Drive
FID_RPO="1YUEM8sJDRGI0SK-uirJQhMU8_R9QZyRA"
FID_SXSBRA="1QYWO9GWydbIkTXgRPkB60NoXu5acp6tU"
FID_DICIONARIOS="1xZsQLUY3q_5yh7TYIn7eoyO51f28ppdO"
FID_MENUS="1yJA5q6L3lIG7B12zMNsbsEL3BQCKhqGv"
FID_HELPS="1MihUsvtcIgo4sJjTIIhr67Ton5Xins4C"

# Tamanhos esperados — integridade disponível sem rebaixar 1,2 GB
SIZE_RPO=606222775
SIZE_SXSBRA=592018106
SIZE_SX2UNQ=80912

UA="Mozilla/5.0 (compatible; protheus-fetcher/1.0)"
WORK="$(mktemp -d)"; COOKIE="$WORK/cookies.txt"
trap 'rm -rf "$WORK"' EXIT

log()  { printf '    %s\n' "$*"; }
size() { wc -c < "$1" 2>/dev/null | tr -d ' '; }

# 0 = precisa baixar (ausente ou tamanho diferente); 1 = já está bom
precisa() {
  local f="$1" esperado="$2"
  [ -s "$f" ] || return 0
  [ "$(size "$f")" = "$esperado" ] && return 1
  log "tamanho divergente em $(basename "$f") — baixando de novo"
  return 0
}

gdrive() {  # $1 = id, $2 = destino
  local id="$1" out="$2" uuid
  curl -fsSL -c "$COOKIE" -A "$UA" \
    "https://drive.usercontent.google.com/download?id=${id}&export=download" -o "${out}.part"
  if grep -q 'uc-download-link' "${out}.part" 2>/dev/null; then
    uuid="$(grep -o 'name="uuid" value="[^"]*"' "${out}.part" | head -1 | sed 's/.*value="//;s/"$//')"
    [ -n "$uuid" ] || { echo "ERRO: token de confirmação não encontrado para ${id}"; exit 1; }
    curl -fSL -b "$COOKIE" -A "$UA" \
      "https://drive.usercontent.google.com/download?id=${id}&export=download&confirm=t&uuid=${uuid}" \
      -o "$out"
    rm -f "${out}.part"
  else
    mv "${out}.part" "$out"
  fi
}

unzip_to() {  # $1 = zip, $2 = padrão, $3 = destino
  local zip="$1" pat="$2" dest="$3"
  mkdir -p "$dest"
  if command -v unzip >/dev/null 2>&1; then
    unzip -o -j "$zip" "$pat" -d "$dest"
  else
    python3 - "$zip" "$pat" "$dest" <<'PY'
import sys, zipfile, fnmatch, os, shutil
zf, pat, dest = sys.argv[1], sys.argv[2], sys.argv[3]
with zipfile.ZipFile(zf) as z:
    for n in z.namelist():
        if fnmatch.fnmatch(os.path.basename(n), pat):
            with z.open(n) as s, open(os.path.join(dest, os.path.basename(n)), 'wb') as d:
                shutil.copyfileobj(s, d)
PY
  fi
}

mkdir -p "$DATA_DIR/apo" "$DATA_DIR/systemload" "$DATA_DIR/system"
echo "==> [fetch-artifacts] destino: $DATA_DIR"

if [ "$FETCH_ARTIFACTS" != "1" ]; then
  echo "    FETCH_ARTIFACTS=$FETCH_ARTIFACTS — download desativado, uso só o que está em disco"
else

  echo "==> [1/5] repositório de objetos (606 MB) -> apo/tttm120.rpo"
  if precisa "$DATA_DIR/apo/tttm120.rpo" "$SIZE_RPO"; then
    gdrive "$FID_RPO" "$DATA_DIR/apo/tttm120.rpo"
  else
    log "já presente"
  fi

  echo "==> [2/5] dicionário BR (592 MB) -> systemload/sxsbra.txt"
  if precisa "$DATA_DIR/systemload/sxsbra.txt" "$SIZE_SXSBRA"; then
    gdrive "$FID_SXSBRA" "$DATA_DIR/systemload/sxsbra.txt"
  else
    log "já presente"
  fi

  echo "==> [3/5] dicionários -> systemload/sx2.unq"
  if precisa "$DATA_DIR/systemload/sx2.unq" "$SIZE_SX2UNQ"; then
    gdrive "$FID_DICIONARIOS" "$WORK/dic.zip"
    unzip_to "$WORK/dic.zip" 'sx2.unq' "$DATA_DIR/systemload"
    log "extraído (o sdfbra.txt diferencial do mesmo zip é ignorado — não serve para ambiente novo)"
  else
    log "já presente"
  fi

  echo "==> [4/5] menus -> system/*.xnu"
  if [ "$(find "$DATA_DIR/system" -name '*.xnu' 2>/dev/null | wc -l)" -lt 60 ]; then
    gdrive "$FID_MENUS" "$WORK/menus.zip"
    unzip_to "$WORK/menus.zip" '*.xnu' "$DATA_DIR/system"
  else
    log "já presentes"
  fi

  echo "==> [5/5] helps -> systemload/hlp*.txt"
  if [ "$(find "$DATA_DIR/systemload" -name 'hlp*.txt' 2>/dev/null | wc -l)" -lt 3 ]; then
    gdrive "$FID_HELPS" "$WORK/helps.zip"
    unzip_to "$WORK/helps.zip" 'hlp*.txt' "$DATA_DIR/systemload"
  else
    log "já presentes"
  fi

fi

echo "==> [fetch-artifacts] conferência"
falhou=0
conferir() {  # $1 = caminho relativo, $2 = tamanho esperado
  local rel="$1" esp="$2"
  if [ -s "$DATA_DIR/$rel" ] && { [ -z "$esp" ] || [ "$(size "$DATA_DIR/$rel")" = "$esp" ]; }; then
    printf '    ok    %-26s %s\n' "$rel" "$(du -h "$DATA_DIR/$rel" | cut -f1)"
  else
    printf '    FALTA %s\n' "$rel"; falhou=1
  fi
}
conferir "apo/tttm120.rpo"        "$SIZE_RPO"
conferir "systemload/sxsbra.txt"  "$SIZE_SXSBRA"
conferir "systemload/sx2.unq"     "$SIZE_SX2UNQ"
printf '    %s    %-26s %s arquivos\n' \
  "$([ "$(find "$DATA_DIR/system" -name '*.xnu' | wc -l)" -ge 60 ] && echo ok || { echo FALTA; falhou=1; })" \
  "system/*.xnu" "$(find "$DATA_DIR/system" -name '*.xnu' | wc -l)"
printf '    %s    %-26s %s arquivos\n' \
  "$([ "$(find "$DATA_DIR/systemload" -name 'hlp*.txt' | wc -l)" -ge 3 ] && echo ok || { echo FALTA; falhou=1; })" \
  "systemload/hlp*.txt" "$(find "$DATA_DIR/systemload" -name 'hlp*.txt' | wc -l)"

[ "$falhou" -eq 0 ] || { echo "ERRO: artefatos incompletos"; exit 1; }
echo "==> [fetch-artifacts] pronto"
