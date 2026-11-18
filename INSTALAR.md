# Instalar las skills de Feroz

Este paquete trae una carpeta por skill (cada una con su `SKILL.md`).

## En Claude Code (y en el modo Code de la app de Claude)

Pide a Claude Code: «Instala las skills de este paquete siguiendo INSTALAR.md». Los pasos son:

1. Descomprimir `paquete-feroz.zip` en una carpeta temporal.
2. Por cada carpeta del paquete que contenga un `SKILL.md`, copiarla a `~/.claude/skills/<nombre>/`.
   - Si `~/.claude/skills/<nombre>/` ya existe, **preguntar antes de sobrescribirla**.
3. Listar lo instalado: el nombre de cada skill y su ruta.

Las skills instaladas así quedan disponibles en Claude Code y en el modo Code de la app de Claude. **No** aparecen en el chat de claude.ai.

## En el chat de claude.ai o de la app de Claude

El chat instala **un zip por skill**:

1. Activa la ejecución de código en los ajustes de Claude (las skills la necesitan).
2. Ve a *Customize › Skills* y sube cada `dist/skills/<nombre>.zip` (por ejemplo `feroz-historias-carruseles.zip`).
3. Activa la skill.

## Skills incluidas

- `feroz-laboratorio` (Claude Code): crea historias y carruseles en la cuenta de Feroz con fotos y textos, y resume la actividad («¿cómo voy?»). Usa `scripts/feroz.sh` y una clave de Mi cuenta › Conectar con Claude Code; después de copiarla, sigue «Primera vez» de su `SKILL.md`.
- `feroz-historias-carruseles` (chat de claude.ai y Claude Code): escribe y ubica los textos de una historia o un carrusel de Feroz Content Lab a partir del prompt y la hoja de contacto que genera la app.
