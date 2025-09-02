#!/bin/bash

# Валидация параметров и зависимостей

# Загружаем глобальные переменные
source "$(dirname "${BASH_SOURCE[0]}")/globals.sh"

# Проверка зависимостей
check_dependencies() {
    log_step "Проверка зависимостей..."
    
    local missing_deps=()
    
    if ! command -v flutter &> /dev/null; then
        missing_deps+=("flutter")
    else
        # Получаем версию Flutter с обработкой ошибок
        local flutter_version
        if flutter_version=$(flutter --version 2>/dev/null | head -n1 | cut -d' ' -f2); then
            log_info "Flutter версия: $flutter_version"
        else
            log_warning "Не удалось получить версию Flutter, но команда найдена"
        fi
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Отсутствуют зависимости: ${missing_deps[*]}"
        echo
        echo "Для установки выполните:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "flutter")
                    echo "  • Установите Flutter: https://flutter.dev/docs/get-started/install"
                    ;;
            esac
        done
        return 1
    fi
    
    log_success "Все зависимости проверены"
    return 0
}

# Проверка использования Shorebird
check_shorebird() {
    local use_shorebird="$1"
    
    if [[ "$use_shorebird" == "true" ]]; then
        if ! command -v shorebird &> /dev/null; then
            log_error "Shorebird не найден в системе"
            log_info "Установка: curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash"
            return 1
        fi
        
        # Проверяем версию без ошибок в stderr
        local shorebird_version
        if shorebird_version=$(shorebird --version 2>/dev/null | head -n1 | cut -d' ' -f2 2>/dev/null); then
            log_info "Shorebird версия: $shorebird_version"
        else
            log_warning "Не удалось получить версию Shorebird, но команда найдена"
        fi
    fi
    
    echo "$use_shorebird"
}

# Проверка и создание директорий
ensure_directories() {
    if [[ ! -d "$APP_DIR" ]]; then
        log_error "Директория app не найдена: $APP_DIR"
        return 1
    fi
    
    log_info "Рабочая директория: $APP_DIR"
    return 0
}

# Валидация параметров
validate_params() {
    local action="$1"
    local platform="$2"
    local flavor="$3"
    
    # Проверяем action
    case "$action" in
        "release"|"patch"|"build")
            ;;
        *)
            log_error "Неверное действие: '$action'"
            log_info "Доступные действия: release, patch, build"
            return 1
            ;;
    esac
    
    # Проверяем platform
    case "$platform" in
        "android"|"ios")
            ;;
        *)
            log_error "Неверная платформа: '$platform'"
            log_info "Доступные платформы: android, ios"
            return 1
            ;;
    esac
    
    # Проверяем flavor (если указан)
    if [[ -n "$flavor" ]]; then
        case "$flavor" in
            "dev"|"preProd"|"stage"|"prod"|"ruStore"|"local")
                ;;
            *)
                log_error "Неверный flavor: '$flavor'"
                log_info "Доступные flavors: dev, preProd, stage, prod, ruStore, local"
                return 1
                ;;
        esac
    fi
    
    return 0
}

# Парсинг аргументов
parse_arguments() {
    local action="$1"
    local platform="$2"
    shift 2
    
    local flavor=""
    local use_shorebird="true"
    local use_apk="$DEFAULT_USE_APK"
    local build_mode="release"
    local verbose="false"
    local upload_enabled="false"
    local auto_increment="false"
    local flutter_version=""
    

    
    # Парсим остальные аргументы
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --apk)
                use_apk="true"
                ;;
            --no-apk)
                use_apk="false"
                ;;

            --debug|-d)
                build_mode="debug"
                ;;
            --profile|-p)
                build_mode="profile"
                ;;
            --release|-r)
                build_mode="release"
                ;;
            --verbose|-v)
                verbose="true"
                ;;
            --upload|-u)
                upload_enabled="true"
                ;;
            --increment-build-number|-ibn)
                auto_increment="true"
                ;;
            --flutter-version)
                shift
                flutter_version="$1"
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --*)
                log_error "Неизвестный флаг: $1"
                log_info "Используйте --help для получения справки"
                exit 1
                ;;
            *)
                if [[ -z "$flavor" ]]; then
                    flavor="$1"
                else
                    log_error "Неизвестный аргумент: $1"
                    exit 1
                fi
                ;;
        esac
        shift
    done
    
    # Автоматическое определение Flutter версии из .fvmrc для Shorebird release/patch
    if [[ "$use_shorebird" == "true" && ("$action" == "release" || "$action" == "patch") && -z "$flutter_version" ]]; then
        if [[ -f "$FVMRC_PATH" ]]; then
            local auto_flutter_version
            auto_flutter_version=$(grep -o '"flutter":[[:space:]]*"[^"]*"' "$FVMRC_PATH" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
            if [[ -n "$auto_flutter_version" ]]; then
                flutter_version="$auto_flutter_version"
                log_info "Автоматически определена Flutter версия: $flutter_version (из .fvmrc)" >&2
            fi
        fi
    fi
    
    echo "$flavor|$use_shorebird|$use_apk|$build_mode|$verbose|$upload_enabled|$auto_increment|$flutter_version"
} 