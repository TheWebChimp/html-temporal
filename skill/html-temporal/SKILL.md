---
name: html-temporal
description: Crear un HTML temporal en una URL pública que el usuario abre para copiar y pegar (correos, textos, tablas) y que se borra solo después de un rato. Usar cuando pidan "un HTML para copiar", "un correo en HTML", "pásamelo en una página", o algo temporal para copy-paste.
---

# HTML temporal (copy & paste)

Páginas desechables en una carpeta que sirve tu web server. La URL y la carpeta están en `config.env`, junto a este archivo.

## Pasos
1. Escribe el HTML en un directorio temporal (no en el repo del proyecto).
2. Publica con `publish.sh <archivo.html> <slug-corto>`, que está en la misma carpeta que este SKILL.md.
3. Dale al usuario la `url` y la hora de expiración que imprime el script. Si `http` no es 200, revisa antes de responder.

## Reglas
- La URL es pública para quien la tenga: el nombre lleva 24 caracteres hex al azar, no hay listado de la carpeta y lleva `noindex`. **No pongas contraseñas, tokens ni datos personales de clientes.**
- Todo va en un solo archivo, sin recursos externos (nada de CDN ni imágenes remotas).

## Si es un correo
**Siempre** parte de `templates/correo.html`, que está en la misma carpeta que este SKILL.md. Trae dos botones, **Copiar asunto** y **Copiar cuerpo**, y un selector de colores (Claro / Oscuro / Sin color). Los colores del modo elegido se copian con el cuerpo.

Qué cambiar:
- **El asunto:** el texto de `<div id="asunto">`.
- **El cuerpo:** solo lo que va dentro de `<div id="contenido">`. Lo demás de la plantilla no se toca.
- **El modo inicial:** el atributo `data-modo` de `<html>`. Por defecto es `claro`.
  - Si el usuario pide modo oscuro, pon `data-modo="oscuro"`.
  - Si dice que se le pegan los colores, o que lo quiere "sin formato de color", pon `data-modo="sin-color"`.
  - Si no dice nada, deja `claro`.
  - En la página puede cambiar el modo antes de copiar.

Reglas del cuerpo:
- **Estilos inline** y tablas para el layout, porque Gmail y Outlook ignoran `<style>`. Ancho máximo de 640px y fuente Arial/Helvetica.
- **Usa solo estos colores, escritos en hex de 6 dígitos.** El modo oscuro cambia cada uno por su par, y "Sin color" quita `color` y `background` y deja los bordes en gris neutro. Un color fuera de esta lista no cambia de modo.

| Uso | Claro (el que escribes) | Oscuro (automático) |
|---|---|---|
| Texto | `#1f2933` | `#e6e9ed` |
| Títulos | `#0b3d5c` | `#8cc4ea` |
| Links | `#0b62a3` | `#7cb8ec` |
| Texto secundario | `#5f6b7a` | `#a3adb8` |
| Fondo | `#ffffff` | `#1b1f24` |
| Celda destacada | `#f7f8fa` | `#262b31` |
| Bordes | `#e3e6ea` | `#3a4048` |

- **Fondos:** usa `background-color`, no `background`.
- **Tabla exterior:** debe conservar su `color` y `background-color`, para que el bloque copiado se vea igual en el correo de destino.

## Si es texto plano
Para un mensaje de WhatsApp o Slack, usa un `<textarea readonly>` o un `<pre>` con un botón "Copiar".

## Tono
Escribe en el idioma y el registro de quien lo va a leer. Si va a gente no técnica, sin jerga.
