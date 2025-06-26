#!/data/data/com.termux/files/usr/bin/bash

# Цвета для вывода
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Функция проверки зависимостей
check_dependencies() {
    echo -e "${YELLOW}[*] Проверка и установка зависимостей...${NC}"
    pkg update -y && pkg upgrade -y
    pkgs=("curl" "python" "shadowsocks-libev" "obfs4" "tor" "dnscrypt-proxy" "speedtest-cli" "jq")
    for pkg in "${pkgs[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            echo -e "${BLUE}[+] Установка $pkg...${NC}"
            pkg install -y "$pkg" || {
                echo -e "${RED}[-] Ошибка установки $pkg!${NC}"
                exit 1
            }
        fi
    done
    pip install --upgrade pip
    pip install speedtest-cli requests
}

# Функция диагностики сети
network_test() {
    echo -e "${YELLOW}[*] Запуск диагностики сети...${NC}"
    
    # Ping до Google
    echo -e "${BLUE}[→] Ping до 8.8.8.8:${NC}"
    ping -c 4 8.8.8.8 | tail -n 2
    
    # Скорость интернета (speedtest-cli)
    echo -e "${BLUE}[→] Тест скорости:${NC}"
    speedtest-cli --simple
    
    # Определение провайдера (через ipinfo.io)
    echo -e "${BLUE}[→] Информация о провайдере:${NC}"
    curl -s ipinfo.io | jq '.org, .country, .city'
    
    # Jitter (разница в задержках)
    echo -e "${BLUE}[→] Jitter (разброс ping):${NC}"
    ping -c 10 8.8.8.8 | awk -F'/' 'END {print "Средний: "$5"ms | Jitter: "$6"ms"}'
}

# Меню выбора режима
show_menu() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════╗"
    echo "║    МЕНЮ ОБХОДА БЛОКИРОВОК        ║"
    echo "╠══════════════════════════════════╣"
    echo "║ 1. Обход всего трафика           ║"
    echo "║ 2. Только YouTube                ║"
    echo "║ 3. Только Discord                ║"
    echo "║ 4. Только Telegram               ║"
    echo "║ 5. Настроить вручную             ║"
    echo "║ 6. Помощь                       ║"
    echo "║ 7. О программе                   ║"
    echo "║ 0. Выход                         ║"
    echo "╚══════════════════════════════════╣"
    echo -e "${NC}"
}

# Методы обхода
select_method() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════╗"
    echo "║    ВЫБОР МЕТОДА ОБХОДА           ║"
    echo "╠══════════════════════════════════╣"
    echo "║ 1. Shadowsocks + obfs4 (рекоменд.)║"
    echo "║ 2. Tor с мостами                 ║"
    echo "║ 3. DNS-over-HTTPS (DoH)          ║"
    echo "║ 4. WireGuard + udp2raw           ║"
    echo "║ 5. Автоматический выбор          ║"
    echo "╚══════════════════════════════════╣"
    echo -e "${NC}"
    read -p "Выберите метод: " method
    case $method in
        1) start_shadowsocks ;;
        2) start_tor ;;
        3) start_doh ;;
        4) start_wireguard ;;
        5) start_auto ;;
        *) echo -e "${RED}Неверный выбор!${NC}" ;;
    esac
}

# Запуск Shadowsocks + obfs4
start_shadowsocks() {
    echo -e "${YELLOW}[*] Запуск Shadowsocks с obfs4...${NC}"
    ss-server -s 0.0.0.0 -p 8388 -k "your_password" -m aes-256-gcm --plugin obfs-server --plugin-opts "obfs=http" &
    echo -e "${GREEN}[+] Готово! Настрой клиент на адрес 127.0.0.1:8388.${NC}"
}

# Запуск Tor с мостами
start_tor() {
    echo -e "${YELLOW}[*] Запуск Tor с мостами...${NC}"
    tor &
    echo -e "${GREEN}[+] Готово! Используй SOCKS5 на 127.0.0.1:9050.${NC}"
}

# Основная логика
main() {
    check_dependencies
    network_test
    while true; do
        show_menu
        read -p "Выберите действие: " choice
        case $choice in
            1) select_method ;;
            2) echo "Режим: Только YouTube" ;;
            3) echo "Режим: Только Discord" ;;
            4) echo "Режим: Только Telegram" ;;
            5) echo "Ручная настройка..." ;;
            6) echo "Помощь: ..." ;;
            7) echo "О программе: ..." ;;
            0) exit 0 ;;
            *) echo -e "${RED}Неверный выбор!${NC}" ;;
        esac
    done
}

main