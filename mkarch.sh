while getopts ":d:n:" opt; do
  case $opt in
    d) dir_path=$OPTARG ;;
    n) name=$OPTARG ;;
    \?) echo "Неверно введена опция: -$OPTARG" >&2; exit 1 ;;
    :) echo "Опция -$OPTARG должна содержать непустое значение" >&2; exit 1 ;;
  esac
done
if [ -z "$dir_path" ] || [ -z "$name" ]; then
  echo "Успешно введена команда: $0 -d <dir_path> -n <name>"
  exit 1
fi
# Создание tar архива и сжатие gzip
tar -czf temp.tar.gz "$dir_path"
# Кодирование архива в base64
encoded_archive=$(base64 -w 0 temp.tar.gz)
# Создание скрипта $name
cat > "$name" <<EOF
#!/bin/bash
unpack_dir=\${2:-"."}
# Проверка наличия архива в скрипте
if [ -f "\$0" ]; then
  tail -n +\$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "\$0") "\$0" | base64 -d | tar -xz -C "\$unpack_dir"
else
  echo "Ошибка, невозможно обнаружить архив."
  exit 1
fi
exit 0
__ARCHIVE_BELOW__
$encoded_archive
EOF
# Установка прав на исполнение создаваемого файла
chmod +x "$name"
# Очистка временного файла
rm temp.tar.gz
echo "Самораспакующийся архив $name успешно создан."
exit 0
