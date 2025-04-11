#!/bin/bash

# 📡 Πληροφορίες συστήματος
HOST=$(hostname)
TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
UPTIME=$(uptime -p | cut -d " " -f2-)

# 🖥️ HDMI CHECK με fallback
HDMI_FILE=$(find /sys/class/drm/ -name "card*-HDMI-A-*/status" | head -n1)

if [ -f "$HDMI_FILE" ]; then
  HDMI_RAW=$(cat "$HDMI_FILE")
  if [ "$HDMI_RAW" == "connected" ]; then
    HDMI_STATUS="🟢 ΝΑΙ"
  else
    HDMI_STATUS="🔴 ΟΧΙ"
  fi
else
  HDMI_RAW=$(tvservice -s 2>/dev/null)
  if echo "$HDMI_RAW" | grep -q "HDMI"; then
    HDMI_STATUS="🟢 ΝΑΙ (tvservice)"
  else
    HDMI_STATUS="🔴 ΟΧΙ (tvservice)"
  fi
fi

# 📬 Telegram
BOT_TOKEN=$(cat /home/pi/.telegram_token)
CHAT_ID=$(cat /home/pi/.telegram_id)

MSG="📡 $HOST\n🌡️ $TEMP\n🧠 RAM: $RAM\n🔁 $UPTIME\n🖥️ HDMI: $HDMI_STATUS"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$MSG"


