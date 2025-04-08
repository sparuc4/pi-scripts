#!/bin/bash

echo "🔐 Telegram BOT TOKEN:"
read -r BOT_TOKEN

echo "📩 Telegram CHAT ID:"
read -r CHAT_ID

TARGET="/home/pi/check_sd_health_telegram.sh"

echo "⚙️ Δημιουργείται το $TARGET..."

cat <<EOF > "$TARGET"
#!/bin/bash

BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"
HOST=\$(hostname)

FSCK_STATUS=\$(sudo fsck -n /dev/mmcblk0p2 | grep -i 'clean' | head -n1)
DMESG_ERRORS=\$(dmesg | grep -iE "error|fail|corrupt" | tail -n 5)

MSG="📀 Έλεγχος SD στο \$HOST\n\n🧹 FSCK: \$FSCK_STATUS"

if [ -z "\$DMESG_ERRORS" ]; then
  MSG="\$MSG\n🧾 dmesg: OK"
else
  MSG="\$MSG\n⚠️ dmesg:\n\$DMESG_ERRORS"
fi

curl -s -X POST https://api.telegram.org/bot\$BOT_TOKEN/sendMessage \\
  -d chat_id="\$CHAT_ID" \\
  -d text="\$MSG"
EOF

chmod +x "$TARGET"

echo "✅ Δημιουργήθηκε το check_sd_health_telegram.sh"
echo "🚀 Εκτελείται δοκιμαστικά..."

bash "$TARGET"
