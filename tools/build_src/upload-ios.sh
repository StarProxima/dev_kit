#!/bin/bash

# Загрузка IPA файлов в App Store Connect
# Использует App Store Connect API для аутентификации

# Загружаем глобальные переменные
source "$(dirname "${BASH_SOURCE[0]}")/globals.sh"


# Проверка конфигурации App Store Connect API
check_appstore_config() {
    log_step "Проверка конфигурации App Store Connect API..."
    
    # Проверяем наличие xcrun (часть Xcode Command Line Tools)
    if ! command -v xcrun &> /dev/null; then
        log_error "xcrun не найден. Установите Xcode Command Line Tools:"
        log_info "xcode-select --install"
        return 1
    fi
    
    # Проверяем обязательные переменные
    if [[ -z "$APPSTORE_API_KEY_PATH" ]]; then
        log_error "APPSTORE_API_KEY_PATH не указан в конфигурации"
        return 1
    fi
    
    if [[ -z "$APPSTORE_API_KEY_ID" ]]; then
        log_error "APPSTORE_API_KEY_ID не указан в конфигурации"
        return 1
    fi
    
    if [[ -z "$APPSTORE_ISSUER_ID" ]]; then
        log_error "APPSTORE_ISSUER_ID не указан в конфигурации"
        return 1
    fi
    
    # Проверяем существование API ключа
    local api_key_full_path="$BUILD_ENV_DIR/$APPSTORE_API_KEY_PATH"
    
    if [[ ! -f "$api_key_full_path" ]]; then
        log_error "API ключ не найден: $api_key_full_path"
        log_info "Поместите .p8 файл в директорию $BUILD_ENV_DIR/"
        log_info "Или обновите APPSTORE_API_KEY_PATH в конфигурации"
        return 1
    fi
    
    log_success "Конфигурация App Store Connect API проверена"
    log_info "API Key ID: $APPSTORE_API_KEY_ID"
    log_info "Issuer ID: $APPSTORE_ISSUER_ID"
    log_info "API Key файл: $APPSTORE_API_KEY_PATH"
    return 0
}

# Поиск IPA файлов
find_ipa_files() {
    log_info "🔍 Поиск IPA файлов в: $IPA_DIR" >&2
    
    if [[ ! -d "$IPA_DIR" ]]; then
        log_error "Директория с IPA файлами не найдена: $IPA_DIR" >&2
        log_info "Убедитесь что iOS сборка прошла успешно" >&2
        log_info "Ожидаемый путь: $APP_DIR/build/ios/ipa/" >&2
        return 1
    fi
    
    # Ищем IPA файлы
    local ipa_files=()
    while IFS= read -r -d '' ipa_file; do
        ipa_files+=("$ipa_file")
    done < <(find "$IPA_DIR" -name "*.ipa" -type f -print0)
    
    if [[ ${#ipa_files[@]} -eq 0 ]]; then
        log_error "IPA файлы не найдены в $IPA_DIR" >&2
        log_info "Убедитесь что iOS сборка завершилась успешно" >&2
        
        # Покажем что есть в директории
        if ls -la "$IPA_DIR" 2>/dev/null >&2; then
            log_info "Содержимое директории $IPA_DIR:" >&2
            ls -la "$IPA_DIR" 2>&1 | head -10 >&2
        fi
        
        return 1
    fi
    
    log_info "📱 Найдено IPA файлов: ${#ipa_files[@]}" >&2
    
    # Возвращаем первый найденный IPA файл
    echo "${ipa_files[0]}"
    return 0
}

# Загрузка IPA файла в App Store Connect
upload_ipa_to_appstore() {
    local ipa_file="$1"
    # Используем глобальную переменную
    local api_key_full_path="$BUILD_ENV_DIR/$APPSTORE_API_KEY_PATH"
    
    if [[ ! -f "$ipa_file" ]]; then
        log_error "IPA файл не найден: $ipa_file"
        return 1
    fi
    
    local ipa_filename=$(basename "$ipa_file")
    log_info "Загружаю IPA файл: $ipa_filename"
    
    # Создаем стандартную директорию для API ключей если не существует
    local standard_keys_dir="$HOME/.appstoreconnect/private_keys"
    if ! mkdir -p "$standard_keys_dir"; then
        log_error "Не удалось создать директорию: $standard_keys_dir"
        return 1
    fi
    
    # Копируем API ключ в стандартную директорию (временно)
    local temp_key_path="$standard_keys_dir/$APPSTORE_API_KEY_PATH"
    if ! cp "$api_key_full_path" "$temp_key_path"; then
        log_error "Не удалось скопировать API ключ в: $temp_key_path"
        return 1
    fi
    
    log_info "🔑 API ключ временно скопирован в стандартную директорию"
    
    # Формируем команду загрузки (без --apiKeyFile, altool найдет ключ в стандартной директории)
    local upload_cmd="xcrun altool --upload-app --type ios"
    upload_cmd+=" --file \"$ipa_file\""
    upload_cmd+=" --apiKey \"$APPSTORE_API_KEY_ID\""
    upload_cmd+=" --apiIssuer \"$APPSTORE_ISSUER_ID\""
    
    echo
    log_command "$upload_cmd"
    echo
    
    # Выполняем загрузку
    local upload_result=0
    if eval "$upload_cmd"; then
        echo
        log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_success "🚀 IPA файл успешно загружен в App Store Connect!"
        log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "📱 Файл: $ipa_filename"
        log_info "🔗 Проверьте статус: https://appstoreconnect.apple.com"
        log_info "⏱️  Обработка может занять несколько минут"
        upload_result=0
    else
        echo
        log_error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_error "❌ Ошибка при загрузке в App Store Connect!"
        log_error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "💡 Возможные причины:"
        log_info "   • Неверная конфигурация API ключа"
        log_info "   • Приложение не найдено в App Store Connect"
        log_info "   • Проблемы с Bundle Identifier"
        log_info "   • Неверная версия или build number"
        upload_result=1
    fi
    
    # Удаляем временный API ключ
    if [[ -f "$temp_key_path" ]]; then
        rm -f "$temp_key_path"
        log_info "🔒 Временный API ключ удален"
    fi
    
    return $upload_result
}

# Главная функция загрузки
main_upload() {
    local app_dir="$1"  # Для обратной совместимости (игнорируется)
    local flavor="$2"
    
    log_step "Загрузка iOS билда в App Store Connect..."
    log_info "📁 Корень проекта: $PROJECT_ROOT"
    log_info "📱 App директория: $APP_DIR"
    
    # Проверяем конфигурацию
    if ! check_appstore_config; then
        return 1
    fi
    
    # Ищем IPA файлы
    local ipa_file
    if ! ipa_file=$(find_ipa_files); then
        return 1
    fi
    
    # Показываем информацию о найденном файле
    local ipa_filename=$(basename "$ipa_file")
    local file_size=""
    if [[ -f "$ipa_file" ]]; then
        file_size=$(du -h "$ipa_file" 2>/dev/null | cut -f1)
    fi
    log_info "✅ Найден IPA файл: $ipa_filename ${file_size:+($file_size)}"
    
    # Загружаем файл
    if upload_ipa_to_appstore "$ipa_file"; then
        return 0
    else
        return 1
    fi
}


# Если скрипт запущен напрямую (не из другого скрипта)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "===========================================" 
    echo "🚀 Прямой запуск iOS Upload Script"
    echo "==========================================="
    echo ""
    echo "📁 Проект: $PROJECT_ROOT"
    echo "📱 App директория: $APP_DIR"
    echo ""
    
    # Пытаемся загрузить конфигурацию
    build_config="$BUILD_ENV_DIR/build.env"
    
    if [[ -f "$build_config" ]]; then
        echo "📋 Загружаю конфигурацию из: $build_config"
        source "$build_config"
    else
        echo "❌ Файл конфигурации не найден: $build_config"
        echo ""
        echo "Для прямого запуска создайте конфигурацию:"
        echo "  cp $BUILD_ENV_DIR/build.env.example $BUILD_ENV_DIR/build.env"
        echo ""  
        echo "Или используйте через главный скрипт:"
        echo "  ./tools/build/build.sh release ios prod --upload"
        exit 1
    fi
    
    echo ""
    echo "🔄 Запуск загрузки..."
    
    # Запускаем главную функцию
    if main_upload "" ""; then
        echo ""
        echo "✅ Загрузка завершена успешно!"
    else
        echo ""
        echo "❌ Ошибка при загрузке"
        exit 1
    fi
else
    # Экспортируем главную функцию для использования в родительском скрипте
    export -f main_upload
fi 
