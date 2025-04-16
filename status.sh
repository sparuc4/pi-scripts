#!/bin/bash

# --- Έλεγχος για νεότερη έκδοση ---
LOCAL_VERSION="2.1.3"
SCRIPT_PATH="/home/pi/status.sh"
REMOTE_URL="https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh"
REMOTE_VERSION=$(curl -s "$REMOTE_URL" | grep '^LOCAL_VERSION=' | cut -d '"' -f2)

if [[ "$REMOTE_VERSION" != "$LOCAL_VERSION" && -n "$REMOTE_VERSION" ]]; then
  echo "🌀 Νεότερη έκδοση $REMOTE_VERSION διαθέσιμη. Κάνω ενημέρωση από $REMOTE_URL..."
  curl -s "$REMOTE_URL" -o "$SCRIPT_PATH"
  chmod +x "$SCRIPT_PATH"
  exec "$SCRIPT_PATH"
  exit 0
fi

# --- Συλλογή Πληροφοριών ---
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

# --- Δημιουργία JSON για Panel ---
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

# --- Αποστολή στο Telegram ---
BOT_TOKEN=$(cat /home/pi/.telegram_token 2>/dev/null)
CHAT_ID=$(cat /home/pi/.telegram_id 2>/dev/null)

if [[ -n "$BOT_TOKEN" && -n "$CHAT_ID" ]]; then
  HDMI_LINE=$(echo "$HDMI_JSON" | grep -o '"port":"[^"]*","status":"connected","resolution":"[^"]*"' | head -n1 | sed 's/","/\n/g' | sed 's/"/ /g' | tr -d '{}')
  MSG="📡 $HOST
🌡️ CPU Temp: $TEMP
🧠 RAM: $RAM
🔁 Uptime: $UPTIME
🖥️ CPU %: $CPU_USAGE
📺 HDMI: $HDMI_LINE
📦 Script Version: $LOCAL_VERSION"

  curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -d chat_id="$CHAT_ID" \
    -d text="$MSG"
fi
