#!/bin/bash

# Configuración
ROBOCODE_HOME="$HOME/robocode"
BOTS_PACKAGE="com/robocode/bot"
MAIN_CLASS="com.robocode.App"
ROBOCODE_JAR_PATH="./lib/robocode-1.9.5.5-setup.jar"
VERSION="1.9.5.5"
DOWNLOAD_URL="https://sourceforge.net/projects/robocode/files/robocode/${VERSION}/robocode-${VERSION}-setup.jar/download"

# Configuración de Java
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para encontrar todos los bots en el proyecto
find_robots() {
    info "Buscando bots en el proyecto..."
    local bots_dir="target/classes/${BOTS_PACKAGE}"
    
    if [ ! -d "$bots_dir" ]; then
        error "No se encontró el directorio de bots: $bots_dir"
    fi

    # Buscar todos los archivos .class que extiendan de Robot
    local robot_files=($(find "$bots_dir" -name '*.class' -type f))
    
    if [ ${#robot_files[@]} -eq 0 ]; then
        error "No se encontraron bots en $bots_dir"
    fi

    # Extraer nombres de clases (removiendo .class y reemplazando / con .)
    local bots=()
    for file in "${robot_files[@]}"; do
        local class_name=$(echo "$file" | sed "s|target/classes/||; s|\.class$||; s|/|.|g")
        bots+=("$class_name")
    done

    echo "${bots[@]}"
}

# Función para descargar Robocode si no existe
download_robocode() {
    info "Descargando Robocode ${VERSION}..."
    mkdir -p ./lib/
    
    if command -v wget &> /dev/null; then
        wget -O "$ROBOCODE_JAR_PATH" "$DOWNLOAD_URL" || {
            error "Falló la descarga con wget. Intenta descargarlo manualmente de:\n   ${DOWNLOAD_URL}\ny colócalo en ./lib/"
        }
    elif command -v curl &> /dev/null; then
        curl -L -o "$ROBOCODE_JAR_PATH" "$DOWNLOAD_URL" || {
            error "Falló la descarga con curl. Intenta descargarlo manualmente de:\n   ${DOWNLOAD_URL}\ny colócalo en ./lib/"
        }
    else
        error "No se encontró wget ni curl. Instala uno de ellos o descarga manualmente Robocode de:\n   ${DOWNLOAD_URL}\ny colócalo en ./lib/"
    fi
    
    success "Robocode descargado correctamente en $ROBOCODE_JAR_PATH"
}

# Función para mostrar mensajes de error
error() {
    echo -e "${RED}❌ Error: $1${NC}"
    exit 1
}

# Función para mostrar mensajes informativos
info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Función para mostrar mensajes de éxito
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para mostrar advertencias
warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# 🧪 Verificar versión de Java
info "Verificando versión de Java..."
JAVA_VERSION=$(java -version 2>&1 | awk -F[\"\.] '/version/ {print $2}')
if [ "$JAVA_VERSION" -gt 11 ]; then
    warning "Java $JAVA_VERSION detectado. Robocode funciona mejor con Java 11."
    info "Se usará Java 11 configurado en JAVA_HOME"
fi

# 📦 Verificar existencia de robocode.jar o descargarlo
info "Verificando existencia de $ROBOCODE_JAR_PATH..."
if [[ ! -f "$ROBOCODE_JAR_PATH" ]]; then
    warning "No se encontró robocode.jar en $ROBOCODE_JAR_PATH"
    download_robocode
fi

# 📦 Instalar robocode.jar en repositorio local de Maven
info "Instalando robocode.jar en el repositorio local de Maven..."
mvn install:install-file \
    -Dfile="$ROBOCODE_JAR_PATH" \
    -DgroupId=net.sf.robocode \
    -DartifactId=robocode-full \
    -Dversion="$VERSION" \
    -Dpackaging=jar \
    -DgeneratePom=true || error "Fallo al instalar robocode.jar en Maven"

success "robocode.jar instalado correctamente en Maven"

# 🛠️ Compilar proyecto
info "Compilando proyecto..."
mvn clean package || error "Fallo al compilar el proyecto"

# 📁 Verificar y crear estructura de directorios
info "Preparando entorno Robocode..."
mkdir -p "$ROBOCODE_HOME/robots/$BOTS_PACKAGE" || error "No se pudo crear directorio para los bots"

# 📁 Copiar bots al entorno de Robocode
info "Copiando bots al entorno Robocode..."
robot_classes=($(find_robots))

for class_file in "${robot_classes[@]}"; do
    # Convertir nombre de clase a ruta de archivo
    file_path="target/classes/$(echo "$class_file" | sed 's|\.|/|g').class"
    
    if [ -f "$file_path" ]; then
        dest_dir="$ROBOCODE_HOME/robots/$(dirname "$(echo "$class_file" | sed 's|\.|/|g')")"
        mkdir -p "$dest_dir"
        cp "$file_path" "$dest_dir/" && success "Copiado: $class_file" || warning "Error copiando: $class_file"
    else
        warning "No se encontró el archivo para: $class_file"
    fi
done

# 🖥️ Determinar modo de ejecución
if [ -z "$DISPLAY" ]; then
    warning "No se detectó entorno gráfico (DISPLAY no está configurado)"
    MODE_GUI=false
else
    info "Entorno gráfico detectado"
    MODE_GUI=true
fi

# ⚙️ Configurar opciones Java
JAVA_OPTS="-Dawt.useSystemAAFontSettings=lcd -Dswing.aatext=true"
if [ "$MODE_GUI" = false ]; then
    JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true"
    warning "Ejecutando en modo sin GUI (headless)"
else
    info "Ejecutando en modo gráfico"
fi

# 🚀 Ejecutar simulación con todos los bots encontrados
if [ ${#robot_classes[@]} -gt 0 ]; then
    info "Iniciando simulación Robocode con los bots: ${robot_classes[*]}"
    java $JAVA_OPTS \
        -cp "$ROBOCODE_HOME/libs/*:target/classes:target/robocode-practica-1.0-SNAPSHOT.jar" \
        "$MAIN_CLASS" "${robot_classes[@]}" || error "Error al ejecutar la simulación"
else
    error "No se encontraron bots para ejecutar"
fi

success "Simulación completada"
