#!/bin/bash

HOST=$(hostname)
TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
UPTIME=$(uptime -p | cut -d " " -f2-)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}')

HDMI_JSON=""
CURRENT_PORT=""
CONNECTED=""
RESOLUTION=""

while read -r line; do
  if [[ "$line" == *"Connector"* && "$line" == *"HDMI-A-"* ]]; then
    CURRENT_PORT=$(echo "$line" | awk '{print $4}')
    if echo "$line" | grep -q "connected"; then
      CONNECTED="connected"
    else
      CONNECTED="disconnected"
    fi
  elif [[ "$line" == *"Crtc"* && "$CONNECTED" == "connected" ]]; then
    RESOLUTION=$(echo "$line" | awk '{print $4}')
    HDMI_JSON+="{\"port\":\"$CURRENT_PORT\",\"status\":\"$CONNECTED\",\"resolution\":\"$RESOLUTION\"},"
    CONNECTED=""
    RESOLUTION=""
  elif [[ -z "$line" && "$CONNECTED" != "" ]]; then
    HDMI_JSON+="{\"port\":\"$CURRENT_PORT\",\"status\":\"$CONNECTED\"},"
    CONNECTED=""
  fi
done < <(kmsprint 2>/dev/null)

HDMI_JSON="[${HDMI_JSON%,}]"

cat <<EOF > /home/pi/status.json
{
  "hostname": "$HOST",
  "temperature": "$TEMP",
  "ram": "$RAM",
  "uptime": "$UPTIME",
  "cpu_temp": "$TEMP",
  "cpu_usage": "$CPU_USAGE",
  "hdmi": $HDMI_JSON
}
EOF

# Optional: Telegram
BOT_TOKEN=$(cat /home/pi/.telegram_token 2>/dev/null)
CHAT_ID=$(cat /home/pi/.telegram_id 2>/dev/null)

if [[ -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
  HDMI_LINE=$(echo "$HDMI_JSON" | grep -o '"port":"[^"]*","status":"connected","resolution":"[^"]*"' | head -n1 | sed 's/","/\n/g' | sed 's/"/ /g' | tr -d '{}')
  MSG="📡 $HOST
🌡️ $TEMP
🧠 RAM: $RAM
🔁 $UPTIME
🖥️ HDMI: $HDMI_LINE"

  curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -d chat_id="$CHAT_ID" \
    -d text="$MSG"
fi
