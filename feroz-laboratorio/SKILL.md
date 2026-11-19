---
name: feroz-laboratorio
description: Úsala cuando el usuario quiera crear una secuencia de historias o un carrusel de Feroz Content Lab desde Claude Code (con sus fotos y su storytelling, dejando el proyecto listo en la app), o pregunte cómo va su trabajo en Feroz («¿cómo voy?»). Habla con la API de Feroz mediante scripts/feroz.sh.
---

# Feroz · laboratorio desde Claude Code

Llevas al usuario de Feroz Content Lab por categoría → plantilla, pides sus fotos y lo que quiere contar, escribes los textos y dejas el proyecto creado en la app, con fotos y textos puestos, para que lo afine en el tablero. Los usuarios son alumnos de una mentoría: explica en lenguaje llano, sin jerga técnica.

## Regla de oro

- La API de Feroz **solo** se llama con `bash <carpeta-de-esta-skill>/scripts/feroz.sh …` (la carpeta es la «Base directory» de esta skill, normalmente `~/.claude/skills/feroz-laboratorio`). Nunca con `curl` directo.
- **Nunca** imprimas, repitas ni guardes la clave en archivos, en el chat ni en comandos que no sean el `login` de abajo.
- `feroz.sh` imprime JSON. Salidas: `0` bien · `1` error de la API (el JSON del error va a stderr) · `2` la respuesta no es de la API de Feroz · `3` no hay clave guardada · `4` sin conexión.

Cada llamada de Bash empieza en una terminal nueva: escribe siempre la ruta completa del script (no la guardes en una variable). Si la skill está en otra carpeta, cambia `~/.claude/skills/feroz-laboratorio` por esa.

```sh
bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh api GET /api/claude/me
bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh api GET '/api/claude/catalog?tool=historias'      # o carruseles
bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh api GET /api/claude/templates/<templateId>
bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh api POST /api/claude/projects @proyecto.json       # {"templateId": "…", "name": "…" opcional}
bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh upload /api/claude/projects/<id>/screens/<screenId>/photo "<ruta de la foto>"
bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh api POST /api/claude/projects/<id>/result @resultado.json
bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh api GET /api/claude/activity
```

Los archivos `@….json` escríbelos en una carpeta temporal, no en la carpeta del usuario.

## Primera vez (salida 3)

1. Si el usuario aún no tiene clave: que entre a Feroz › **Mi cuenta** › **Conectar con Claude Code**, cree una clave (por ejemplo «Mi portátil») y la copie. La URL de Feroz es https://lab.ferozcontentlab.com (la misma que trae la **Instrucción para Claude Code** de esa pantalla); si el usuario te da otra, usa la suya.
2. Ofrece dos caminos para guardarla:
   - **En su terminal (recomendado):** que escriba en Claude Code `! bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh login --url https://lab.ferozcontentlab.com` y pegue la clave cuando se la pida. Si así no le deja escribir, que lo corra en la app Terminal (o Git Bash en Windows) sin el `!`.
   - **Pegándola en el chat:** corre tú `printf '%s' '<clave>' | bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh login --url https://lab.ferozcontentlab.com`. Solo esa vez; después no la vuelvas a escribir.
3. Debe responder `Conectado como <email>.` La clave queda en el llavero del sistema (Llavero en macOS, cifrada con la cuenta en Windows, `secret-tool` en Linux).
4. En Linux, si `feroz.sh` avisa que la guardó en un archivo, recomienda `sudo apt install libsecret-tools` y repetir el login.

Errores al conectar:
- **Salida 2:** la URL no es la de Feroz, o hay una página de acceso delante. Pide la URL exacta de Mi cuenta; si sigue, que avise a su mentor.
- **`invalid_key`:** la clave fue revocada o está mal copiada: que cree otra.
- **`suspended`:** la cuenta está suspendida: que hable con su mentor.

## Crear una historia o un carrusel

1. **Herramienta:** pregunta si quiere una **secuencia de historias** (1080×1920) o un **carrusel** (1080×1350), si no lo dijo.
2. **Categoría:** `GET /api/claude/catalog?tool=…` y muestra las categorías con cuántas plantillas tiene cada una.
3. **Plantilla:** muestra las de la categoría elegida: nombre, para qué sirve (de `instructions`), nº de pantallas y de fotos. Ayúdale a elegir según lo que quiere contar.
4. **Qué hace falta:** `GET /api/claude/templates/<id>`. Explica pantalla por pantalla el `role`, qué foto pide (`imageGuide`) y qué textos lleva (campos con su `guide`). Pide:
   - la **ruta de una foto por pantalla** que la pida (`imageRequired`); acepta una carpeta y propón el orden;
   - el **storytelling**: qué quiere contar, a quién, y los datos reales que haga falta (cifras, nombres, fechas). No los inventes.
5. **Crear el proyecto:** `POST /api/claude/projects` con `{"templateId": "<id>"}` (y `"name"` si el usuario le puso nombre). Guarda `id` y `editorUrl`.
6. **Subir fotos:** `upload` de cada foto a su pantalla (`screens[].id`). Cita la ruta entre comillas; acepta espacios, acentos y rutas de Windows (`C:\Users\…`).
   - **415 / `UNSUPPORTED`:** casi siempre es una foto HEIC del iPhone. Pide que la exporte como JPG (en Fotos: Archivo › Exportar, o en el iPhone Ajustes › Cámara › Formatos › Más compatible) y vuelve a subirla.
   - **413 / `too_large`:** la foto pasa de 15 MB; que la exporte más pequeña.
7. **Mirar las fotos:** léelas (puedes ver imágenes) para saber dónde están las caras y las zonas limpias. La app las pone en modo «cubrir»: llenan el cuadro y se recortan centradas.
8. **Escribir los textos** siguiendo [reference/escritura.md](reference/escritura.md): tono, márgenes seguros, color, resaltado y recuadro. Si falta un dato, pregunta antes de seguir.
9. **Enviar el resultado:** escribe `resultado.json` con el formato de [reference/esquema-resultado.md](reference/esquema-resultado.md), con el `templateId` y el `templateVersion` exactos de la plantilla, y envíalo con `api POST /api/claude/projects/<id>/result @resultado.json`.
   - **422 `invalid_result`:** lee `errors` (vienen en español), corrige y reenvía.
   - Si el error es de **versión** («El resultado es de la versión…»), vuelve a pedir `templates/<id>`, ajusta el resultado a la versión actual y reenvía.
   - `warnings` (textos más largos que `maxChars`): acórtalos si puedes, o díselo al usuario.
10. **Cerrar:** da el `editorUrl` y una línea de qué revisar en el tablero (por ejemplo, que el titular no tape una cara en la pantalla 3). Si el proyecto ya estaba abierto en otra pestaña, la app le avisará que hay una versión nueva: que recargue.

**Stickers:** el resultado no los rellena. Si una pantalla tiene `sticker`, propón en el chat su texto (pregunta, opciones o enlace) y dile que lo ponga en el tablero o directamente en Instagram.

## ¿Cómo voy?

`GET /api/claude/activity` y resúmelo en lenguaje llano: cuántos proyectos tiene en curso, exportados y archivados por herramienta, cuántas versiones lleva y los últimos proyectos con su enlace (`editorUrl`). Aclara que es su actividad en la app: **todavía no hay métricas de Instagram**.

## Prohibiciones

Las de [reference/escritura.md](reference/escritura.md#prohibiciones): no inventes cifras, nombres, clientes ni testimonios (pregunta), no añadas pantallas ni campos y no incluyas imágenes en el resultado. Tampoco toques proyectos que el usuario no pidió.
