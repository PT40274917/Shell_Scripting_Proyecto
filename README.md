
# Proyecto Shell Scripting

## Descripción
Sistema de automatización de tareas administrativas
para servidores Linux mediante Bash Scripting.

## Entorno de implementación
- Sistema operativo: Ubuntu Server 26.04 LTS
- Servidor de pruebas: srvvirtual01
- Lenguaje: Bash
- Herramientas: AWK, SED, CRON y Git

## Módulos

### 01 - Monitoreo del sistema
Archivo: scripts/01_entorno.sh

Funcionalidades:
- Consultar usuario y hostname.
- Mostrar versión de Ubuntu.
- Consultar memoria RAM y espacio en disco.
- Generar alertas por consumo de disco.
- Guardar reportes históricos.

Ejecución:
    ./scripts/01_entorno.sh

Parámetros: no requiere argumentos.
Umbral de alerta: 80%, configurable en el código.

### 02 - Gestor de archivos
Archivo: scripts/02_gestor.sh

Funcionalidades:
- Crear archivos.
- Copiar archivos.
- Modificar permisos.
- Eliminar archivos temporales según fecha.
- Registrar operaciones.

Ejecución:
    ./scripts/02_gestor.sh

Parámetros: menú interactivo.
Ejemplos de entrada:
- Nombre: prueba.txt
- Permisos: 640
- Fecha límite: 2026-10-20

### 03 - Reportes AWK y SED
Archivo: scripts/03_reportes.sh

Funcionalidades:
- Generar reportes de almacenamiento con AWK.
- Buscar y reemplazar texto con SED.
- Crear copias de seguridad .bak.

Ejecución:
    ./scripts/03_reportes.sh

Parámetros: menú interactivo.
Ejemplo: reemplazar Linux por Ubuntu.

### 04 - Automatización CRON
Archivo: scripts/04_cron.sh

Funcionalidades:
- Programar monitoreo automático.
- Configurar frecuencias y horarios.
- Consultar tareas CRON.
- Eliminar tareas del proyecto.

Ejecución:
    ./scripts/04_cron.sh

Parámetros: menú interactivo.
Ejemplo: seleccionar opción 1 y frecuencia
cada hora.

## Instalación y ejecución

Clonar el repositorio:

    git clone https://github.com/PT40274917/Shell_Scripting_Proyecto.git

Ingresar al proyecto:

    cd Shell_Scripting_Proyecto

Asignar permisos:

    chmod +x scripts/*.sh

Ejecutar los módulos:

    ./scripts/01_entorno.sh
    ./scripts/02_gestor.sh
    ./scripts/03_reportes.sh
    ./scripts/04_cron.sh

## Consideraciones
Los scripts utilizan la ruta:
$HOME/Shell_Scripting_Proyecto

Los directorios de trabajo y reportes se crean
automáticamente cuando corresponde.

Las operaciones de archivos se limitan a
directorios del laboratorio.

La ejecución de CRON requiere que el servicio
cron esté activo.

## Resultados
Se verificó la generación de reportes históricos,
el procesamiento de texto mediante AWK y SED,
y la ejecución automática de monitoreo con CRON.

## Seguridad
No se publican reportes internos, archivos
temporales ni registros operativos del servidor.
