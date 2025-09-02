#!/bin/bash

# Глобальные переменные для build системы
# Загружается из всех скриптов через: source "globals.sh"

# Базовые пути

# Определяем директорию build относительно этого файла
export BUILD_DIR="${BUILD_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Остальные пути строятся относительно BUILD_DIR
export TOOLS_DIR="${TOOLS_DIR:-$(dirname "$BUILD_DIR")}"
export PROJECT_ROOT="${PROJECT_ROOT:-$(dirname "$TOOLS_DIR")}"
export APP_DIR="${APP_DIR:-$PROJECT_ROOT/app}"

# Директории конфигурации и окружения
export BUILD_ENV_DIR="${BUILD_ENV_DIR:-$BUILD_DIR/../build_env}"
export BUILD_CONFIG_PATH="${BUILD_CONFIG_PATH:-$BUILD_ENV_DIR/build.env}"

# Файлы проекта
export PUBSPEC_PATH="${PUBSPEC_PATH:-$APP_DIR/pubspec.yaml}"
export XCODE_PROJECT_PATH="${XCODE_PROJECT_PATH:-$APP_DIR/ios/Runner.xcodeproj/project.pbxproj}"

# Пути к скриптам
export IOS_VERSION_SCRIPT="${IOS_VERSION_SCRIPT:-$BUILD_DIR/sync-xcode-version.sh}"
export IOS_UPLOAD_SCRIPT="${IOS_UPLOAD_SCRIPT:-$BUILD_DIR/upload-ios.sh}"
export ANDROID_UPLOAD_SCRIPT="${ANDROID_UPLOAD_SCRIPT:-$BUILD_DIR/upload-android.sh}"
export INCREMENT_BUILD_SCRIPT="${INCREMENT_BUILD_SCRIPT:-$BUILD_DIR/increment-build-number.sh}"

# Build артефакты
export IPA_DIR="${IPA_DIR:-$APP_DIR/build/ios/ipa}"

# Android директории для поиска (список через пробел)
export ANDROID_SEARCH_DIRS="${ANDROID_SEARCH_DIRS:-$APP_DIR/build/app/outputs}"

# Конкретные поддиректории для разных типов билдов (через пробел)
export ANDROID_AAB_SUBDIRS="${ANDROID_AAB_SUBDIRS:-bundle apk}"
export ANDROID_APK_SUBDIRS="${ANDROID_APK_SUBDIRS:-flutter-apk apk}"

# Настройки
export DEFAULT_USE_APK="${DEFAULT_USE_APK:-false}"  # false = AAB, true = APK
export BUILD_SCRIPT_VERSION="${BUILD_SCRIPT_VERSION:-v5.1.0}"

# Цвета для вывода
export RED="${RED:-\033[0;31m}"
export GREEN="${GREEN:-\033[0;32m}"
export YELLOW="${YELLOW:-\033[1;33m}"
export BLUE="${BLUE:-\033[0;34m}"
export PURPLE="${PURPLE:-\033[0;35m}"
export CYAN="${CYAN:-\033[0;36m}"
export WHITE="${WHITE:-\033[1;37m}"
export GRAY="${GRAY:-\033[0;90m}"
export NC="${NC:-\033[0m}"

# Функции логирования
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
log_command() { echo -e "${CYAN}[COMMAND]${NC} $1"; }

# Экспортируем функции для использования в других скриптах
export -f log_info log_success log_warning log_error log_step log_command 