
#!/bin/bash

# MODULO 04: ADMINISTRACION DE CRON

BASE="$HOME/Shell_Scripting_Proyecto"
ENTORNO="$BASE/scripts/01_entorno.sh"
LOG="$BASE/reportes/cron.log"
MARCA="SHELL_SCRIPTING_MONITOREO"

mkdir -p "$BASE/reportes"

VERDE='\033[0;32m'
ROJO='\033[0;31m'
AZUL='\033[0;36m'
RESET='\033[0m'

registrar() {
    echo "$(date '+%F %T') | $1" >> "$LOG"
}

leer_cron() {
    crontab -l 2>/dev/null || true
}

# Reconocer solo tareas del proyecto
es_tarea_proyecto() {
    grep -F "$ENTORNO" | grep -F "$MARCA"
}

programar() {
    if [ ! -f "$ENTORNO" ]; then
        echo "ERROR: No existe el script de monitoreo."
        return
    fi

    echo ""
    echo "1. Cada 5 minutos"
    echo "2. Cada 15 minutos"
    echo "3. Cada 30 minutos"
    echo "4. Cada hora"
    echo "5. Diario a hora personalizada"
    echo "6. Lunes a viernes a hora personalizada"
    echo "0. Cancelar"

    read -r -p "Frecuencia: " opcion

    case "$opcion" in
        1) expresion="*/5 * * * *" ;;
        2) expresion="*/15 * * * *" ;;
        3) expresion="*/30 * * * *" ;;
        4) expresion="0 * * * *" ;;
        5|6)
            read -r -p "Hora (0-23): " hora
            read -r -p "Minuto (0-59): " minuto

            if ! [[ "$hora" =~ ^[0-9]{1,2}$ ]] ||
               ! [[ "$minuto" =~ ^[0-9]{1,2}$ ]] ||
               [ "$((10#$hora))" -gt 23 ] ||
               [ "$((10#$minuto))" -gt 59 ]; then
                echo -e "${ROJO}Horario invalido.${RESET}"
                return
            fi

            hora=$((10#$hora))
            minuto=$((10#$minuto))

            if [ "$opcion" = "5" ]; then
                expresion="$minuto $hora * * *"
            else
                expresion="$minuto $hora * * 1-5"
            fi
            ;;
        0) return ;;
        *) echo "Opcion incorrecta."; return ;;
    esac

    echo "Programacion: $expresion"
    read -r -p "Confirmar (SI/NO): " confirmar

    [ "$confirmar" = "SI" ] || {
        echo "Operacion cancelada."
        return
    }

    # Conservar otras tareas de CRON
    actual=$(leer_cron)
    limpio=$(printf '%s\n' "$actual" |
        grep -vF "$ENTORNO" || true)

    tarea="$expresion /bin/bash $ENTORNO >/dev/null 2>&1 # $MARCA"

    if {
        printf '%s\n' "$limpio"
        printf '%s\n' "$tarea"
    } | crontab -; then
        echo -e "${VERDE}Tarea programada.${RESET}"
        registrar "PROGRAMAR: $expresion"
    else
        echo -e "${ROJO}Error al programar.${RESET}"
    fi
}

ver_tareas() {
    echo -e "${AZUL}===== TAREAS CRON =====${RESET}"
    crontab -l 2>/dev/null ||
        echo "No hay tareas programadas."
}

eliminar_tarea() {
    actual=$(leer_cron)

    if ! printf '%s\n' "$actual" |
        es_tarea_proyecto >/dev/null; then
        echo "No existe tarea del proyecto."
        return
    fi

    read -r -p "Eliminar tarea (SI/NO): " confirmar

    [ "$confirmar" = "SI" ] || return

    limpio=$(printf '%s\n' "$actual" |
        grep -vF "$ENTORNO" || true)

    if printf '%s\n' "$limpio" | crontab -; then
        echo -e "${VERDE}Tarea eliminada.${RESET}"
        registrar "ELIMINAR: tarea de monitoreo"
    else
        echo -e "${ROJO}Error al eliminar.${RESET}"
    fi
}

while true; do
    echo ""
    echo -e "${AZUL}===================================${RESET}"
    echo "     MODULO 04 - GESTION CRON"
    echo -e "${AZUL}===================================${RESET}"
    echo "1. Programar monitoreo"
    echo "2. Ver tareas programadas"
    echo "3. Eliminar tarea del proyecto"
    echo "0. Salir"

    read -r -p "Seleccione una opcion: " opcion

    case "$opcion" in
        1) programar ;;
        2) ver_tareas ;;
        3) eliminar_tarea ;;
        0) exit 0 ;;
        *) echo -e "${ROJO}Opcion incorrecta.${RESET}" ;;
    esac
done
