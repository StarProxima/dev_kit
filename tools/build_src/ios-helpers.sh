#!/bin/bash

# iOS специфичные функции

# Загружаем глобальные переменные
source "$(dirname "${BASH_SOURCE[0]}")/globals.sh"

# Загрузка конфигурации сборки
load_build_config() {
    local upload_enabled="$1"
    
    if [[ "$upload_enabled" != "true" ]]; then
        return 0
    fi
    
    if [[ -f "$BUILD_CONFIG_PATH" ]]; then
        log_info "Загружаю конфигурацию из tools/build/build.env"
        source "$BUILD_CONFIG_PATH"
    else
        log_error "Файл конфигурации не найден: $BUILD_CONFIG_PATH"
        echo
        echo "Для автоматической загрузки в App Store Connect:"
        echo "1. Скопируйте: cp tools/build/build.env.example tools/build/build.env"
        echo "2. Отредактируйте tools/build/build.env с вашими данными"
        echo "3. Поместите .p8 файл API ключа в tools/build/"
        echo
        echo "Подробные инструкции в tools/build/build.env.example"
        return 1
    fi
    
    return 0
}

# Обновление версии для iOS
update_ios_version() {
    local platform="$1"
    local use_shorebird="$2"
    
    if [[ "$platform" == "ios" ]]; then
        log_step "Обновление версии для iOS..."
        
        if [[ -f "$IOS_VERSION_SCRIPT" ]]; then
            # Подключаем скрипт синхронизации версии
            source "$IOS_VERSION_SCRIPT"
            sync_xcode_version
            log_success "Версия обновлена"
        else
            log_warning "Скрипт обновления версии не найден: $IOS_VERSION_SCRIPT"
        fi
    fi
}

# Загрузка iOS билда в App Store Connect
upload_ios_to_appstore() {
    local original_platform="$1"
    local flavor="$2"
    local upload_enabled="$3"
    
    if [[ "$original_platform" == "ios" && "$upload_enabled" == "true" ]]; then
        # Подключаем скрипт загрузки в App Store
        source "$IOS_UPLOAD_SCRIPT"
        main_upload "$APP_DIR" "$flavor"
    fi
}

# Автоматически инкрементирует build number после успешного билда
auto_increment_build_number() {
    local auto_increment="$1"
    
    if [[ "$auto_increment" == "true" ]]; then
        log_step "Автоматический инкремент build number..."
        
        if [[ -f "$INCREMENT_BUILD_SCRIPT" ]]; then
            # Подключаем скрипт инкремента
            source "$INCREMENT_BUILD_SCRIPT"
            
            if increment_build; then
                log_success "✅ Build number успешно инкрементирован"
            else
                log_warning "⚠️ Ошибка инкремента build number"
                return 1
            fi
        else
            log_warning "⚠️ Скрипт инкремента не найден: $INCREMENT_BUILD_SCRIPT"
        fi
    fi
} 