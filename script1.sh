declare -i attempts=1
declare -i hits=0
declare -i misses=0
declare -a numbers
RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'

while :
do
    secret=${RANDOM: -1}
    echo "Step: ${attempts}"
    read -p "Please enter a number from 0 to 9 (q - quit): " guess
    if [[ "$guess" == "q" ]]; then
        break
    fi
    if ! [[ "$guess" =~ ^[0-9]$ ]]; then
        echo "Invalid input. Input must be a single number from 0 to 9. Please, retry!"
        continue
    fi
    if [ "$guess" == "$secret" ]; then
        number="${GREEN}${secret}${RESET}"
        ((hits++))
        echo "Hit! My number: $secret"
    else
        number="${RED}${secret}${RESET}"
        ((misses++))
        echo "Miss! My number: $secret"
    fi
    numbers+=(${number})
    hitrate=$((hits * 100 / attempts))
    missrate=$((misses * 100 / attempts))
    echo "Hit: ${hitrate}% Miss: ${missrate} %"
    echo "Last 10 items: "
    if [ ${#numbers[@]} -gt 10 ]; then
        start_idx=$(( ${#numbers[@]} - 10 ))
        for ((i = start_idx; i < ${#numbers[@]}; i++)); do
            echo -ne "${numbers[$i]} "
        done
    else
        echo -ne "${numbers[@]}"
    fi
    echo ""
    attempts+=1
done
