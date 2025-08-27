#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Использование: ./tools/refactor.sh <директория>"
    echo "Пример: ./tools/refactor.sh test/"
    exit 1
fi

echo "🔄 Рефакторинг импортов app_update..."
cd "$(dirname "$0")/.."
dart run tools/refactor_imports.dart "$1"
echo "✨ Готово!"
