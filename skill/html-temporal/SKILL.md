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
Parte de `templates/correo.html` y cambia solo el asunto y lo que va dentro de `<div id="contenido">`.
- **Estilos inline** y tablas para el layout: Gmail y Outlook ignoran `<style>`.
- Ancho máximo de 640px y fuente Arial/Helvetica.
- La plantilla ya trae los botones "Copiar asunto" y "Copiar correo". Este último copia como `text/html` + `text/plain` para que al pegar se conserve el formato.

## Si es texto plano
Para un mensaje de WhatsApp o Slack, usa un `<textarea readonly>` o un `<pre>` con un botón "Copiar".

## Tono
Escribe en el idioma y el registro de quien lo va a leer. Si va a gente no técnica, sin jerga.
