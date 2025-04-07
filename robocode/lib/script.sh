#!/bin/bash

# Ruta al archivo robocode.jar
ROBOCODE_JAR_PATH="robocode-1.9.5.5-setup.jar"
VERSION="1.9.5.5"

echo "🔍 Verificando existencia de $ROBOCODE_JAR_PATH..."

if [[ ! -f "$ROBOCODE_JAR_PATH" ]]; then
  echo "❌ No se encontró robocode.jar en la ruta $ROBOCODE_JAR_PATH"
  echo "➡️ Descarga e instala Robocode desde:"
  echo "   https://sourceforge.net/projects/robocode/files/robocode/$VERSION/"
  echo "   y copia robocode.jar a ./lib/"
  exit 1
fi

echo "📦 Instalando robocode.jar en el repositorio local de Maven..."

mvn install:install-file \
  -Dfile="$ROBOCODE_JAR_PATH" \
  -DgroupId=net.sf.robocode \
  -DartifactId=robocode-full \
  -Dversion="$VERSION" \
  -Dpackaging=jar

if [[ $? -eq 0 ]]; then
  echo "✅ robocode.jar instalado correctamente en Maven"
else
  echo "❌ Ocurrió un error durante la instalación"
fi

