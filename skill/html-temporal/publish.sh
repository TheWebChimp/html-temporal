#!/usr/bin/env bash
# Publica un HTML temporal y devuelve su URL. El archivo se borra solo
# después de TMP_HTML_TTL_MIN minutos (lo borra el cron de server/cron).
#
# Uso: publish.sh <archivo.html> [slug]
#
# Configuración: config.env junto a este script (lo crea install.sh) o
# variables de entorno:
#   TMP_HTML_DIR       carpeta servida por el web server
#   TMP_HTML_BASE_URL  URL pública de esa carpeta, con / al final
#   TMP_HTML_TTL_MIN   minutos de vida (default 60)
#   TMP_HTML_TZ        zonas horarias para mostrar la expiración, separadas por espacio
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
[ -f "$here/config.env" ] && . "$here/config.env"

: "${TMP_HTML_DIR:?Falta TMP_HTML_DIR (corre install.sh o define la variable)}"
: "${TMP_HTML_BASE_URL:?Falta TMP_HTML_BASE_URL}"
TMP_HTML_TTL_MIN="${TMP_HTML_TTL_MIN:-60}"
TMP_HTML_TZ="${TMP_HTML_TZ:-UTC}"

src="${1:?uso: publish.sh <archivo.html> [slug]}"
[ -f "$src" ] || { echo "No existe: $src" >&2; exit 1; }

slug="$(printf '%s' "${2:-pagina}" | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//' | cut -c1-40)"
[ -n "$slug" ] || slug=pagina
# 24 caracteres hex al azar: la URL no se puede adivinar.
rand="$(openssl rand -hex 12 2>/dev/null || head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')"
name="${slug}-${rand}.html"

install -m 644 "$src" "$TMP_HTML_DIR/$name"
url="${TMP_HTML_BASE_URL%/}/$name"

echo "url: $url"
if command -v curl >/dev/null; then
	echo "http: $(curl -s -o /dev/null -w '%{http_code}' "$url")"
fi
exp=""
for tz in $TMP_HTML_TZ; do
	exp="$exp $(TZ="$tz" date -d "+${TMP_HTML_TTL_MIN} min" '+%H:%M' 2>/dev/null || TZ="$tz" date -v+"${TMP_HTML_TTL_MIN}"M '+%H:%M') ${tz##*/}"
done
echo "expira: ~${exp# } (el cron borra cada 5 min)"
