# Esquema de `resultado.json` (feroz-resultado, versión 2)

Es lo único que devuelve la skill. La app de Feroz lo valida antes de aplicarlo y, si hay errores, no aplica nada.

```json
{
  "schemaVersion": 2,
  "type": "feroz-resultado",
  "templateId": "historias-dia-de-grabacion",
  "templateVersion": 1,
  "screens": [
    {
      "id": "arranque",
      "fields": [
        {
          "id": "titular",
          "text": "EMPIEZA EL DÍA DE GRABACIÓN",
          "x": 80,
          "y": 1120,
          "width": 920,
          "style": { "color": "#ffffff" }
        }
      ]
    }
  ]
}
```

## Campos

| Campo | Obligatorio | Regla |
| --- | --- | --- |
| `schemaVersion` | sí | Siempre `2`. |
| `type` | sí | Siempre `"feroz-resultado"`. |
| `templateId` | sí | El del prompt, exacto. |
| `templateVersion` | sí | El del prompt, exacto. |
| `screens[].id` | sí | Un `id` de pantalla del prompt. |
| `screens[].fields[].id` | sí | Un `id` de campo de esa pantalla. |
| `text` | no | Texto del campo. Si supera `maxChars` se aplica, pero la app avisa. |
| `x`, `y` | no | Píxeles del cuadro, esquina superior izquierda. `x ≥ 0`, `y ≥ 0`, `y < alto`. |
| `width` | no | Ancho del bloque en píxeles. `x + width ≤ 1080`. |
| `style.font` | no | `"display"` (Chakra Petch), `"text"` (Inter) o `"mono"` (JetBrains Mono). |
| `style.fontSize` | no | Número positivo, en píxeles del cuadro (la app permite de 24 a 180). |
| `style.color` | no | Token (`"--fg"`) o hex (`"#fff"`, `"#ffffff"`). |
| `style.highlight` | no | Token, hex o `null` para quitarlo. Se dibuja como un marcador por renglón. |
| `style.box` | no | Recuadro sólido detrás del texto: `{ "color": token o hex, "radius": entero de 0 a 64 }`, o `null` para quitarlo. |
| `style.bold`, `style.italic` | no | `true` o `false`. |

Lo que no venga se conserva. La app nunca toca las fotos.

## Errores que la app rechaza

- Otra plantilla: «Este resultado es de otra plantilla («…»). Abre «…» o genera de nuevo el prompt.»
- Otra versión: «El resultado es de la versión N de la plantilla y la actual es la M.»
- Pantalla o campo que no existe.
- Un campo que queda fuera del cuadro.
- Un color que no es hex ni token.
- Un archivo que no es `feroz-resultado` versión 2.

## Respuesta en claude.ai

Si no puedes crear archivos, devuelve un único bloque:

````
```json
{ "schemaVersion": 2, "type": "feroz-resultado", … }
```
````

La app acepta el texto pegado aunque lleve algo alrededor, pero lo más fiable es el bloque solo.
