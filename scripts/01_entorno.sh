
#!/bin/bash

# PROYECTO: SHELL SCRIPTING
# Script 01: Monitoreo y reportes del servidor Linux

set -o pipefail

BASE="$HOME/Shell_Scripting_Proyecto"
REPORTES="$BASE/reportes"
mkdir -p "$REPORTES"

# Colores para la terminal
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
AZUL='\033[0;36m'
RESET='\033[0m'

# Variables del sistema
USUARIO=$(whoami)
SERVIDOR=$(hostname)
SISTEMA=$(. /etc/os-release; echo "$PRETTY_NAME")
FECHA=$(date '+%Y-%m-%d %H:%M:%S')
MARCA=$(date '+%Y%m%d_%H%M%S')
UMBRAL=80

# Archivos de salida
REPORTE="$REPORTES/reporte_${MARCA}_$$.txt"
HISTORIAL="$REPORTES/historial.txt"

# Funcion para presentar el sistema
mostrar_sistema() {
    echo -e "${AZUL}"
    echo "=========================================="
    echo "      SISTEMA DE MONITOREO LINUX"
    echo "=========================================="
    echo -e "${RESET}"

    echo "Servidor : $SERVIDOR"
    echo "Usuario  : $USUARIO"
    echo "Sistema  : $SISTEMA"
    echo "Fecha    : $FECHA"
    echo ""
}

# Funcion para consultar memoria
mostrar_memoria() {
    echo -e "${AZUL}===== MEMORIA RAM =====${RESET}"
    free -h
    echo ""
}

# Funcion para evaluar almacenamiento
verificar_disco() {
    echo -e "${AZUL}===== ESPACIO EN DISCO =====${RESET}"
    df -h /
    echo ""

    USO=$(df -P / | awk 'NR==2 {
        gsub("%","",$5)
        print $5
    }')

    if ! [[ "$USO" =~ ^[0-9]+$ ]]; then
        echo "ERROR: No se pudo consultar el disco."
        return 1
    fi

    if [ "$USO" -ge "$UMBRAL" ]; then
        echo -e "${ROJO}[ALERTA] Disco al $USO%${RESET}"
    elif [ "$USO" -ge 60 ]; then
        echo -e "${AMARILLO}[AVISO] Disco al $USO%${RESET}"
    else
        echo -e "${VERDE}[OK] Disco al $USO%${RESET}"
    fi

    echo ""
}

# Funcion para mostrar resumen
mostrar_resumen() {
    echo -e "${AZUL}===== RESUMEN =====${RESET}"
    echo "Servidor evaluado: $SERVIDOR"
    echo "Umbral de alerta: $UMBRAL%"
    echo "Fecha de revision: $FECHA"
    echo "=========================================="
}

# Ejecutar funciones y guardar reporte
{
    mostrar_sistema
    mostrar_memoria
    verificar_disco
    mostrar_resumen
} | tee >(sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' > "$REPORTE")

ESTADO=${PIPESTATUS[0]}

if [ "$ESTADO" -ne 0 ]; then
    echo "ERROR: Fallo la generacion del reporte."
    exit 1
fi

# Registrar ejecucion en el historial
echo "$FECHA | $SERVIDOR | Reporte: $REPORTE" \
    >> "$HISTORIAL"

echo ""
echo -e "${VERDE}[OK] Reporte generado correctamente${RESET}"
echo "Archivo: $REPORTE"
echo "Historial: $HISTORIAL"
