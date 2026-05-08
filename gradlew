#!/usr/bin/env sh
# Kava Launcher - Self-bootstrapping gradlew for AiDE / Android
# Automatically downloads gradle-wrapper.jar if missing

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JAR="$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.jar"

# Download wrapper jar if missing or too small to be valid
if [ ! -f "$JAR" ] || [ "$(wc -c < "$JAR")" -lt 10000 ]; then
    echo ">>> Downloading gradle-wrapper.jar..."
    mkdir -p "$SCRIPT_DIR/gradle/wrapper"
    DOWNLOADED=0
    for URL in \
        "https://github.com/gradle/gradle/raw/v6.5.0/gradle/wrapper/gradle-wrapper.jar" \
        "https://raw.githubusercontent.com/gradle/gradle/v6.5.0/gradle/wrapper/gradle-wrapper.jar"; do
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "$URL" -o "$JAR" && DOWNLOADED=1 && break
        elif command -v wget >/dev/null 2>&1; then
            wget -q "$URL" -O "$JAR" && DOWNLOADED=1 && break
        fi
    done
    if [ "$DOWNLOADED" -eq 0 ]; then
        echo "ERROR: Could not download gradle-wrapper.jar"
        echo "Please run:"
        echo "  curl -L https://github.com/gradle/gradle/raw/v6.5.0/gradle/wrapper/gradle-wrapper.jar -o gradle/wrapper/gradle-wrapper.jar"
        exit 1
    fi
    echo ">>> Downloaded gradle-wrapper.jar successfully"
fi

# Find Java
if [ -n "$JAVA_HOME" ]; then
    JAVACMD="$JAVA_HOME/bin/java"
else
    JAVACMD="java"
fi

APP_HOME="$SCRIPT_DIR"
CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

exec "$JAVACMD" -Xmx64m -Xms64m $JAVA_OPTS $GRADLE_OPTS \
    "-Dorg.gradle.appname=gradlew" \
    -classpath "$CLASSPATH" \
    org.gradle.wrapper.GradleWrapperMain "$@"
