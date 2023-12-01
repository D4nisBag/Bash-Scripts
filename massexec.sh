#!/bin/bash

# Проверка аргументов командной строки
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 [--path dirpath] [--mask mask] [--number number] command"
    exit 1
fi

dirpath=$(pwd)
mask="*"
number=$(nproc)

# Обработка опций командной строки
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --path)
            dirpath="$2"
            shift 2
            ;;
        --mask)
            mask="$2"
            shift 2
            ;;
        --number)
            number="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

command="$@"

# Проверка существования директории
if [[ ! -d "$dirpath" ]]; then
    echo "Directory $dirpath does not exist."
    exit 1
fi

# Получение списка файлов для обработки
files_to_process=("$dirpath"/$mask)
files_count=${#files_to_process[@]}

# Переменная для отслеживания запущенных процессов
running_processes=0

# Функция для обработки файлов
process_files() {
    local file="$1"
    # Проверка на регулярный файл
    if [[ -f "$file" ]]; then
        "$command" "$file" &
        ((running_processes++))
    fi
}

# Обработка файлов
for file in "${files_to_process[@]}"; do
    process_files "$file"

    if [[ $running_processes -ge $number ]]; then
        wait
        running_processes=0
    fi
done

wait # Ожидание завершения всех запущенных процессов
