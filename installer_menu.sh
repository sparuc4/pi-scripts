#!/bin/bash

while true; do
  clear
  echo "🛠️  Raspberry Pi Installer Menu"
  echo "1) Εγκατάσταση status.sh"
  echo "2) Έλεγχος SD Card (check_sd_health)"
  echo "3) Έξοδος"
  echo
  read -p "Επιλέξτε μια επιλογή [1-3]: " choice

  case $choice in
    1)
      echo "📥 Κατεβάζω το status.sh από το GitHub..."
      wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh -O /home/pi/status.sh
      chmod +x /home/pi/status.sh

      if [[ ! -f /home/pi/.telegram_token || ! -f /home/pi/.telegram_id ]]; then
        echo "🔐 Εισάγετε το Telegram BOT TOKEN:"
        read -r TOKEN
        echo "$TOKEN" > /home/pi/.telegram_token

        echo "👤 Εισάγετε το Telegram CHAT ID:"
        read -r ID
        echo "$ID" > /home/pi/.telegram_id
      fi

      echo "✅ Το status.sh εγκαταστάθηκε/ενημερώθηκε."
      echo "🚀 Εκτελείται δοκιμαστικά..."
      /home/pi/status.sh
      read -p "👉 Πάτησε Enter για επιστροφή στο μενού..."
      ;;
    2)
      echo "📥 Κατεβάζω το check_sd_health_telegram.sh από το GitHub..."
      wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/check_sd_health_telegram.sh -O /home/pi/check_sd_health_telegram.sh
      chmod +x /home/pi/check_sd_health_telegram.sh

      if [[ ! -f /home/pi/.telegram_token || ! -f /home/pi/.telegram_id ]]; then
        echo "🔐 Εισάγετε το Telegram BOT TOKEN:"
        read -r TOKEN
        echo "$TOKEN" > /home/pi/.telegram_token

        echo "👤 Εισάγετε το Telegram CHAT ID:"
        read -r ID
        echo "$ID" > /home/pi/.telegram_id
      fi

      echo "✅ Το check_sd_health_telegram.sh εγκαταστάθηκε/ενημερώθηκε."
      echo "🚀 Εκτελείται δοκιμαστικά..."
      /home/pi/check_sd_health_telegram.sh
      read -p "👉 Πάτησε Enter για επιστροφή στο μενού..."
      ;;
    3)
      echo "👋 Έξοδος από το μενού. Καλή συνέχεια!"
      break
      ;;
    *)
      echo "❌ Μη έγκυρη επιλογή."
      sleep 1
      ;;
  esac
done
