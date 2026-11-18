# Skills de Feroz Content Lab

Dos skills para trabajar con Feroz Content Lab desde Claude:

- **`feroz-laboratorio`** (Claude Code): crea historias y carruseles en tu cuenta de Feroz con tus fotos y tu storytelling, y te dice cómo vas. Necesita una clave de Feroz (Mi cuenta › Conectar con Claude Code).
- **`feroz-historias-carruseles`** (chat de claude.ai): escribe y ubica los textos a partir del prompt y la hoja de contacto que genera la app. No usa la red.

## Instalar en Claude Code

Pega en Claude Code la instrucción que aparece en Feroz › Mi cuenta › Conectar con Claude Code. Si te la piden a mano: «Instala la skill de Feroz desde `<url de este repo>` y conéctala a `<url de Feroz>`».

### Pasos para Claude Code

1. Descarga este repo en una carpeta temporal:
   - con git: `git clone --depth 1 <url-del-repo> "<temporal>/feroz-skills"`;
   - sin git: `curl -fsSL https://codeload.github.com/<org>/<repo>/tar.gz/refs/heads/main | tar -xz -C "<temporal>"` (la carpeta queda como `<repo>-main`).
2. Por cada carpeta de la raíz que tenga un `SKILL.md`, cópiala a `~/.claude/skills/<nombre>/`. En Windows es `%USERPROFILE%\.claude\skills\<nombre>\` (desde Git Bash, `~/.claude/skills/` también funciona).
   - Si `~/.claude/skills/<nombre>/` ya existe, **pregunta antes de sobrescribirla**.
3. Marca el script como ejecutable: `chmod +x ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh`.
4. Conecta la cuenta con la URL de Feroz que te dieron: sigue «Primera vez» de `feroz-laboratorio/SKILL.md` (el usuario corre `feroz.sh login --url <url>` y pega su clave, o la pega en el chat).
5. Comprueba: `bash ~/.claude/skills/feroz-laboratorio/scripts/feroz.sh api GET /api/claude/me` responde con su correo.
6. Borra la carpeta temporal y di qué quedó instalado y dónde. Puede hacer falta reiniciar Claude Code para que vea las skills nuevas.

No hace falta instalar Node, Python ni servidores: el script usa `bash` y `curl`, que vienen con macOS, Linux y Git for Windows.

## Instalar en el chat de claude.ai

1. Activa la ejecución de código en los ajustes de Claude.
2. Comprime la carpeta `feroz-historias-carruseles` en `feroz-historias-carruseles.zip` (la carpeta debe quedar en la raíz del zip) y súbelo en *Customize › Skills*.
3. Activa la skill.
