#!/bin/bash

# 📡 Πληροφορίες συστήματος
HOST=$(hostname)
TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
UPTIME=$(uptime -p | cut -d " " -f2-)

# 🖥️ HDMI έλεγχος (για νέο driver)
HDMI_PATH="/sys/class/drm/card0-HDMI-A-1/status"
if [ -f "$HDMI_PATH" ]; then
  HDMI_RAW=$(cat $HDMI_PATH)
  if [ "$HDMI_RAW" == "connected" ]; then
    HDMI_STATUS="🟢 ΝΑΙ"
  else
    HDMI_STATUS="🔴 ΟΧΙ"
  fi
else
  HDMI_STATUS="❓ Άγνωστο"
fi

# 📬 Ανάγνωση Telegram στοιχείων
BOT_TOKEN=$(cat /home/pi/.telegram_token)
CHAT_ID=$(cat /home/pi/.telegram_id)

# 📝 Μήνυμα
MSG="📡 $HOST\n🌡️ $TEMP\n🧠 RAM: $RAM\n🔁 $UPTIME\n🖥️ HDMI: $HDMI_STATUS"

# 🚀 Αποστολή στο Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$MSG"
