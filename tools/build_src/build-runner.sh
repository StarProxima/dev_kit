#!/bin/bash

# Основная логика сборки приложения

# Загружаем глобальные переменные
source "$(dirname "${BASH_SOURCE[0]}")/globals.sh"

# Основная функция сборки
run_build() {
    local action="$1"
    local platform="$2"
    local original_platform="$3"
    local flavor="$4"
    local use_shorebird="$5"
    local use_apk="$6"
    local build_mode="$7"
    local verbose="$8"
    local upload_enabled="$9"
    local auto_increment="${10}"
    local flutter_version="${11}"
    
    log_step "Подготовка к сборке..."
    
    # Определяем базовую команду
    local base_command="flutter"
    if [[ "$use_shorebird" == "true" ]]; then
        base_command="shorebird"
    else
        # Для Flutter меняем action и platform
        if [[ "$action" == "release" || "$action" == "patch" ]]; then
            action="build"
        fi
        
        # Для Flutter Android используем apk или appbundle
        if [[ "$platform" == "android" ]]; then
            if [[ "$use_apk" == "true" ]]; then
                platform="apk"
            else
                platform="appbundle"
            fi
        fi
    fi
    
    # Формируем команду
    local command="$base_command $action $platform"
    
    # Добавляем artifact для Shorebird Android
    if [[ "$original_platform" == "android" && "$use_shorebird" == "true" && "$action" == "release" && "$use_apk" == "true" ]]; then
        command+=" --artifact apk"
    fi
    
    # Добавляем flavor
    if [[ -n "$flavor" ]]; then
        command+=" --flavor $flavor"
        command+=" --dart-define=FLAVOR=$flavor"
    fi
    
    # Добавляем build mode для Flutter
    if [[ "$use_shorebird" == "false" ]]; then
        case "$build_mode" in
            "debug")
                command+=" --debug"
                ;;
            "profile")
                command+=" --profile"
                ;;
            "release")
                command+=" --release"
                ;;
        esac
    fi
    
    # Добавляем flutter-version для Shorebird
    if [[ "$use_shorebird" == "true" && -n "$flutter_version" ]]; then
        command+=" --flutter-version $flutter_version"
    fi
    
    # Добавляем verbose
    if [[ "$verbose" == "true" ]]; then
        command+=" --verbose"
    fi
    
    # Показываем информацию о сборке
    echo
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "🎯 Действие: $action"
    log_info "📱 Платформа: $original_platform"
    [[ -n "$flavor" ]] && log_info "🌍 Flavor: $flavor"
    log_info "🔧 Инструмент: $base_command"
    [[ "$original_platform" == "android" && "$use_apk" == "true" ]] && log_info "📦 Формат: APK"
    [[ "$original_platform" == "android" && "$use_apk" == "false" ]] && log_info "📦 Формат: App Bundle"
    [[ "$use_shorebird" == "false" ]] && log_info "🏗️ Режим: $build_mode"
    [[ "$use_shorebird" == "true" ]] && log_info "🏗️ Режим: release (Shorebird)"
    [[ "$use_shorebird" == "true" && -n "$flutter_version" ]] && log_info "📱 Flutter версия: $flutter_version"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    # Переходим в директорию app
    cd "$APP_DIR" || {
        log_error "Не удалось перейти в директорию: $APP_DIR"
        return 1
    }
    
    # Обновляем версию для iOS
    update_ios_version "$original_platform" "$use_shorebird"
    
    # Версия будет применена автоматически через обновленный project.pbxproj
    
    # Выполняем команду
    log_command "$command"
    echo
    
    if eval "$command"; then
        echo
        log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_success "🎉 Сборка завершена успешно!"
        log_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Показываем информацию о результате с конкретными путями к файлам
        show_build_result "$original_platform" "$flavor" "$use_apk"
        
        # Автоматически инкрементируем build number если требуется
        auto_increment_build_number "$auto_increment"
        
        # Загружаем в App Store Connect если требуется
        upload_ios_to_appstore "$original_platform" "$flavor" "$upload_enabled"
    else
        echo
        log_error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_error "❌ Ошибка при сборке!"
        log_error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        return 1
    fi
    
    # Возвращаемся в исходную директорию
    cd - > /dev/null
} 