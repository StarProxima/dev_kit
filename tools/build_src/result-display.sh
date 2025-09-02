#!/bin/bash

# Отображение путей к собранным файлам

# Загружаем глобальные переменные
source "$(dirname "${BASH_SOURCE[0]}")/globals.sh"

# Функции поиска Android файлов
find_android_apk_files() {
    local flavor="$1"
    local found_files=()
    
    # Создаем массив из строки с поддиректориями (совместимо с bash и zsh)
    if [[ -n "$ZSH_VERSION" ]]; then
        local subdirs_array=(${=ANDROID_APK_SUBDIRS})
    else
        local subdirs_array=($ANDROID_APK_SUBDIRS)
    fi
    
    # Перебираем все поддиректории для APK
    for subdir in "${subdirs_array[@]}"; do
        local search_path="$ANDROID_SEARCH_DIRS/$subdir"
        if [[ -d "$search_path" ]]; then
            # Ищем файлы с flavor
            if [[ -n "$flavor" ]]; then
                while IFS= read -r -d '' file; do
                    found_files+=("$file")
                done < <(find "$search_path" -name "*$flavor*.apk" -type f -print0 2>/dev/null)
            fi
            
            # Ищем любые APK файлы если flavor не найдены
            if [[ ${#found_files[@]} -eq 0 ]]; then
                while IFS= read -r -d '' file; do
                    found_files+=("$file")
                done < <(find "$search_path" -name "*.apk" -type f -print0 2>/dev/null)
            fi
        fi
    done
    
    # Выводим найденные файлы
    for file in "${found_files[@]}"; do
        echo "$file"
    done
}

find_android_aab_files() {
    local flavor="$1"
    local found_files=()
    
    # Создаем массив из строки с поддиректориями (совместимо с bash и zsh)
    if [[ -n "$ZSH_VERSION" ]]; then
        local subdirs_array=(${=ANDROID_AAB_SUBDIRS})
    else
        local subdirs_array=($ANDROID_AAB_SUBDIRS)
    fi
    
    # Перебираем все поддиректории для AAB
    for subdir in "${subdirs_array[@]}"; do
        local search_path="$ANDROID_SEARCH_DIRS/$subdir"
        if [[ -d "$search_path" ]]; then
            # Ищем файлы с flavor
            if [[ -n "$flavor" ]]; then
                while IFS= read -r -d '' file; do
                    found_files+=("$file")
                done < <(find "$search_path" -name "*$flavor*.aab" -type f -print0 2>/dev/null)
            fi
            
            # Ищем любые AAB файлы если flavor не найдены
            if [[ ${#found_files[@]} -eq 0 ]]; then
                while IFS= read -r -d '' file; do
                    found_files+=("$file")
                done < <(find "$search_path" -name "*.aab" -type f -print0 2>/dev/null)
            fi
        fi
    done
    
    # Выводим найденные файлы
    for file in "${found_files[@]}"; do
        echo "$file"
    done
}

# Показ результатов сборки
show_build_result() {
    local platform="$1"
    local flavor="$2"
    local use_apk="$3"
    
    # Получаем относительный путь от корня проекта
    local rel_path_prefix="app"
    
    if [[ "$platform" == "android" ]]; then
        if [[ "$use_apk" == "true" ]]; then
            # Ищем APK файлы рекурсивно
            local apk_found=false
            while IFS= read -r apk_file; do
                if [[ -n "$apk_file" ]]; then
                    local rel_apk_path="${apk_file#$PROJECT_ROOT/}"
                    log_info "📦 APK файл: $rel_apk_path"
                    apk_found=true
                fi
            done < <(find_android_apk_files "$flavor")
            
            if [[ "$apk_found" == "false" ]]; then
                log_info "📦 APK файлы сохранены в: $rel_path_prefix/build/app/outputs/"
            fi
        else
            # Ищем AAB файлы рекурсивно
            local aab_found=false
            while IFS= read -r aab_file; do
                if [[ -n "$aab_file" ]]; then
                    local rel_aab_path="${aab_file#$PROJECT_ROOT/}"
                    log_info "📦 AAB файл: $rel_aab_path"
                    aab_found=true
                fi
            done < <(find_android_aab_files "$flavor")
            
            if [[ "$aab_found" == "false" ]]; then
                log_info "📦 AAB файлы сохранены в: $rel_path_prefix/build/app/outputs/"
            fi
        fi
    elif [[ "$platform" == "ios" ]]; then
        # Ищем iOS архивы и IPA файлы
        local archive_dir="$APP_DIR/build/ios/archive"
        local ipa_dir="$APP_DIR/build/ios/ipa"
        
        # Ищем xcarchive файлы
        local archive_found=false
        if [[ -d "$archive_dir" ]]; then
            while IFS= read -r -d '' archive_file; do
                local rel_archive_path="${archive_file#$PROJECT_ROOT/}"
                log_info "📱 Архив: $rel_archive_path"
                archive_found=true
            done < <(find "$archive_dir" -name "*.xcarchive" -type d -print0)
            
            if [[ "$archive_found" == "false" ]]; then
                log_info "📱 Архивы сохранены в: $rel_path_prefix/build/ios/archive/"
            fi
        fi
        
        # Ищем IPA файлы
        local ipa_found=false
        if [[ -d "$ipa_dir" ]]; then
            while IFS= read -r -d '' ipa_file; do
                local rel_ipa_path="${ipa_file#$PROJECT_ROOT/}"
                log_info "📱 IPA файл: $rel_ipa_path"
                ipa_found=true
            done < <(find "$ipa_dir" -name "*.ipa" -type f -print0)
        fi
        
        # Если ничего не найдено, выводим общую информацию
        if [[ "$archive_found" == "false" && "$ipa_found" == "false" ]]; then
            if [[ ! -d "$archive_dir" && ! -d "$ipa_dir" ]]; then
                log_info "📱 iOS сборка завершена"
            fi
        fi
    fi
} 