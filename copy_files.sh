#!/bin/bash

# Проверяем, что переданы аргументы
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <целевая_директория>"
    exit 1
fi

TARGET_DIR="$1"
LOG_FILE="copy_log.txt"

# Проверяем, существует ли указанная директория
if [ ! -d "$TARGET_DIR" ]; then
    echo "Директория $TARGET_DIR не существует."
    exit 1
fi

# Получаем список последних 5 коммитов (или меньше, если их меньше пяти)
COMMITS=$(git log --pretty=format:"%h %s" -n 5)

# Проверяем, есть ли коммиты
if [ -z "$COMMITS" ]; then
    echo "Нет коммитов в репозитории."
    exit 0
fi

# Выводим список коммитов и предлагаем пользователю выбрать один
echo "Выберите коммит для копирования файлов:"
echo "$COMMITS"
echo -n "Введите хэш коммита: "
read COMMIT_HASH

# Проверяем, существует ли выбранный коммит
if ! git rev-parse --quiet --verify "$COMMIT_HASH" > /dev/null; then
    echo "Коммит с хэшем $COMMIT_HASH не найден."
    exit 1
fi

# Получаем список файлов из выбранного коммита
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r "$COMMIT_HASH")

# Проверяем, есть ли измененные файлы
if [ -z "$CHANGED_FILES" ]; then
    echo "Нет файлов в выбранном коммите."
    exit 0
fi

# Копируем файлы из выбранного коммита в целевую директорию
for FILE in $CHANGED_FILES; do
    # Проверяем, существует ли файл
    if [ -f "$FILE" ]; then
        # Определяем директорию и имя файла
        FILE_DIR=$(dirname "$FILE")
        FILE_NAME=$(basename "$FILE")
        
        # Определяем целевую директорию и целевой файл
        DEST_DIR="$TARGET_DIR/$FILE_DIR"
        DEST_FILE="$DEST_DIR/$FILE_NAME"
        
        # Создаем директорию, если она не существует
        mkdir -p "$DEST_DIR"
        
        # Копируем файл в соответствующую подпапку
        cp "$FILE" "$DEST_FILE"
        echo "Скопирован файл: $FILE в $DEST_FILE"
        
        # Записываем информацию о копировании в лог-файл
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$TIMESTAMP: $FILE -> $DEST_FILE" >> "$LOG_FILE"
    else
        echo "Файл не найден: $FILE"
    fi
done

# Добавляем пустую строку в конец лог-файла
echo "" >> "$LOG_FILE"

echo "Готово!"