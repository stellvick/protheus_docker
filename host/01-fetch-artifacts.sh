#!/usr/bin/env bash
# =============================================================================
# 01-fetch-artifacts.sh — baixa os artefatos licenciados direto para o host
# =============================================================================
# Os arquivos vem da pasta publica do Google Drive do usuario. Nao ha copia
# offline: 606 MB (RPO) + 592 MB (dicionario) nao passam por Git.
#
# Baixa e organiza (o sdfbra.txt diferencial fica de fora — nao e usado por um
# ambiente novo; ele serve para atualizar dicionario existente):
#
#   apo/tttm120.rpo            <- REPOSITORIO_DE_OBJETOS_BRASIL_12_1_2510
#   systemload/sxsbra.txt      <- sxsbra.txt
#   systemload/sx2.unq         <- DICIONARIOS_DIF zip
#   systemload/hlp*.txt        <- HELPS zip
#   system/*.xnu               <- MENUS zip
#
# Uso:  DATA_DIR=/srv/protheus bash 01-fetch-artifacts.sh
# =============================================================================
set -euo pipefail

DATA_DIR="${DATA_DIR:-/srv/protheus}"
UA="Mozilla/5.0 (compatible; protheus-fetch/1.0)"
WORK="$(mktemp -d)"
COOKIE="$WORK/cookies.txt"
trap 'rm -rf "$WORK"' EXIT

command -v curl >/dev/null 2>&1 || { echo "ERRO: curl nao encontrado"; exit 1; }

# IDs da pasta do Drive. A pasta e publica (link "qualquer pessoa com o link").
FID_RPO="1YUEM8sJDRGI0SK-uirJQhMU8_R9QZyRA"
FID_SXSBRA="1QYWO9GWydbIkTXgRPkB60NoXu5acp6tU"
FID_DICIONARIOS="1xZsQLUY3q_5yh7TYIn7eoyO51f28ppdO"
FID_MENUS="1yJA5q6L3lIG7B12zMNsbsEL3BQCKhqGv"
FID_HELPS="1MihUsvtcIgo4sJjTIIhr67Ton5Xins4C"

# O Google exige um token de confirmacao para arquivos acima de ~25 MB. O
# segundo parametro do token vem no HTML da primeira resposta; sem ele o
# download devolve a pagina de aviso em vez do arquivo.
gdrive() {
  local id="$1" out="$2" uuid
  curl -fsSL -c "$COOKIE" -A "$UA" \
    "https://drive.usercontent.google.com/download?id=${id}&export=download" \
    -o "${out}.part"
  if grep -q 'uc-download-link' "${out}.part"; then
    uuid="$(grep -o 'name="uuid" value="[^"]*"' "${out}.part" | head -1 | sed 's/.*value="//;s/"$//')"
    [ -n "$uuid" ] || { echo "ERRO: token de confirmacao nao encontrado para ${id}"; exit 1; }
    curl -fSL -b "$COOKIE" -A "$UA" \
      "https://drive.usercontent.google.com/download?id=${id}&export=download&confirm=t&uuid=${uuid}" \
      -o "$out"
    rm -f "${out}.part"
  else
    mv "${out}.part" "$out"
  fi
}

# unzip pode nao existir num host enxuto; python3 -m zipfile faz o mesmo.
unzip_to() {
  local zipfile="$1" pattern="$2" dest="$3"
  if command -v unzip >/dev/null 2>&1; then
    unzip -o -j "$zipfile" "$pattern" -d "$dest"
  else
    python3 - "$zipfile" "$pattern" "$dest" <<'PY'
import sys, zipfile, fnmatch, os, shutil
zf, pat, dest = sys.argv[1], sys.argv[2], sys.argv[3]
with zipfile.ZipFile(zf) as z:
    for n in z.namelist():
        if fnmatch.fnmatch(os.path.basename(n), pat):
            with z.open(n) as src, open(os.path.join(dest, os.path.basename(n)), 'wb') as dst:
                shutil.copyfileobj(src, dst)
PY
  fi
}

echo "==> destino: $DATA_DIR"
install -d "$DATA_DIR/apo" "$DATA_DIR/systemload" "$DATA_DIR/system"

echo "==> [1/5] repositorio de objetos (606 MB) -> apo/tttm120.rpo"
gdrive "$FID_RPO" "$DATA_DIR/apo/tttm120.rpo"

echo "==> [2/5] dicionario BR (592 MB) -> systemload/sxsbra.txt"
gdrive "$FID_SXSBRA" "$DATA_DIR/systemload/sxsbra.txt"

echo "==> [3/5] dicionarios diferenciais -> systemload/sx2.unq"
gdrive "$FID_DICIONARIOS" "$WORK/dic.zip"
unzip_to "$WORK/dic.zip" 'sx2.unq' "$DATA_DIR/systemload"

echo "==> [4/5] menus -> system/*.xnu"
gdrive "$FID_MENUS" "$WORK/menus.zip"
unzip_to "$WORK/menus.zip" '*.xnu' "$DATA_DIR/system"

echo "==> [5/5] helps -> systemload/hlp*.txt"
gdrive "$FID_HELPS" "$WORK/helps.zip"
unzip_to "$WORK/helps.zip" 'hlp*.txt' "$DATA_DIR/systemload"

echo
echo "==> conferencia"
for f in apo/tttm120.rpo systemload/sxsbra.txt systemload/sx2.unq; do
  if [ -s "$DATA_DIR/$f" ]; then
    printf '    ok    %-28s %s\n' "$f" "$(du -h "$DATA_DIR/$f" | cut -f1)"
  else
    printf '    FALTA %s\n' "$f"; exit 1
  fi
done
printf '    ok    %-28s %s arquivos\n' "system/*.xnu" "$(find "$DATA_DIR/system" -name '*.xnu' | wc -l)"
printf '    ok    %-28s %s arquivos\n' "systemload/hlp*.txt" "$(find "$DATA_DIR/systemload" -name 'hlp*.txt' | wc -l)"
echo
echo "==> proximo passo: bash 02-gen-dbaccess.sh"
