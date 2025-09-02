#!/bin/bash

# Автоматический инкремент build number в pubspec.yaml и синхронизация с Xcode
# 
# Использование:
#   build.sh ... --increment-build-number  (рекомендуется)
#   increment-build-number.sh      (прямой вызов)
#
# Поддерживает версии вида: 1.0.0+123

set -e

# Загружаем глобальные переменные
source "$(dirname "${BASH_SOURCE[0]}")/globals.sh"

# Основные функции

# Извлекает текущую версию из pubspec.yaml
get_current_version() {
    if [[ ! -f "$PUBSPEC_PATH" ]]; then
        log_error "pubspec.yaml не найден: $PUBSPEC_PATH"
        return 1
    fi
    
    local version_line
    version_line=$(grep "^version:" "$PUBSPEC_PATH" | head -1)
    
    if [[ -z "$version_line" ]]; then
        log_error "Версия не найдена в pubspec.yaml"
        return 1
    fi
    
    # Извлекаем версию (убираем "version: " и пробелы)
    echo "$version_line" | sed 's/^version:[[:space:]]*//'
}

# Извлекает build number из версии
get_build_number() {
    local version="$1"
    
    if [[ "$version" =~ \+([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        log_error "Не удалось извлечь build number из версии: $version"
        log_error "Ожидаемый формат: 1.0.0+123"
        return 1
    fi
}

# Извлекает версию без build number
get_version_name() {
    local version="$1"
    echo "${version%+*}"
}

# Инкрементирует build number в pubspec.yaml
increment_build_number() {
    log_step "Инкремент build number..."
    
    # Получаем текущую версию
    local current_version
    current_version=$(get_current_version)
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    log_info "📋 Текущая версия: $current_version"
    
    # Извлекаем компоненты
    local version_name build_number
    version_name=$(get_version_name "$current_version")
    build_number=$(get_build_number "$current_version")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Инкрементируем build number
    local new_build_number=$((build_number + 1))
    local new_version="${version_name}+${new_build_number}"
    
    log_info "📱 Новая версия: $new_version"
    
    # Обновляем pubspec.yaml с экранированием regex символов
    local escaped_current_version
    local escaped_new_version
    escaped_current_version=$(printf '%s\n' "$current_version" | sed 's/[\[\.*^$(){}?+|]/\\&/g')
    escaped_new_version=$(printf '%s\n' "$new_version" | sed 's/[&/\]/\\&/g')
    if sed -i.tmp "s/^version:[[:space:]]*${escaped_current_version}/version: ${escaped_new_version}/" "$PUBSPEC_PATH"; then
        rm -f "${PUBSPEC_PATH}.tmp"
        log_success "✅ Build number обновлен в pubspec.yaml"
    else
        log_error "❌ Ошибка при обновлении pubspec.yaml"
        return 1
    fi
    
    # Проверяем результат
    local updated_version
    updated_version=$(get_current_version)
    if [[ "$updated_version" == "$new_version" ]]; then
        log_success "✅ Версия успешно обновлена: $updated_version"
    else
        log_error "❌ Ошибка проверки: ожидалась $new_version, получена $updated_version"
        return 1
    fi
    
    return 0
}

# Синхронизирует версию с Xcode
sync_with_xcode() {
    log_step "Синхронизация с Xcode..."
    
    if [[ -f "$IOS_VERSION_SCRIPT" ]]; then
        # Подключаем и вызываем скрипт синхронизации
        source "$IOS_VERSION_SCRIPT"
        
        if sync_xcode_version; then
            log_success "✅ Версия синхронизирована с Xcode"
        else
            log_warning "⚠️ Ошибка синхронизации с Xcode"
            return 1
        fi
    else
        log_warning "⚠️ Скрипт синхронизации Xcode не найден: $IOS_VERSION_SCRIPT"
        log_info "iOS версия не будет синхронизирована"
    fi
}

# Основная функция инкремента
increment_build() {
    log_info "🔄 Автоматический инкремент build number..."
    log_info "📁 Корень проекта: $PROJECT_ROOT"
    log_info "📱 App директория: $APP_DIR"
    log_info "📄 pubspec.yaml: $PUBSPEC_PATH"
    
    # Инкрементируем build number
    if ! increment_build_number; then
        log_error "❌ Ошибка инкремента build number"
        return 1
    fi
    
    # Синхронизируем с Xcode
    if ! sync_with_xcode; then
        log_error "❌ Ошибка синхронизации с Xcode"
        return 1
    fi
    
    log_success "🎉 Build number успешно инкрементирован!"
    return 0
}

# Точка входа для прямого запуска
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "==========================================="
    echo "🔢 Прямой запуск Build Number Increment"
    echo "==========================================="
    echo
    echo "📁 Проект: $PROJECT_ROOT"
    echo "📱 App директория: $APP_DIR"
    echo
    
    increment_build
    
    if [[ $? -eq 0 ]]; then
        echo
        echo "✅ Инкремент завершен успешно!"
        exit 0
    else
        echo
        echo "❌ Ошибка инкремента!"
        exit 1
    fi
fi 