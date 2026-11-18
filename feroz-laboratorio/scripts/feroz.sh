#!/usr/bin/env bash
# feroz.sh — la skill feroz-laboratorio habla con la API de Feroz Content Lab solo a través de este script.
#
#   feroz.sh login [--url URL]          guarda la clave (por stdin, o la pide si hay terminal) tras comprobarla
#   feroz.sh logout                     borra la clave de este computador
#   feroz.sh api MÉTODO RUTA [@a.json]  llama a la API e imprime el JSON
#   feroz.sh upload RUTA-API FOTO       sube una foto (multipart, campo file)
#
# La clave nunca se imprime ni va como argumento de un programa: curl la recibe por stdin (-H @-).
# Almacén: FEROZ_KEY_STORE=auto|keychain|dpapi|secret-tool|file (auto elige según el sistema).
# Configuración: FEROZ_CONFIG_DIR (por defecto ~/.config/feroz).
#
# Salidas: 0 bien · 1 error de la API o de uso · 2 la respuesta no es de la API de Feroz
#          3 no hay clave guardada · 4 no se pudo conectar
set -uo pipefail

CONFIG_DIR="${FEROZ_CONFIG_DIR:-$HOME/.config/feroz}"
SERVICE="feroz-content-lab"
NO_KEY="No hay clave guardada. Crea una en Mi cuenta › Conectar con Claude Code y corre feroz.sh login."
NOT_FEROZ="La respuesta no es de la API de Feroz. Revisa la URL (feroz.sh login --url …) o pide a tu mentor que revise el acceso."

die() { printf '%s\n' "$1" >&2; exit "${2:-1}"; }

store_kind() {
  local kind="${FEROZ_KEY_STORE:-auto}"
  if [ "$kind" != "auto" ]; then printf '%s' "$kind"; return; fi
  case "$(uname -s)" in
    Darwin) printf 'keychain' ;;
    MINGW*|MSYS*|CYGWIN*) printf 'dpapi' ;;
    *) if command -v secret-tool >/dev/null 2>&1; then printf 'secret-tool'; else printf 'file'; fi ;;
  esac
}

saved_url() { [ -f "$CONFIG_DIR/url" ] && tr -d '\r\n' < "$CONFIG_DIR/url"; return 0; }

# --- Almacenes de la clave. La clave entra siempre por stdin. ------------------------------------------
PS_SAVE='$k = [Console]::In.ReadToEnd().Trim(); $d = Join-Path $env:APPDATA "feroz"; New-Item -ItemType Directory -Force -Path $d | Out-Null; ConvertTo-SecureString -String $k -AsPlainText -Force | ConvertFrom-SecureString | Set-Content -Path (Join-Path $d "key.txt")'
PS_READ='$p = Join-Path $env:APPDATA "feroz\key.txt"; if (Test-Path $p) { [Net.NetworkCredential]::new("", (Get-Content $p | ConvertTo-SecureString)).Password }'
PS_DELETE='$p = Join-Path $env:APPDATA "feroz\key.txt"; if (Test-Path $p) { Remove-Item $p }'

save_file() { # clave por stdin → archivo con permisos 600
  mkdir -p "$CONFIG_DIR" && (umask 077 && cat > "$CONFIG_DIR/key") && chmod 600 "$CONFIG_DIR/key"
}

save_key() { # url; clave por stdin
  local url="$1" key
  key="$(cat)"
  case "$(store_kind)" in
    keychain)
      # security -i lee la orden por stdin: la clave no aparece en la lista de procesos.
      printf 'add-generic-password -U -s "%s" -a "%s" -w "%s"\n' "$SERVICE" "$url" "$key" | security -i >/dev/null ;;
    dpapi) printf '%s' "$key" | powershell.exe -NoProfile -NonInteractive -Command "$PS_SAVE" ;;
    secret-tool)
      # Sin llavero en marcha (WSL, SSH) secret-tool falla: se guarda en el archivo 600 y se avisa.
      if ! printf '%s' "$key" | secret-tool store --label "Feroz Content Lab" service "$SERVICE" url "$url" 2>/dev/null; then
        printf '%s' "$key" | save_file || return 1
        printf 'El llavero del sistema no respondió; la clave quedó en %s/key (solo la lees tú).\n' "$CONFIG_DIR" >&2
      fi ;;
    file) printf '%s' "$key" | save_file ;;
    *) die "FEROZ_KEY_STORE no válido: usa auto, keychain, dpapi, secret-tool o file." 1 ;;
  esac
}

read_key() { # url → clave por stdout (solo para uso interno)
  local url="$1"
  case "$(store_kind)" in
    keychain) security find-generic-password -s "$SERVICE" -a "$url" -w 2>/dev/null ;;
    dpapi) powershell.exe -NoProfile -NonInteractive -Command "$PS_READ" 2>/dev/null | tr -d '\r\n' ;;
    secret-tool) secret-tool lookup service "$SERVICE" url "$url" 2>/dev/null || { [ -f "$CONFIG_DIR/key" ] && cat "$CONFIG_DIR/key"; } ;;
    file) [ -f "$CONFIG_DIR/key" ] && cat "$CONFIG_DIR/key" ;;
  esac
  return 0
}

delete_key() {
  local url="$1"
  case "$(store_kind)" in
    keychain) security delete-generic-password -s "$SERVICE" -a "$url" >/dev/null 2>&1 ;;
    dpapi) powershell.exe -NoProfile -NonInteractive -Command "$PS_DELETE" >/dev/null 2>&1 ;;
    secret-tool) secret-tool clear service "$SERVICE" url "$url" >/dev/null 2>&1; rm -f "$CONFIG_DIR/key" ;;
    file) rm -f "$CONFIG_DIR/key" ;;
  esac
  return 0
}

# --- Rutas de archivos: en Windows (Git Bash) acepta C:\Users\José\foto.jpg ------------------------------
local_path() {
  local p="$1"
  if command -v cygpath >/dev/null 2>&1 && [[ "$p" == *\\* || "$p" =~ ^[A-Za-z]: ]]; then p="$(cygpath -u "$p")"; fi
  printf '%s' "$p"
}
curl_path() { # forma que entiende curl en Windows (C:/…); igual en macOS y Linux
  if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi
}

# --- Petición ----------------------------------------------------------------------------------------
# request URL KEY MÉTODO RUTA [args de curl…] → imprime el cuerpo; sale con 1, 2 o 4 si algo falla.
request() {
  local url="$1" key="$2" method="$3" path="$4"
  shift 4
  local tmp out status type
  tmp="$(mktemp)"
  out="$(printf 'Authorization: Bearer %s\nX-Feroz-Client: 1\n' "$key" |
    curl -q -sS -g -X "$method" -H @- "$@" -o "$tmp" -w '%{http_code} %{content_type}' "$url$path")" || {
    rm -f "$tmp"
    die "No pudimos conectar con $url. Revisa tu conexión y la URL (feroz.sh login --url …)." 4
  }
  status="${out%% *}"
  type="${out#* }"
  case "$type" in
    application/json*) ;;
    *) rm -f "$tmp"; die "$NOT_FEROZ" 2 ;;
  esac
  if [ "$status" -ge 400 ]; then
    cat "$tmp" >&2; printf '\n' >&2
    rm -f "$tmp"
    exit 1
  fi
  cat "$tmp"; printf '\n'
  rm -f "$tmp"
}

credentials() { # → define URL y KEY o sale con 3
  URL="$(saved_url)"
  [ -n "$URL" ] || die "$NO_KEY" 3
  KEY="$(read_key "$URL")"
  [ -n "$KEY" ] || die "$NO_KEY" 3
}

# --- Subcomandos --------------------------------------------------------------------------------------
cmd_login() {
  local url="" key="" body email
  while [ $# -gt 0 ]; do
    case "$1" in
      --url) url="${2:-}"; shift 2 || shift ;;
      --url=*) url="${1#--url=}"; shift ;;
      *) die "Opción desconocida: $1. Uso: feroz.sh login [--url https://…]" 1 ;;
    esac
  done
  [ -n "$url" ] || url="$(saved_url)"
  if [ -z "$url" ] && [ -t 0 ]; then read -r -p "URL de Feroz (https://…): " url; fi
  url="$(printf '%s' "$url" | tr -d " \t\r\n\"'")"
  url="${url%/}"
  [ -n "$url" ] || die "Falta la URL de Feroz. Corre feroz.sh login --url https://… (viene en la instrucción de Mi cuenta)." 1
  case "$url" in http://*|https://*) ;; *) url="https://$url" ;; esac

  if [ -t 0 ]; then
    read -r -s -p "Pega tu clave de Feroz y pulsa Enter: " key; printf '\n' >&2
  else
    key="$(cat)"
    if [ -z "$(printf '%s' "$key" | tr -d " \t\r\n")" ] && { : </dev/tty; } 2>/dev/null; then
      read -r -s -p "Pega tu clave de Feroz y pulsa Enter: " key </dev/tty; printf '\n' >&2
    fi
  fi
  # Quita espacios, saltos de línea y comillas que se cuelan al copiar y pegar.
  key="$(printf '%s' "$key" | tr -d " \t\r\n\"'\`")"
  [ -n "$key" ] || die "No llegó ninguna clave. Cópiala de Mi cuenta › Conectar con Claude Code." 1
  case "$key" in feroz_*) ;; *) die "Eso no parece una clave de Feroz: debe empezar por feroz_. Cópiala de Mi cuenta › Conectar con Claude Code." 1 ;; esac

  body="$(request "$url" "$key" GET /api/claude/me)" || exit $?
  mkdir -p "$CONFIG_DIR" && printf '%s\n' "$url" > "$CONFIG_DIR/url"
  printf '%s' "$key" | save_key "$url" || die "No pudimos guardar la clave en el llavero de este computador." 1
  email="$(printf '%s' "$body" | sed -n 's/.*"email"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  printf 'Conectado como %s.\n' "${email:-tu cuenta}"
  if [ "$(store_kind)" = "file" ] && [ "$(uname -s)" = "Linux" ]; then
    printf 'La clave quedó en %s/key (solo la lees tú). Para usar el llavero del sistema: sudo apt install libsecret-tools y vuelve a correr login.\n' "$CONFIG_DIR" >&2
  fi
}

cmd_logout() {
  local url
  url="$(saved_url)"
  [ -n "$url" ] && delete_key "$url"
  printf 'Clave borrada de este computador.\n'
}

cmd_api() {
  [ $# -ge 2 ] || die "Uso: feroz.sh api MÉTODO RUTA [@archivo.json]" 1
  local method path file
  method="$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')"
  path="$2"
  credentials
  if [ $# -ge 3 ]; then
    case "$3" in @*) ;; *) die "El cuerpo va como @archivo.json." 1 ;; esac
    file="$(local_path "${3#@}")"
    [ -f "$file" ] || die "No encontramos el archivo $file." 1
    request "$URL" "$KEY" "$method" "$path" -H 'Content-Type: application/json' --data-binary "@$(curl_path "$file")"
  else
    request "$URL" "$KEY" "$method" "$path"
  fi
}

cmd_upload() {
  [ $# -eq 2 ] || die "Uso: feroz.sh upload RUTA-API FOTO" 1
  local path="$1" photo
  photo="$(local_path "$2")"
  [ -f "$photo" ] || die "No encontramos la foto $2. Revisa la ruta." 1
  credentials
  request "$URL" "$KEY" POST "$path" -F "file=@\"$(curl_path "$photo")\""
}

case "${1:-}" in
  login) shift; cmd_login "$@" ;;
  logout) shift; cmd_logout ;;
  api) shift; cmd_api "$@" ;;
  upload) shift; cmd_upload "$@" ;;
  *) die "Uso: feroz.sh login [--url URL] | logout | api MÉTODO RUTA [@archivo.json] | upload RUTA-API FOTO" 1 ;;
esac
