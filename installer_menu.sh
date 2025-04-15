#!/bin/bash

echo "📦 Raspberry Pi Installer Menu"
echo "-----------------------------"
echo "[1] Εγκατάσταση status.sh (Telegram)"
echo "[2] Έλεγχος κάρτας SD (sd_health)"
echo "[3] Update status.sh από GitHub"
echo "[4] Έξοδος"
echo "-----------------------------"
read -p "➤ Επιλογή: " choice

ask_token_and_id() {
  echo "🔑 Δεν βρέθηκε σωστό token ή ID. Παρακαλώ συμπλήρωσε:"
  read -p "📬 Telegram Bot Token: " TOKEN
  echo "$TOKEN" > /home/pi/.telegram_token

  read -p "🆔 Telegram Chat ID: " CHAT_ID
  echo "$CHAT_ID" > /home/pi/.telegram_id
}

check_token_and_id() {
  [[ ! -s /home/pi/.telegram_token ]] && return 1
  [[ ! -s /home/pi/.telegram_id ]] && return 1
  return 0
}

send_test_message() {
  TOKEN=$(cat /home/pi/.telegram_token)
  CHAT_ID=$(cat /home/pi/.telegram_id)
  MSG="✅ Το status.sh εγκαταστάθηκε με επιτυχία στο $(hostname)"
  curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$MSG" | grep -q '"ok":true'
  return $?
}

case $choice in
  1)
    echo "📥 Λήψη status.sh από GitHub..."
    wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh -O /home/pi/status.sh
    chmod +x /home/pi/status.sh

    # Έλεγχος για token & id
    check_token_and_id || ask_token_and_id

    # Έλεγχος αν στέλνει όντως
    if send_test_message; then
      echo "✅ Ελέγχθηκε σύνδεση με Telegram!"
    else
      echo "⚠️ Το μήνυμα απέτυχε. Ξανασυμπλήρωσε:"
      ask_token_and_id
      send_test_message && echo "✅ Τώρα όλα καλά!" || echo "❌ Απέτυχε ξανά."
    fi
    ;;
  2)
    echo "📥 Λήψη ελέγχου κάρτας SD..."
    wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/install_sd_check.sh -O install_sd_check.sh
    chmod +x install_sd_check.sh
    ./install_sd_check.sh
    ;;
  3)
    echo "🔄 Ενημέρωση του status.sh από GitHub..."
    wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh -O /home/pi/status.sh
    chmod +x /home/pi/status.sh
    echo "✅ Έγινε ενημέρωση!"
    ;;
  4)
    echo "👋 Έξοδος..."
    exit 0
    ;;
  *)
    echo "❌ Μη έγκυρη επιλογή."
    ;;
esac
