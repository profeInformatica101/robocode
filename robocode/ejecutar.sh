#!/bin/bash

cd "$(dirname "$0")"

ROBOCODE_HOME="$HOME/robocode"
BOT_PACKAGE_PATH="com/robocode/bot"
BOT_CLASS="MiPrimerBot.class"
MAIN_CLASS="com.robocode.App"

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "🔧 Compilando proyecto..."
mvn clean package || { echo "❌ Fallo al compilar"; exit 1; }

echo "📁 Copiando $BOT_CLASS al entorno Robocode..."
mkdir -p "$ROBOCODE_HOME/robots/$BOT_PACKAGE_PATH"
cp "target/classes/$BOT_PACKAGE_PATH/$BOT_CLASS" "$ROBOCODE_HOME/robots/$BOT_PACKAGE_PATH/" || { echo "❌ Error copiando bot"; exit 1; }

echo -n "🖥️ Ejecutando en modo "
if [ -z "$DISPLAY" ]; then
  echo "sin GUI (headless)"
  MODE_GUI=false
else
  echo "gráfico"
  MODE_GUI=true
fi

JAVA_OPTS="-Dawt.useSystemAAFontSettings=lcd -Dswing.aatext=true"
if [ "$MODE_GUI" = false ]; then
  JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true"
fi

java $JAVA_OPTS -cp "$ROBOCODE_HOME/libs/*:target/classes:target/robocode-practica-1.0-SNAPSHOT.jar" "$MAIN_CLASS"

