#!/bin/bash

echo "🔐 Πληκτρολόγησε το Telegram BOT TOKEN:"
read -r BOT_TOKEN

echo "📩 Πληκτρολόγησε το Telegram CHAT ID:"
read -r CHAT_ID

TARGET="/home/pi/status.sh"

echo "⚙️ Δημιουργείται το $TARGET..."

cat <<EOF > "$TARGET"
#!/bin/bash

BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"
HOST=\$(hostname)
TEMP=\$(vcgencmd measure_temp | cut -d "=" -f2)
RAM=\$(free -h | awk '/^Mem:/ {print \$3 "/" \$2 " used"}')
UPTIME=\$(uptime -p | sed 's/up //')

MSG="📡 \$HOST\n🌡️ \$TEMP\n🧠 RAM: \$RAM\n🔁 \$UPTIME"
# HDMI Check
if tvservice -s | grep -q "HDMI"; then
  HDMI_STATUS="🟢 ΝΑΙ"
else
  HDMI_STATUS="🔴 ΟΧΙ"
fi

MSG+="\n🖥️ HDMI: $HDMI_STATUS"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$MSG"
EOF

chmod +x "$TARGET"

echo "✅ Το status.sh δημιουργήθηκε με επιτυχία."
echo "🚀 Εκτελείται δοκιμαστικά..."

bash "$TARGET"
