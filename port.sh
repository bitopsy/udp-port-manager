#!/usr/bin/env bash

PORT=8452

usage() {
    echo "Usage: sudo ./port.sh [open|close|check]"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

ACTION="$1"

# Require root/sudo for open and close actions
if [ "$ACTION" = "open" ] || [ "$ACTION" = "close" ]; then
    if [ "$EUID" -ne 0 ]; then
        echo "[-] Please run 'open' or 'close' with sudo: sudo ./port.sh $ACTION"
        exit 1
    fi
fi

case "$ACTION" in
    open)
        echo "[+] Opening UDP port $PORT..."
        if ! command -v ufw &> /dev/null; then
            echo "[*] Installing UFW..."
            apt update && apt install -y ufw
        fi
        
        UFW_STATUS=$(ufw status | grep "Status:" | awk '{print $2}')
        if [ "$UFW_STATUS" != "active" ]; then
            echo "[*] Enabling UFW (allowing SSH first)..."
            ufw allow ssh
            ufw --force enable
        fi
        
        ufw allow "$PORT/udp"
        ufw reload
        echo "[+] Success! UDP port $PORT is now open in UFW."
        ;;
    close)
        echo "[+] Closing UDP port $PORT..."
        ufw delete allow "$PORT/udp"
        ufw reload
        echo "[+] Success! UFW rule for UDP port $PORT removed."
        ;;
    check)
        echo "[*] Checking status of UDP port $PORT..."
        echo "------------------------------------------"
        
        # 1. Check UFW status
        if command -v ufw &> /dev/null; then
            UFW_RULE=$(ufw status | grep "$PORT/udp")
            if [ -n "$UFW_RULE" ]; then
                echo "[+] Firewall Rule: Active ($UFW_RULE)"
            else
                echo "[-] Firewall Rule: Not found for port $PORT/udp."
            fi
        else
            echo "[-] UFW is not installed."
        fi

        # 2. Check if a local process is listening on the port
        echo ""
        echo "[*] Checking local listeners:"
        LISTENING=$(ss -uln | grep ":$PORT")
        if [ -n "$LISTENING" ]; then
            echo "[+] Local Listener: Active"
            echo "    $LISTENING"
        else
            echo "[-] Local Listener: No app is currently listening on UDP port $PORT."
            echo "    (Make sure your game server is running so it can bind to the port!)"
        fi
        echo "------------------------------------------"
        ;;
    *)
        usage
        ;;
esac
