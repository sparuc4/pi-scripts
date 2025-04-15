#!/bin/bash

clear
echo "📦 Πίνακας Εγκαταστάσεων Raspberry Pi"
echo "------------------------------------"
echo "[1] Εγκατάσταση status.sh (Telegram)"
echo "[2] Έλεγχος κάρτας SD (sd_health)"
echo "[3] Έξοδος"
echo "[4] 🔁 Μόνο Ενημέρωση scripts (χωρίς εκτέλεση)"
echo "------------------------------------"
read -p "➤ Δώσε επιλογή: " choice

case $choice in
    1)
        echo "📥 Κατεβάζω το status.sh από το GitHub..."
        wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh -O /home/pi/status.sh
        chmod +x /home/pi/status.sh
        echo "✅ Το status.sh εγκαταστάθηκε."
        echo "🚀 Εκτελείται δοκιμαστικά..."
        /home/pi/status.sh
        ;;
    2)
        echo "📥 Κατεβάζω το check_sd_health_telegram.sh από το GitHub..."
        wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/check_sd_health_telegram.sh -O /home/pi/check_sd_health_telegram.sh
        chmod +x /home/pi/check_sd_health_telegram.sh
        echo "✅ Το check_sd_health_telegram.sh εγκαταστάθηκε."
        echo "🚀 Εκτελείται δοκιμαστικά..."
        /home/pi/check_sd_health_telegram.sh
        ;;
    3)
        echo "👋 Έξοδος..."
        exit 0
        ;;
    4)
        echo "🔄 Ενημέρωση status.sh και sd_check χωρίς εκτέλεση..."
        wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh -O /home/pi/status.sh
        chmod +x /home/pi/status.sh
        wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/check_sd_health_telegram.sh -O /home/pi/check_sd_health_telegram.sh
        chmod +x /home/pi/check_sd_health_telegram.sh
        echo "✅ Τα scripts ενημερώθηκαν επιτυχώς!"
        ;;
    *)
        echo "❌ Μη έγκυρη επιλογή."
        ;;
esac
