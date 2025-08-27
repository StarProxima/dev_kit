#!/bin/bash

echo "🔧 Генерация экспортов для app_update..."
cd "$(dirname "$0")/.."
dart run tools/generate_exports.dart
echo "✨ Готово!"
