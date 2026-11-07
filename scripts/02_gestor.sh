
#!/bin/bash

# PROYECTO: SHELL SCRIPTING
# Script 02: Gestor de archivos Linux

BASE="$HOME/Shell_Scripting_Proyecto"
ARCHIVOS="$BASE/archivos"
TEMPORALES="$BASE/temporales"
LOG="$BASE/reportes/gestor.log"

mkdir -p "$ARCHIVOS" "$TEMPORALES" "$BASE/reportes"

# Colores
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AZUL='\033[0;36m'
AMARILLO='\033[1;33m'
RESET='\033[0m'

# Registrar operaciones
registrar() {
    echo "$(date '+%F %T') | $1" >> "$LOG"
}

# Validar nombres simples y seguros
validar_nombre() {
    [[ "$1" =~ ^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)?$ ]]
}

# Crear archivo
crear_archivo() {
    read -r -p "Nombre del archivo: " nombre

    if ! validar_nombre "$nombre"; then
        echo -e "${ROJO}Nombre no valido.${RESET}"
    elif [ -e "$ARCHIVOS/$nombre" ]; then
        echo -e "${AMARILLO}El archivo ya existe.${RESET}"
    else
        touch "$ARCHIVOS/$nombre"
        echo -e "${VERDE}Archivo creado.${RESET}"
        registrar "CREAR: $nombre"
    fi
}

# Copiar archivo
copiar_archivo() {
    read -r -p "Archivo de origen: " origen
    read -r -p "Nombre de la copia: " destino

    if ! validar_nombre "$origen" ||
       ! validar_nombre "$destino"; then
        echo "Nombre no valido."
    elif [ ! -f "$ARCHIVOS/$origen" ]; then
        echo -e "${ROJO}El archivo no existe.${RESET}"
    elif [ -e "$ARCHIVOS/$destino" ]; then
        echo "El archivo destino ya existe."
    elif cp -- "$ARCHIVOS/$origen" "$ARCHIVOS/$destino"; then
        echo -e "${VERDE}Copia realizada.${RESET}"
        registrar "COPIAR: $origen -> $destino"
    else
        echo "ERROR: No se pudo copiar."
    fi
}

# Cambiar permisos
cambiar_permisos() {
    read -r -p "Archivo: " nombre
    read -r -p "Permisos (ejemplo 640): " permisos

    if ! validar_nombre "$nombre"; then
        echo "Nombre no valido."
    elif [ ! -f "$ARCHIVOS/$nombre" ]; then
        echo -e "${ROJO}El archivo no existe.${RESET}"
    elif [[ ! "$permisos" =~ ^[0-7]{3}$ ]]; then
        echo -e "${ROJO}Permisos incorrectos.${RESET}"
    elif chmod "$permisos" "$ARCHIVOS/$nombre"; then
        echo -e "${VERDE}Permisos actualizados.${RESET}"
        registrar "CHMOD: $nombre -> $permisos"
    else
        echo "ERROR: No se pudieron cambiar los permisos."
    fi
}

# Eliminar temporales anteriores a una fecha
limpiar_temporales() {
    read -r -p "Fecha limite (AAAA-MM-DD): " fecha

    if [[ ! "$fecha" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] ||
       [ "$(date -d "$fecha" +%F 2>/dev/null)" != "$fecha" ]; then
        echo -e "${ROJO}Fecha incorrecta.${RESET}"
        return
    fi

    limite=$(date -d "$fecha 00:00:00" +%s)

    echo -e "${AZUL}Archivos anteriores a $fecha:${RESET}"

    encontrados=0

    for archivo in "$TEMPORALES"/*.tmp; do
        [ -f "$archivo" ] || continue
        marca=$(stat -c %Y "$archivo") || continue

        if [ "$marca" -lt "$limite" ]; then
            echo " - $(basename "$archivo")"
            encontrados=$((encontrados + 1))
        fi
    done

    if [ "$encontrados" -eq 0 ]; then
        echo "No hay archivos para eliminar."
        return
    fi

    read -r -p "Confirmar eliminacion (SI/NO): " respuesta

    if [ "$respuesta" != "SI" ]; then
        echo "Operacion cancelada."
        return
    fi

    for archivo in "$TEMPORALES"/*.tmp; do
        [ -f "$archivo" ] || continue
        marca=$(stat -c %Y "$archivo") || continue

        if [ "$marca" -lt "$limite" ]; then
            if rm -- "$archivo"; then
                registrar "ELIMINAR: $(basename "$archivo")"
                echo "Eliminado: $(basename "$archivo")"
            else
                echo "ERROR: No se pudo eliminar $archivo"
            fi
        fi
    done
}

# Listar archivos
listar_archivos() {
    echo -e "${AZUL}===== ARCHIVOS =====${RESET}"
    ls -lh "$ARCHIVOS"

    echo -e "${AZUL}===== TEMPORALES =====${RESET}"
    ls -lh "$TEMPORALES"
}

# Menu principal
while true; do
    echo ""
    echo -e "${AZUL}====================================${RESET}"
    echo "       GESTOR DE ARCHIVOS LINUX"
    echo -e "${AZUL}====================================${RESET}"
    echo "1. Crear archivo"
    echo "2. Copiar archivo"
    echo "3. Cambiar permisos"
    echo "4. Limpiar archivos temporales"
    echo "5. Listar archivos"
    echo "0. Salir"
    echo "===================================="

    read -r -p "Seleccione una opcion: " opcion

    case "$opcion" in
        1) crear_archivo ;;
        2) copiar_archivo ;;
        3) cambiar_permisos ;;
        4) limpiar_temporales ;;
        5) listar_archivos ;;
        0)
            echo "Finalizando gestor..."
            exit 0
            ;;
        *)
            echo -e "${ROJO}Opcion incorrecta.${RESET}"
            ;;
    esac
done
