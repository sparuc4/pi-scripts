#!/bin/bash

clear
echo "📦 Πίνακας Εγκαταστάσεων Raspberry Pi"
echo "------------------------------------"
echo "[1] Εγκατάσταση status.sh (Telegram)"
echo "[2] Έλεγχος κάρτας SD (sd_health)"
echo "[3] Έξοδος"
echo "------------------------------------"
read -p "➤ Δώσε επιλογή: " choice

case $choice in
    1)
        echo "📥 Κατεβάζω το status.sh από το GitHub..."
        wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh -O status.sh
        chmod +x status.sh
        ./status.sh
        ;;
    2)
        echo "📥 Κατεβάζω το sd_health.sh από το GitHub..."
        wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/install_sd_check.sh -O install_sd_check.sh
        chmod +x install_sd_check.sh
        ./install_sd_check.sh
        ;;
    3)
        echo "👋 Έξοδος..."
        exit 0
        ;;
    *)
        echo "❌ Μη έγκυρη επιλογή."
        ;;
esac
