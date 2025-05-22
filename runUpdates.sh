#!/bin/bash

# =================================================================================================================
# === About:     Script for updating all packages         
# === Author:    AlexVezo
# === Date:      17.12.2024
# === Version:   v2
# === Licence:   MIT
# =================================================================================================================

echo "# ==========================================================================================================="
echo "# === INIT: Ensure the script is being run as root                                                           "
echo "# ==========================================================================================================="

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as superuser"
  sleep 5
  exit
fi

if [ "$(id -u)" -eq 0 ]; then
  echo "Check OK: You are running the updates as admin"
  sleep 2
fi

echo "# ==========================================================================================================="
echo "# === Step 0: check that logfile exists, write basic infos to logfile                                        "
echo "# ==========================================================================================================="
LOGFILE="/home/superuser/Skripte/Updates/log/$(date +'%Y-%m-%d_%H-%M-%S')_ManualUpdateLogfile.log"    # ENABLE  LOGFILE => write to logfile
#LOGFILE="/dev/null"                                                                                  # DISABLE LOGFILE => "write into void"

# Create the log file if it doesn't exist
if [ ! -f "$LOGFILE" ]; then
  if [ "$LOGFILE" != "/dev/null" ]; then
    touch "$LOGFILE"
    chmod 644 "$LOGFILE"
  fi
fi

echo "###################################################################################################################################################" | tee -a "$LOGFILE"
echo "### System Update Process Started. System Information:                                                                                             " | tee -a "$LOGFILE"
echo "###################################################################################################################################################" | tee -a "$LOGFILE"
echo "Kernel info: $(uname -a)"                    >> $LOGFILE       # Kernel and OS info
echo "Uptime:      $(uptime)"                      >> $LOGFILE       # uptime
echo "Free Memory: $(free -h)"                     >> $LOGFILE       # free memory
echo "Disk Usage:  $(df -h /)"                     >> $LOGFILE       # disk usage
echo "Time:        $(date '+%Y-%m-%d %H:%M:%S')"   >> $LOGFILE       # date

echo "# ===========================================================================================================" | tee -a "$LOGFILE"
echo "# === Step 1: update dnf packages                                                                            " | tee -a "$LOGFILE"
echo "# ===========================================================================================================" | tee -a "$LOGFILE"
sudo apt update       -y | tee -a "$LOGFILE"  # Paketquellen aktualiseren
sudo apt upgrade      -y | tee -a "$LOGFILE"  # Updates anwenden
sudo apt clean        -y | tee -a "$LOGFILE"  # Nicht benötigte Pakete entfernen 
sudo apt autoremove   -y | tee -a "$LOGFILE"  # Nicht benötigte Pakete entfernen

echo "# ===========================================================================================================" | tee -a "$LOGFILE"
echo "# === Step 2: update snap packages                                                                           " | tee -a "$LOGFILE"
echo "# ===========================================================================================================" | tee -a "$LOGFILE"
sudo snap refresh        #| tee -a "$LOGFILE"  # Snaps:   update all

echo "# ===========================================================================================================" | tee -a "$LOGFILE"
echo "# === Step 3: update flatpak packages                                                                        " | tee -a "$LOGFILE"
echo "# ===========================================================================================================" | tee -a "$LOGFILE"
flatpak update -y        | tee -a "$LOGFILE"  # flatpak: update all

echo "# ===========================================================================================================" | tee -a "$LOGFILE"
echo "# === Step 4: Update ClamAV                                                                                  " | tee -a "$LOGFILE"
echo "# ===========================================================================================================" | tee -a "$LOGFILE"
sudo freshclam           | tee -a "$LOGFILE"  # clamAV:  update database

echo "# ===========================================================================================================" | tee -a "$LOGFILE"
echo "# === Finish - Wait 5sec and close window then                                                               " | tee -a "$LOGFILE"
echo "# ===========================================================================================================" | tee -a "$LOGFILE"
echo "Finish Time: $(date '+%Y-%m-%d %H:%M:%S')" >> $LOGFILE

sleep 5
exit
