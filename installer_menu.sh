#!/bin/bash

while true; do
  echo -e "\n🛠 Επιλογές εγκατάστασης:\n"
  echo "1) Εγκατάσταση status.sh"
  echo "2) Εγκατάσταση sd_health_check.sh"
  echo "3) Έξοδος"
  echo -n "➤ Δώσε επιλογή (1-3): "
  read choice

  case $choice in
    1)
      echo "📥 Κατεβάζω το status.sh από το GitHub..."
      wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/status.sh -O status.sh
      chmod +x status.sh
      ./status.sh

    2)
      echo "⬇️ Κατεβαίνει το install_sd_check.sh..."
      wget -q https://raw.githubusercontent.com/sparuc4/pi-scripts/main/install_sd_check.sh -O install_sd_check.sh
      bash install_sd_check.sh
      ;;
    3)
      echo "👋 Έξοδος..."
      exit 0
      ;;
    *)
      echo "⚠️ Μη έγκυρη επιλογή"
      ;;
  esac
done
