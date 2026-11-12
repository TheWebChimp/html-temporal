#!/usr/bin/env bash
# Instala el skill html-temporal para Claude Code.
#
#   ./install.sh --dir /var/www/tmp-html --url https://midominio.com/tmp-html/ \
#                [--ttl 60] [--tz "America/Mexico_City UTC"] [--project /ruta/al/proyecto]
#
# Sin --project se instala para tu usuario (~/.claude/skills); con --project,
# en <proyecto>/.claude/skills. No toca el web server ni el cron: eso está en
# server/ (ver README).
set -euo pipefail

dir="" url="" ttl=60 tz="UTC" project=""
while [ $# -gt 0 ]; do
	case "$1" in
		--dir) dir="$2"; shift 2 ;;
		--url) url="$2"; shift 2 ;;
		--ttl) ttl="$2"; shift 2 ;;
		--tz) tz="$2"; shift 2 ;;
		--project) project="$2"; shift 2 ;;
		-h|--help) sed -n '2,9p' "$0"; exit 0 ;;
		*) echo "Opción desconocida: $1" >&2; exit 1 ;;
	esac
done
[ -n "$dir" ] && [ -n "$url" ] || { echo "Faltan --dir y --url (./install.sh --help)" >&2; exit 1; }
case "$ttl" in ''|*[!0-9]*) echo "--ttl debe ser un número de minutos" >&2; exit 1 ;; esac

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -n "$project" ]; then dest="$project/.claude/skills/html-temporal"; else dest="$HOME/.claude/skills/html-temporal"; fi

mkdir -p "$dest" "$dir"
chmod 755 "$dir"
cp -R "$here/skill/html-temporal/." "$dest/"
chmod +x "$dest/publish.sh"
cat > "$dest/config.env" <<CFG
TMP_HTML_DIR="$dir"
TMP_HTML_BASE_URL="${url%/}/"
TMP_HTML_TTL_MIN="$ttl"
TMP_HTML_TZ="$tz"
CFG

echo "Skill instalado en $dest"
echo "Carpeta: $dir  ·  URL: ${url%/}/  ·  vida: $ttl min"
echo
echo "Falta, si no lo has hecho:"
echo "  1. Servir la carpeta en tu web server (server/apache.conf o server/nginx.conf)."
echo "  2. Instalar el borrado automático (server/cron → /etc/cron.d/html-temporal)."
echo "  3. Probar:  echo '<h1>hola</h1>' > /tmp/t.html && $dest/publish.sh /tmp/t.html prueba"
