# html-temporal

Skill para [Claude Code](https://claude.com/claude-code) que publica páginas HTML **temporales** en tu propio servidor: correos listos para copiar y pegar, tablas, mensajes. Cada página se borra sola a la hora.

Sirve cuando necesitas pasarle a alguien un texto con formato y no quieres pegar HTML en la terminal ni depender de una cuenta externa. Le pides a Claude "pásame el correo en HTML para copiar" y te regresa un link:

```
url: https://midominio.com/tmp-html/correo-equipo-3b05ed9a88899b8019309673.html
http: 200
expira: ~11:30 Mexico_City (el cron borra cada 5 min)
```

Los correos traen los botones **Copiar asunto** y **Copiar cuerpo**. El cuerpo se copia con formato (`text/html` + `text/plain`) y se pega bien en Gmail y Outlook.

Como el formato incluye los colores, la página tiene un selector de colores:

| Modo | Qué se copia |
|---|---|
| **Claro** | Texto oscuro sobre fondo blanco |
| **Oscuro** | Texto claro sobre fondo oscuro |
| **Sin color** | Sin colores ni fondos: toma el tema del correo de quien lo recibe |

Claude elige el modo inicial según lo que pidas ("en modo oscuro", "sin colores"). Se puede cambiar en la página antes de copiar.

## Cómo funciona

```
Claude escribe el HTML ──▶ publish.sh ──▶ /var/www/tmp-html/<slug>-<24 hex>.html
                                                   │
                         web server (Alias) ◀──────┘   cron: borra lo que tenga > 60 min
```

- **Sin app nueva:** es una carpeta servida por Apache o nginx, más un cron.
- **Nombres inadivinables:** cada archivo lleva 24 caracteres hex al azar, sin listado de carpeta, con `noindex` y `no-store`.
- **Ojo:** quien tenga el link puede ver la página mientras exista. No publiques contraseñas, tokens ni datos personales.

## Instalación

**1. Clona y corre el instalador.**

Para tu usuario:

```bash
git clone https://github.com/TheWebChimp/html-temporal.git
cd html-temporal
./install.sh --dir /var/www/tmp-html --url https://midominio.com/tmp-html/ \
             --tz "America/Mexico_City America/Costa_Rica"
```

Para un solo proyecto, agrega `--project /ruta/al/proyecto`.

**2. Sirve la carpeta** con [`server/apache.conf`](server/apache.conf) o [`server/nginx.conf`](server/nginx.conf), y recarga el servidor:

```bash
apache2ctl configtest && systemctl reload apache2
# o
nginx -t && systemctl reload nginx
```

> Si tu vhost hace proxy de `/` a una app (Node, etc.), el `ProxyPass /tmp-html/ !` debe ir **antes** del `ProxyPass /`.

**3. Activa el borrado automático:**

```bash
sudo cp server/cron /etc/cron.d/html-temporal && sudo chmod 644 /etc/cron.d/html-temporal
```

**4. Prueba:**

```bash
echo '<h1>hola</h1>' > /tmp/t.html && ~/.claude/skills/html-temporal/publish.sh /tmp/t.html prueba
```

## Configuración

`install.sh` escribe `config.env` junto al skill. También se puede definir con variables de entorno:

| Variable | Qué es | Default |
|---|---|---|
| `TMP_HTML_DIR` | Carpeta que sirve el web server | (obligatoria) |
| `TMP_HTML_BASE_URL` | URL pública de esa carpeta | (obligatoria) |
| `TMP_HTML_TTL_MIN` | Minutos de vida, solo para mostrar la hora de expiración | `60` |
| `TMP_HTML_TZ` | Zonas horarias para la expiración, separadas por espacio | `UTC` |

Si cambias la vida o la carpeta, ajusta también el `-mmin` y la ruta en el cron.

### Un dominio por proyecto

Con el skill instalado una sola vez para tu usuario, cada proyecto puede publicar en su propio dominio. Crea `.claude/html-temporal.env` en la raíz del proyecto con las mismas variables:

```bash
TMP_HTML_DIR="/var/www/mi-proyecto/.tmp-html"
TMP_HTML_BASE_URL="https://mi-proyecto.com/tmp-html/"
```

`publish.sh` busca ese archivo subiendo desde `CLAUDE_PROJECT_DIR` (o la carpeta actual) y, si lo encuentra, pisa la config global. Cada carpeta necesita su propio alias en el web server y su línea de cron.

## Contenido

```
install.sh                         instalador
skill/html-temporal/SKILL.md       instrucciones para Claude
skill/html-temporal/publish.sh     publica un archivo y devuelve la URL
skill/html-temporal/templates/     plantilla de correo: copiar asunto/cuerpo, modo claro/oscuro/sin color
server/                            Apache, nginx y cron
```

## English

A Claude Code skill that publishes throwaway HTML pages (copy-paste-ready emails with light/dark/no-color modes, tables, messages) to a folder on your own web server and returns the link. A cron job deletes them after an hour. Run `./install.sh --dir <served dir> --url <public url>`, add the Apache or nginx snippet from `server/`, and install the cron. Anyone with the link can open the page until it expires, so don't publish secrets.

## Licencia

MIT
