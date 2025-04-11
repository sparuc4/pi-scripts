#!/bin/bash

# 📡 Πληροφορίες συστήματος
HOST=$(hostname)
TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
UPTIME=$(uptime -p | cut -d " " -f2-)

# 🖥️ HDMI CHECK με ανάλυση μέσω kmsprint
HDMI_BLOCK=$(kmsprint 2>/dev/null | grep -A3 "HDMI-A")

HDMI_STATUS=""
CURRENT_PORT=""

while read -r line; do
  if echo "$line" | grep -q "HDMI-A"; then
    CURRENT_PORT=$(echo "$line" | awk '{print $4}')
    if echo "$line" | grep -q "connected"; then
      STATUS="🟢 $CURRENT_PORT: συνδεδεμένο"
    else
      STATUS="🔴 $CURRENT_PORT: αποσυνδεδεμένο"
    fi
    HDMI_STATUS+="$STATUS"
  elif [[ $line == *"Mode:"* ]]; then
    RES=$(echo "$line" | awk '{print $2}')
    HDMI_STATUS+=" - 🔢 Ανάλυση: $RES\n"
  fi
done <<< "$HDMI_BLOCK"

# 📬 Telegram
BOT_TOKEN=$(cat /home/pi/.telegram_token)
CHAT_ID=$(cat /home/pi/.telegram_id)

MSG="📡 $HOST\n🌡️ $TEMP\n🧠 RAM: $RAM\n🔁 $UPTIME\n🖥️ HDMI:\n$HDMI_STATUS"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$MSG"

