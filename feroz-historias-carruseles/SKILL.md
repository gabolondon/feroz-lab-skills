---
name: feroz-historias-carruseles
description: Úsala cuando el usuario pega un prompt de Feroz Content Lab con una hoja de contacto para escribir y ubicar los textos de una historia o carrusel. Devuelve solo el JSON feroz-resultado que la app de Feroz importa.
---

# Feroz · historias y carruseles

Escribes y colocas los textos de una secuencia de historias de Instagram o de un carrusel que el usuario armó en Feroz Content Lab. La app ya tiene sus fotos; tú devuelves textos, posiciones y, si hace falta, estilos.

## Entradas

1. **El prompt de Feroz**, pegado por el usuario. Empieza con «Usa la skill feroz-historias-carruseles» y contiene un bloque JSON con la plantilla (`templateId`, `templateVersion`, medidas, `instructions`) y, por pantalla, sus campos con `id`, `label`, `guide`, `maxChars`, `text`, `x`, `y`, `width` y `style`.
2. **`hoja-de-contacto.png`**, adjunta. Muestra las pantallas en fila, numeradas con su ID (`1 · arranque`), con la foto en su posición actual, los textos actuales y una cuadrícula cada 10 % del cuadro.

Si falta cualquiera de las dos, pídela antes de seguir.

## Pasos

1. Lee las `instructions` de la plantilla y, en cada campo, su `guide` y su `maxChars`. Las guías marcadas `[borrador]` son provisionales: síguelas igual.
2. Mira cada pantalla en la hoja de contacto: qué muestra la foto, dónde están las caras y dónde hay zonas limpias (cielo, pared, mesa, fondo desenfocado).
3. Escribe, ubica y da estilo a cada texto siguiendo [reference/escritura.md](reference/escritura.md): tono, márgenes seguros, color, resaltado, recuadro y stickers. Para traducir zonas a coordenadas, usa la cuadrícula de la hoja de contacto (cada celda es el 10 % del ancho y del alto).

## Salida

Devuelve **solo** el bloque JSON `feroz-resultado` descrito en [reference/esquema-resultado.md](reference/esquema-resultado.md), con el `templateId` y el `templateVersion` exactos del prompt.

- Si el entorno permite crear archivos, entrégalo como `resultado.json`.
- Si no, como un único bloque de código ```json, sin texto antes ni después.
- Incluye solo las pantallas y campos que cambies; lo que no incluyas se conserva.

Ejemplo completo: [examples/prompt-ejemplo.txt](examples/prompt-ejemplo.txt) → [examples/resultado-ejemplo.json](examples/resultado-ejemplo.json).

## Prohibiciones

Las de [reference/escritura.md](reference/escritura.md#prohibiciones): no inventes cifras, nombres ni testimonios (pregunta), no añadas pantallas ni campos y no incluyas imágenes.

## Entorno

No usa la red ni descarga nada del servidor de Feroz. Funciona en claude.ai (con la ejecución de código activada) y en Claude Code.
