#!/bin/bash

# Build скрипт для сборки Flutter/Shorebird приложений
# Поддерживает iOS и Android, разные flavors и режимы сборки

# Загружаем глобальные переменные
source "$(dirname "${BASH_SOURCE[0]}")/globals.sh"

# Подключаем модули

source "$BUILD_DIR/validate.sh"
source "$BUILD_DIR/ios-helpers.sh"
source "$BUILD_DIR/result-display.sh"
source "$BUILD_DIR/build-runner.sh"

# Основная логика

main() {
    # Проверяем help сначала
    case "${1:-}" in
        --help|-h|help|"")
            show_help
            exit 0
            ;;
    esac
    
    # Проверяем аргументы
    if [[ $# -lt 2 ]]; then
        show_help
        exit 0
    fi
    
    local action="$1"
    local platform="$2"
    
    show_banner
    
    # Проверяем зависимости
    if ! check_dependencies; then
        exit 1
    fi
    
    # Проверяем директории
    if ! ensure_directories; then
        exit 1
    fi
    
    # Валидируем параметры
    if ! validate_params "$action" "$platform" ""; then
        echo
        log_info "Используйте '$0 --help' для получения справки"
        exit 1
    fi
    
    # Парсим аргументы
    local parse_result
    parse_result=$(parse_arguments "$@")
    IFS='|' read -r flavor use_shorebird use_apk build_mode verbose upload_enabled auto_increment <<< "$parse_result"
    
    # Проверяем Shorebird если нужен (не для build action)
    if [[ "$use_shorebird" == "true" && "$action" != "build" ]]; then
        if ! check_shorebird "$use_shorebird"; then
            log_error "Проблемы с Shorebird. Используйте --no-shorebird для Flutter или исправьте установку Shorebird"
            exit 1
        fi
    fi
    
    # Дополнительная валидация с flavor
    if ! validate_params "$action" "$platform" "$flavor"; then
        echo
        log_info "Используйте '$0 --help' для получения справки"
        exit 1
    fi
    
    # Загружаем конфигурацию для App Store Connect если требуется загрузка
    if ! load_build_config "$upload_enabled"; then
        exit 1
    fi
    
    # Запускаем сборку
    if run_build "$action" "$platform" "$platform" "$flavor" "$use_shorebird" "$use_apk" "$build_mode" "$verbose" "$upload_enabled" "$auto_increment"; then
        echo
        log_success "🎊 Процесс завершен успешно!"
    else
        echo
        log_error "💥 Процесс завершен с ошибкой!"
        exit 1
    fi
}

# Вспомогательные функции

# Цвета и функции логирования загружены из globals.sh

# ASCII баннер
show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
██████╗ ██╗   ██╗██╗██╗     ██████╗ 
██╔══██╗██║   ██║██║██║     ██╔══██╗
██████╔╝██║   ██║██║██║     ██║  ██║
██╔══██╗██║   ██║██║██║     ██║  ██║
██████╔╝╚██████╔╝██║███████╗██████╔╝
╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ 
EOF
    echo -e "${NC}"
    echo -e "${WHITE}🚀 Build Script $BUILD_SCRIPT_VERSION${NC}"
    echo -e "${GRAY}═══════════════════════════════════════════════════════${NC}"
    echo
}

# Показать справку
show_help() {
    show_banner
    echo -e "🔧 ${WHITE}Использование:${NC} $0 <action> <platform> [flavor] [flags]"
    echo
    echo -e "📝 ${WHITE}Действия (Actions):${NC}"
    echo -e "   ${GREEN}release${NC}     Создать новый релиз через Shorebird"
    echo -e "   ${GREEN}patch${NC}       Создать патч для существующего релиза через Shorebird"
    echo -e "   ${GREEN}build${NC}       Обычная сборка через Flutter (автоматически --no-shorebird)"
    echo
    echo -e "🎯 ${WHITE}Платформы (Platforms):${NC}"
    echo -e "   ${BLUE}android${NC}     Android платформа"
    echo -e "   ${BLUE}ios${NC}         iOS платформа"
    echo
    echo -e "🌍 ${WHITE}Flavors (опционально):${NC}"
    echo -e "   ${YELLOW}dev${NC}        Development среда"
    echo -e "   ${YELLOW}preProd${NC}    Pre-production среда"
    echo -e "   ${YELLOW}stage${NC}      Staging среда"
    echo -e "   ${YELLOW}prod${NC}       Production среда"
    echo -e "   ${YELLOW}ruStore${NC}    Russian Store версия"
    echo -e "   ${YELLOW}local${NC}      Local development"
    echo
    echo -e "🚩 ${WHITE}Флаги:${NC}"
    echo -e "   ${PURPLE}--apk${NC}                    Создать APK для Android (по умолчанию: $([[ "$DEFAULT_USE_APK" == "true" ]] && echo "включено" || echo "выключено"))"
    echo -e "   ${PURPLE}--no-apk${NC}                 Использовать App Bundle для Android"
    echo -e "   ${PURPLE}--no-shorebird${NC}, ${PURPLE}-ns${NC}     Использовать Flutter вместо Shorebird"
    echo -e "   ${PURPLE}--debug${NC}, ${PURPLE}-d${NC}             Debug режим сборки"
    echo -e "   ${PURPLE}--profile${NC}, ${PURPLE}-p${NC}           Profile режим сборки"
    echo -e "   ${PURPLE}--release${NC}, ${PURPLE}-r${NC}           Release режим сборки (по умолчанию)"
    echo -e "   ${PURPLE}--upload${NC}, ${PURPLE}-u${NC}            Автоматически загрузить в App Store Connect (только iOS)"
    echo -e "   ${PURPLE}--auto-increment${NC}, ${PURPLE}-ai${NC}   Автоматически увеличить build number после успешного билда"
    echo -e "   ${PURPLE}--verbose${NC}, ${PURPLE}-v${NC}           Подробный вывод команд"
    echo -e "   ${PURPLE}--help${NC}, ${PURPLE}-h${NC}             Показать эту справку"
    echo
    echo -e "💡 ${WHITE}Примеры использования:${NC}"
    echo
    echo -e "   ${CYAN}# Release для Android с APK${NC}"
    echo -e "   $0 release android dev --apk"
    echo
    echo -e "   ${CYAN}# Patch для iOS production${NC}"
    echo -e "   $0 patch ios prod"
    echo
    echo -e "   ${CYAN}# Обычная сборка через Flutter${NC}"
    echo -e "   $0 build android dev --debug"
    echo
    echo -e "   ${CYAN}# Debug сборка с краткими параметрами${NC}"
    echo -e "   $0 build android dev -d -v"
    echo
    echo -e "   ${CYAN}# Release для ruStore с подробным выводом${NC}"
    echo -e "   $0 release android ruStore --apk --verbose"
    echo
    echo -e "   ${CYAN}# iOS релиз с автоматической загрузкой в App Store${NC}"
    echo -e "   $0 release ios prod --upload"
    echo
    echo -e "   ${CYAN}# Release с автоматическим инкрементом build number${NC}"
    echo -e "   $0 release android dev --auto-increment"
    echo
    echo -e "   ${CYAN}# Краткие параметры для быстрого использования${NC}"
    echo -e "   $0 release ios prod -u -ai -v"
    echo
    echo -e "🔑 ${WHITE}Особенности:${NC}"
    echo -e "   • Автоматическое обновление версии для iOS релизов"
    echo -e "   • Автоматический инкремент build number для избежания конфликтов"
    echo -e "   • Поддержка Shorebird Code Push"
    echo -e "   • Умное определение типа сборки"
    echo -e "   • Цветной вывод с индикацией прогресса"
    echo -e "   • Валидация параметров и окружения"
    echo -e "   • Конфигурируемые настройки по умолчанию"
    echo -e "   • Вывод кликабельных путей к собранным файлам"
    echo -e "   • Автоматическая загрузка iOS билдов в App Store Connect"
    echo -e "   • Модульная архитектура скриптов"
    echo
    echo -e "⚙️  ${WHITE}Конфигурация (изменяется в начале файла):${NC}"
    echo -e "   ${YELLOW}DEFAULT_USE_APK${NC}=$DEFAULT_USE_APK       # Использовать APK по умолчанию"
    echo
}

# Запуск скрипта
main "$@" 