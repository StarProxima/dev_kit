#!/bin/bash

if [ "$1" = "--help" ]; then
    echo "Рефакторинг структуры тестов part/part of -> imports"
    echo "Использование: ./tools/refactor_tests.sh [директория] [--dry-run]"
    echo "  директория: путь к тестам (по умолчанию: test)"
    echo "  --dry-run: показать изменения без их выполнения"
    exit 0
fi

echo "🔧 Рефакторинг структуры тестов..."
cd "$(dirname "$0")/.."

dart run tools/refactor_tests.dart "$@"

echo "✨ Готово!"
