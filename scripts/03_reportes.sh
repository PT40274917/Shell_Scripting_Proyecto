

#!/bin/bash

# MODULO 03: REPORTES Y PROCESAMIENTO DE TEXTO
# Herramientas: AWK y SED

BASE="$HOME/Shell_Scripting_Proyecto"
REPORTES="$BASE/reportes"
ARCHIVOS="$BASE/archivos"
LOG="$REPORTES/reportes.log"

mkdir -p "$REPORTES" "$ARCHIVOS"

VERDE='\033[0;32m'
ROJO='\033[0;31m'
AZUL='\033[0;36m'
RESET='\033[0m'

registrar() {
    echo "$(date '+%F %T') | $1" >> "$LOG"
}

reporte_awk() {
    salida="$REPORTES/reporte_awk_$(date +%Y%m%d_%H%M%S)_$$.txt"

    if df -P | awk '
    NR == 1 {
        print "REPORTE DE ALMACENAMIENTO"
        print "================================"
        next
    }
    {
        printf "Dispositivo: %s\n", $1
        printf "Uso: %s\n", $5
        printf "Montaje: %s\n", $6
        print "--------------------------------"
    }' > "$salida"; then
        echo -e "${VERDE}Reporte generado correctamente.${RESET}"
        echo "$salida"
        registrar "AWK: $salida"
    else
        echo -e "${ROJO}Error al generar reporte.${RESET}"
    fi
}

reemplazar_sed() {
    read -r -p "Archivo: " nombre

    if [[ ! "$nombre" =~ ^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)?$ ]]; then
        echo "Nombre de archivo invalido."
        return
    fi

    ruta="$ARCHIVOS/$nombre"

    if [ ! -f "$ruta" ] || [ -L "$ruta" ]; then
        echo -e "${ROJO}Archivo inexistente o no permitido.${RESET}"
        return
    fi

    read -r -p "Texto a buscar: " buscar
    read -r -p "Texto nuevo: " nuevo

    if [ -z "$buscar" ] || [ -z "$nuevo" ]; then
        echo "Los textos no pueden estar vacios."
        return
    fi

    buscar_esc=$(printf '%s' "$buscar" |
        sed 's/[][\\.^$*\/]/\\&/g')
    nuevo_esc=$(printf '%s' "$nuevo" |
        sed 's/[&\/\\]/\\&/g')

    if sed -i.bak "s/$buscar_esc/$nuevo_esc/g" "$ruta"; then
        echo -e "${VERDE}Reemplazo realizado.${RESET}"
        echo "Respaldo: $ruta.bak"
        registrar "SED: $nombre"
    else
        echo -e "${ROJO}Error al reemplazar texto.${RESET}"
    fi
}

while true; do
    echo ""
    echo -e "${AZUL}===================================${RESET}"
    echo "    MODULO 03 - REPORTES Y TEXTO"
    echo -e "${AZUL}===================================${RESET}"
    echo "1. Generar reporte con AWK"
    echo "2. Reemplazar texto con SED"
    echo "0. Salir"

    read -r -p "Seleccione una opcion: " opcion

    case "$opcion" in
        1) reporte_awk ;;
        2) reemplazar_sed ;;
        0) exit 0 ;;
        *) echo -e "${ROJO}Opcion incorrecta.${RESET}" ;;
    esac
done

