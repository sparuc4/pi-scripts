#!/bin/bash

# 📡 Πληροφορίες συστήματος
HOST=$(hostname)
TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
UPTIME=$(uptime -p | cut -d " " -f2-)

# 🖥️ HDMI CHECK με kmsprint (για vc4-kms-v3d)
HDMI_RAW=$(kmsprint 2>/dev/null | grep -A1 "HDMI-A" | grep "connected")

if [ -n "$HDMI_RAW" ]; then
  HDMI_STATUS="🟢 ΝΑΙ (kmsprint)"
else
  HDMI_STATUS="🔴 ΟΧΙ (kmsprint)"
fi

# 📬 Telegram
BOT_TOKEN=$(cat /home/pi/.telegram_token)
CHAT_ID=$(cat /home/pi/.telegram_id)

MSG="📡 $HOST\n🌡️ $TEMP\n🧠 RAM: $RAM\n🔁 $UPTIME\n🖥️ HDMI: $HDMI_STATUS"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$MSG"
