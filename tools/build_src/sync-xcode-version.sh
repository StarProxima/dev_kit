#!/bin/bash

# Синхронизация версии Xcode с pubspec.yaml
# Универсальный скрипт для Flutter проектов

# Загружаем глобальные переменные
source "$(dirname "${BASH_SOURCE[0]}")/globals.sh"

# Основная функция синхронизации

sync_xcode_version() {
    log_info "🔄 Синхронизация версии Xcode с pubspec.yaml..."
    log_info "📁 Корень проекта: $PROJECT_ROOT"
    
    # Проверяем существование файлов
    if [[ ! -f "$PUBSPEC_PATH" ]]; then
        log_error "Файл pubspec.yaml не найден: $PUBSPEC_PATH"
        return 1
    fi
    
    if [[ ! -f "$XCODE_PROJECT_PATH" ]]; then
        log_error "Файл project.pbxproj не найден: $XCODE_PROJECT_PATH"
        log_error "Убедитесь что iOS проект инициализирован"
        return 1
    fi
    
    # Чтение версии из pubspec.yaml
    local version
    version=$(grep "^version:" "$PUBSPEC_PATH" | sed 's/version: //')
    
    if [[ -z "$version" ]]; then
        log_error "Не удалось прочитать версию из $PUBSPEC_PATH"
        return 1
    fi
    
    local version_number=${version%%+*}
    local build_number=${version##*+}
    
    log_info "📋 Текущая версия: $version_number+$build_number"
    
    # Проверяем корректность версии
    if [[ -z "$version_number" || -z "$build_number" ]]; then
        log_error "Некорректный формат версии в pubspec.yaml: $version"
        log_error "Ожидается формат: 1.0.0+1"
        return 1
    fi
    
    # Регулярные выражения для замены версии
    local version_regex="MARKETING_VERSION = .*;"
    local build_regex="CURRENT_PROJECT_VERSION = .*;"
    
    # Экранируем специальные символы в replacement строках для sed
    local escaped_version_number
    local escaped_build_number
    escaped_version_number=$(printf '%s\n' "$version_number" | sed 's/[&/\]/\\&/g')
    escaped_build_number=$(printf '%s\n' "$build_number" | sed 's/[&/\]/\\&/g')
    
    # Замена версий для всех схем
    if sed -i.tmp "s/$version_regex/MARKETING_VERSION = $escaped_version_number;/" "$XCODE_PROJECT_PATH" && \
       sed -i.tmp "s/$build_regex/CURRENT_PROJECT_VERSION = $escaped_build_number;/" "$XCODE_PROJECT_PATH"; then
        # Удаляем временные файлы после успешного обновления
        rm -f "${XCODE_PROJECT_PATH}.tmp"
        
        log_success "✅ Версия обновлена в Xcode проекте"
        log_info "📱 Marketing Version: $version_number"
        log_info "🔢 Build Number: $build_number"
        log_info "📄 Файл: $(basename "$XCODE_PROJECT_PATH")"
        
        # Проверяем что изменения применились
        local updated_marketing_matches=$(grep "MARKETING_VERSION" "$XCODE_PROJECT_PATH" | sed 's/.*= \(.*\);/\1/')
        local updated_build=$(grep "CURRENT_PROJECT_VERSION" "$XCODE_PROJECT_PATH" | head -1 | sed 's/.*= \(.*\);/\1/')
        
        if echo "$updated_marketing_matches" | grep -q "^$version_number$" && [[ "$updated_build" == "$build_number" ]]; then
            log_success "✅ Версия успешно проверена в проекте"
        else
            log_warning "⚠️  Предупреждение: версия в проекте может быть некорректной"
            log_info "Ожидалось: $version_number+$build_number"
            log_info "Найдено MARKETING_VERSION(s): $(echo "$updated_marketing_matches" | tr '\n' ', ' | sed 's/,$//')"
            log_info "Найдено CURRENT_PROJECT_VERSION: $updated_build"
        fi
        
        return 0
    else
        log_error "❌ Ошибка при обновлении версии"
        # Очистка временных файлов при ошибке
        rm -f "${XCODE_PROJECT_PATH}.tmp"
        return 1
    fi
}

# Точка входа для прямого запуска
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "==========================================="
    echo "🔄 Прямой запуск Xcode Version Sync Script"
    echo "==========================================="
    echo ""
    echo "📁 Проект: $PROJECT_ROOT"
    echo "📱 App директория: $APP_DIR"
    echo ""
    
    if sync_xcode_version; then
        echo ""
        echo "✅ Синхронизация версии завершена успешно!"
    else
        echo ""
        echo "❌ Ошибка при синхронизации версии"
        exit 1
    fi
else
    # Экспортируем главную функцию для использования в родительском скрипте
    export -f sync_xcode_version
fi 