#!/bin/bash

# Выполняем git add .
git add .

# Просим пользователя ввести название коммита
echo "Введите название коммита:"
read COMMIT_MESSAGE

# Выполняем коммит с введенным названием
git commit -m "$COMMIT_MESSAGE"

# Выводим сообщение об успешном выполнении
echo "Коммит успешно создан: $COMMIT_MESSAGE"