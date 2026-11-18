# Escribir, ubicar y dar estilo a los textos

Reglas compartidas por las skills de Feroz (`feroz-historias-carruseles` y `feroz-laboratorio`). Se aplican igual tanto si miras una hoja de contacto como si miras las fotos originales.

## Tono

- Directo y cercano, en segunda persona o en primera del creador, como habla en sus historias.
- Frases cortas y concretas. Sin promesas exageradas, sin «secretos», sin urgencia falsa.
- Respeta `maxChars`; si no cabe, recorta la idea, no la letra.
- Los titulares en mayúsculas solo si el texto actual o la guía ya lo están.

## Ubicación y márgenes seguros

- Evita caras, manos con gesto y zonas con mucho detalle. Busca zonas limpias: cielo, pared, mesa, fondo desenfocado.
- Coordenadas en píxeles del cuadro (1080 de ancho). `x`, `y` son la esquina superior izquierda; `width` el ancho del bloque. Todo debe quedar dentro: `x ≥ 0`, `y ≥ 0`, `x + width ≤ 1080`, `y < alto`.
- **Historias (1080×1920):** márgenes seguros de Instagram. Ningún texto nuevo en los 250 px de arriba ni en los 340 px de abajo (la interfaz de Instagram los tapa). Cuenta el alto del texto: aproximadamente `líneas × fontSize × 1,15`.
- **Carruseles (1080×1350):** deja al menos 80 px de margen en los bordes.
- Para traducir una zona de la foto a coordenadas, piensa en porcentajes del cuadro: cada 10 % del ancho son 108 px; cada 10 % del alto, 192 px en historias y 135 px en carruseles. La app pone la foto en modo «cubrir»: llena el cuadro y recorta lo que sobra, centrado.
- Los campos `rol` son la etiqueta fija de la plantilla: no los muevas salvo que tapen una cara.

## Color, resaltado y recuadro

Cámbialos solo si el texto no se leería sobre la foto. Usa tokens (`--fg`, `--accent2`, `--action`, `--panel`) o hex (`#ffffff`).

- **Resaltado** (`"highlight": "--action"`): un marcador detrás de las palabras de cada renglón, ceñido a cada línea.
- **Recuadro** (`"box": { "color": "--panel", "radius": 0 }`): una caja sólida del ancho del campo, detrás de todo el texto. `radius` va de 0 (esquina recta) a 64; la app usa 0 o 16. `"box": null` lo quita.
- Se pueden usar los dos a la vez. Prefiere el recuadro cuando la foto tiene mucho detalle detrás de un bloque de varias líneas.

## Stickers

Si una pantalla tiene `sticker`, deja libre la zona central inferior (alrededor del 70 % del alto): ahí va el sticker de Instagram.

## Prohibiciones

- No inventes cifras, resultados, nombres, clientes ni testimonios. Si un campo pide una cifra o un caso y no lo tienes, pregunta al usuario antes de escribirlo.
- No añadas pantallas ni campos, ni cambies sus `id`.
- No incluyas imágenes, URLs de imágenes ni datos binarios en el resultado.
