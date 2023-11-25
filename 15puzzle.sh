#!/bin/bash

# Функция для проверки завершения игры
game_completed() {
    local -a winning_board=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 " ")

    for ((i = 0; i < 16; i++)); do
        if [[ ${board[$i]} != ${winning_board[$i]} ]]; then
            return 1
        fi
    done

    return 0
}

# Функция для вывода игрового поля
print_board() {
    echo "+-------------------+"
    for ((i = 0; i < 16; i += 4)); do
        printf "| %2s | %2s | %2s | %2s |\n" "${board[$i]:-" "}" "${board[$i + 1]:-" "}" "${board[$i + 2]:-" "}" "${board[$i + 3]:-" "}"
        echo "+-------------------+"
    done
}

# Функция для перемешивания пазла
shuffle_board() {
    local -a numbers=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 " ")
    local n=${#numbers[@]}

    for ((i = n - 1; i > 0; i--)); do
        j=$((RANDOM % (i + 1)))
        temp=${numbers[i]}
        numbers[i]=${numbers[j]}
        numbers[j]=$temp
    done

    board=("${numbers[@]}")
}

# Инициализация игры
shuffle_board
moves=0

# Основной цикл игры
while true; do
    clear
    echo "Ход № $moves"
    print_board

    if game_completed; then
        echo -e "\nВы собрали головоломку за $moves ходов.\n"
        exit 0
    fi

    echo -n "Ваш ход (q - выход): "
    read -r input

    if [[ $input == "q" ]]; then
        echo -e "\nИгра завершена."
        exit 0
    fi

    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        echo "Неверный ввод! Введите число от 1 до 15 или 'q' для выхода."
        sleep 2
        continue
    fi

    if [[ ! " ${board[*]} " =~ " $input " ]]; then
        echo "Неверный ход! Введите число из доступных: ${board[*]}"
        sleep 2
        continue
    fi

    index=0
    empty_index=0

    for ((i = 0; i < 16; i++)); do
        if [[ ${board[$i]} == " " ]]; then
            empty_index=$i
        fi
    done

    for ((i = 0; i < 16; i++)); do
        if [[ ${board[$i]} == "$input" ]]; then
            index=$i
            break
        fi
    done

    row=$((index / 4))
    col=$((index % 4))
    empty_row=$((empty_index / 4))
    empty_col=$((empty_index % 4))

    if ! ((row == empty_row && (col - 1 == empty_col || col + 1 == empty_col) || col == empty_col && (row - 1 == empty_row || row + 1 == empty_row))); then
        echo "Неверный ход! Нельзя передвинуть костяшку $input на пустую ячейку."
        sleep 2
        continue
    fi

    board[empty_index]=${board[index]}
    board[index]=" "
    ((moves++))
done
