#!/bin/bash

# 📡 Πληροφορίες συστήματος
HOST=$(hostname)
TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
UPTIME=$(uptime -p | cut -d " " -f2-)

# 🖥️ HDMI CHECK με ανάλυση από Crtc
HDMI_STATUS=""
CURRENT_PORT=""
CONNECTED=""
RESOLUTION=""

while read -r line; do
  if [[ "$line" == *"Connector"* && "$line" == *"HDMI-A-"* ]]; then
    CURRENT_PORT=$(echo "$line" | awk '{print $4}')
    if echo "$line" | grep -q "connected"; then
      CONNECTED="🟢 $CURRENT_PORT: συνδεδεμένο"
    else
      CONNECTED="🔴 $CURRENT_PORT: αποσυνδεδεμένο"
    fi
  elif [[ "$line" == *"Crtc"* && "$CONNECTED" != "" ]]; then
    RESOLUTION=$(echo "$line" | awk '{print $4}')
    HDMI_STATUS+="$CONNECTED - 🔢 Ανάλυση: $RESOLUTION"$'\n'
    CONNECTED=""
    RESOLUTION=""
  elif [[ -z "$line" && "$CONNECTED" != "" ]]; then
    HDMI_STATUS+="$CONNECTED"$'\n'
    CONNECTED=""
  fi
done < <(kmsprint 2>/dev/null)

# 📬 Telegram αποστολή
BOT_TOKEN=$(cat /home/pi/.telegram_token)
CHAT_ID=$(cat /home/pi/.telegram_id)

MSG="📡 $HOST"$'\n'"🌡️ $TEMP"$'\n'"🧠 RAM: $RAM"$'\n'"🔁 $UPTIME"$'\n'"🖥️ HDMI:"$'\n'"$HDMI_STATUS"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$MSG"
