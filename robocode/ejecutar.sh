#!/bin/bash

# Configuración
ROBOCODE_HOME="$HOME/robocode"
BOTS_PACKAGE="com.robocode.bot"
MAIN_CLASS="com.robocode.App"
SETUP_JAR="./lib/robocode-1.9.5.5-setup.jar"
INSTALLED_JAR="$ROBOCODE_HOME/libs/robocode.jar"
ROBOCODE_JAR_PATH="$INSTALLED_JAR"
VERSION="1.9.5.5"
DOWNLOAD_URL="https://sourceforge.net/projects/robocode/files/robocode/${VERSION}/robocode-${VERSION}-setup.jar/download"
DEFAULT_OPPONENT="sample.SpinBot"
JAR_BOTS="bots.jar"

export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"

# Colores
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }

# Argumentos
SELECTED_BOTS=()
for arg in "$@"; do
    case $arg in
        --bot=*) SELECTED_BOTS+=("${arg#*=}");;
        --listar) LISTAR=true;;
        --help)
            echo -e "${BLUE}Uso:${NC} ./ejecutar.sh [--bot=NOMBRE]..."
            echo "       --bot=NombreBot     Añade un bot al combate (se puede usar varias veces)"
            echo "       --listar            Muestra los bots disponibles"
            echo "       --help              Muestra esta ayuda"
            exit 0
            ;;
    esac
done

download_robocode() {
    info "Descargando Robocode $VERSION..."
    mkdir -p ./lib/
    wget -O "$SETUP_JAR" "$DOWNLOAD_URL" || error "Fallo descarga con wget"
    success "Robocode descargado correctamente"
}

run_installer_if_needed() {
    if [ ! -f "$INSTALLED_JAR" ]; then
        info "Ejecutando instalador de Robocode..."
        java -jar "$SETUP_JAR" || error "No se pudo ejecutar el instalador"
        [ ! -f "$INSTALLED_JAR" ] && error "No se encuentra robocode.jar tras la instalación. Instálalo manualmente en $ROBOCODE_HOME"
    fi
}

find_robots() {
    local bots_dir="target/classes/${BOTS_PACKAGE//./\/}"
    [ ! -d "$bots_dir" ] && error "No se encontró el directorio de bots: $bots_dir"

    mapfile -t robot_files < <(find "$bots_dir" -name '*.class' -type f ! -name '*Estrategia*' ! -name '*Strategy*')
    [ ${#robot_files[@]} -eq 0 ] && error "No se encontraron bots"

    local bots=()
    for file in "${robot_files[@]}"; do
        local class_name="${file#target/classes/}"
        class_name="${class_name%.class}"
        class_name="${class_name//\//.}"
        bots+=("$class_name")
    done
    printf "%s\n" "${bots[@]}"
}

info "Verificando versión de Java..."
JAVA_VERSION=$(java -version 2>&1 | awk -F[\"\.] '/version/ {print $2}')
[ "$JAVA_VERSION" -gt 11 ] && warning "Java $JAVA_VERSION detectado. Se recomienda Java 11"

info "Verificando Robocode..."
[ ! -f "$SETUP_JAR" ] && download_robocode
run_installer_if_needed

info "Instalando robocode.jar real en Maven..."
mvn install:install-file -Dfile="$ROBOCODE_JAR_PATH" \
    -DgroupId=net.sf.robocode -DartifactId=robocode-full -Dversion="$VERSION" \
    -Dpackaging=jar -DgeneratePom=true || error "Fallo al instalar robocode.jar"
success "robocode.jar instalado"

info "Compilando proyecto..."
mvn clean package || error "Falló la compilación"

info "Buscando bots disponibles..."
mapfile -t robot_classes < <(find_robots)

info "Empaquetando bots en ${JAR_BOTS}..."
jar cf "$JAR_BOTS" -C target/classes . || error "No se pudo crear $JAR_BOTS"

info "Copiando ${JAR_BOTS} a $ROBOCODE_HOME/robots/..."
mkdir -p "$ROBOCODE_HOME/robots" || error "No se pudo crear el directorio de robots"
cp "$JAR_BOTS" "$ROBOCODE_HOME/robots/" || error "No se pudo copiar bots.jar"

[ "$LISTAR" = true ] && {
    echo -e "${BLUE}Bots disponibles:${NC}"
    printf " - %s\n" "${robot_classes[@]}"
    exit 0
}

GUI_MODE=true
[ -z "$DISPLAY" ] && warning "Modo headless" && GUI_MODE=false

ROBOT_CLASSPATH="$ROBOCODE_JAR_PATH:target/classes:target/robocode-practica-1.0-SNAPSHOT.jar"

# Selección de bots
BOTS_ELEGIDOS=()
if [ ${#SELECTED_BOTS[@]} -gt 0 ]; then
    info "Seleccionando bots: ${SELECTED_BOTS[*]}"
    for seleccionado in "${SELECTED_BOTS[@]}"; do
        encontrado=false
        for bot in "${robot_classes[@]}"; do
            if [[ "$bot" == *"$seleccionado" ]]; then
                BOTS_ELEGIDOS+=("$bot")
                encontrado=true
                break
            fi
        done
        [ "$encontrado" = false ] && warning "No se encontró: $seleccionado"
    done
else
    BOTS_ELEGIDOS=("${robot_classes[@]}")
fi

# Asegurar al menos dos bots
if [ ${#BOTS_ELEGIDOS[@]} -lt 2 ]; then
    BOTS_ELEGIDOS+=("$DEFAULT_OPPONENT")
fi
[ ${#BOTS_ELEGIDOS[@]} -lt 2 ] && error "Se necesitan al menos 2 bots para combatir"

info "Iniciando batalla con: ${BOTS_ELEGIDOS[*]}"
JAVA_OPTS="-Drobocode.console.visible=$GUI_MODE"
[ "$GUI_MODE" = false ] && JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true"

java $JAVA_OPTS -cp "$ROBOT_CLASSPATH" "$MAIN_CLASS" "${BOTS_ELEGIDOS[@]}" || error "Error ejecutando batalla"

success "Simulación finalizada"

