#!/bin/bash

TARGET="/home/pi/status.sh"
TOKEN_FILE="/home/pi/.telegram_token"
ID_FILE="/home/pi/.telegram_id"

# Ρώτα μόνο αν δεν υπάρχουν ήδη αποθηκευμένα
if [ ! -f "$TOKEN_FILE" ]; then
  read -p "🔑 Telegram Bot Token: " BOT_TOKEN
  echo "$BOT_TOKEN" > "$TOKEN_FILE"
else
  BOT_TOKEN=$(cat "$TOKEN_FILE")
fi

if [ ! -f "$ID_FILE" ]; then
  read -p "🆔 Telegram Chat ID: " CHAT_ID
  echo "$CHAT_ID" > "$ID_FILE"
else
  CHAT_ID=$(cat "$ID_FILE")
fi

echo "📥 Κατεβάζω το status.sh από το GitHub..."
wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh -O "$TARGET"

# Έλεγχος αν κατέβηκε σωστά
if [ $? -ne 0 ]; then
  echo "❌ Αποτυχία λήψης status.sh"
  exit 1
fi

chmod +x "$TARGET"

echo "✅ Το status.sh εγκαταστάθηκε/ενημερώθηκε."
echo "🚀 Εκτελείται δοκιμαστικά..."

bash "$TARGET"
