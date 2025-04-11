#!/bin/bash

HOST=$(hostname)
TEMP=$(vcgencmd measure_temp | cut -d "=" -f2)
RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
UPTIME=$(uptime -p | cut -d " " -f2-)

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

HDMI_JSON="[${HDMI_JSON%,}]"  # Αφαίρεση τελευταίου κόμματος

cat <<EOF > /home/pi/status.json
{
  "hostname": "$HOST",
  "temperature": "$TEMP",
  "ram": "$RAM",
  "uptime": "$UPTIME",
  "hdmi": $HDMI_JSON
}
EOF
