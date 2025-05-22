#!/bin/bash

# =================================================================================================================
# === About:     Installationsskript für Laptops
# === Author:    AlexVezo
# === Date:      17.12.2024
# === Version:   v4
# === Licence:   MIT
# =================================================================================================================

# =================================================================================================================
# === Step 0: Ensure the script is being run as root
# =================================================================================================================
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root."
  exit 10
fi

# =================================================================================================================
# === Step 1: Update all 
# =================================================================================================================

# ----------------------------------------------------------------------------------------
# --- apt
# ----------------------------------------------------------------------------------------
sudo apt update       -y # Paketquellen aktualiseren
sudo apt upgrade      -y # Updates anwenden
sudo apt dist-upgrade -y # Alle Updates anwenden
sudo apt clean        -y # Nicht benötigte Pakete entfernen 
sudo apt autoremove   -y # Nicht benötigte Pakete entfernen

# ----------------------------------------------------------------------------------------
# --- snap
# ----------------------------------------------------------------------------------------
sudo snap refresh        # Snaps:   update all

# ----------------------------------------------------------------------------------------
# --- flatpak
# ----------------------------------------------------------------------------------------
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak gnome-software -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak update -y          

# =================================================================================================================
# === Step 2: Install Software
# =================================================================================================================

# Library: Calibre, Zotero, JabRef
# Chat: WhatsApp / Signal
# MS Office: Outlook / Thunderbird, Teams, OneNote / Joplin / Obsidian + LibreOffice
# MathTools: Scilab Xcos Octave
# Tools: meld czkawka

sudo apt install synaptic anki scilab librecad shotcut octave meld pspp gparted curl gimp vlc -y
sudo apt install calibre texmaker lyx jabref gnome-shell-pomodoro -y

sudo snap install p3x-onenote          # Inofficial OneNote-Client 
sudo snap install teams-for-linux      # Inofficial Teams-Client 
sudo snap install prospect-mail        # Inofficial Outlook-Client 
sudo snap install whatsie              # Inofficial WhatsApp-Desktop-Client 

sudo snap install signal-desktop       
sudo snap install obsidian             
sudo snap install zotero-snap          
sudo snap install zenkit
sudo snap install czkawka               
sudo snap install pinta
sudo snap install drawio
sudo snap install duolingo-desktop
sudo snap install bitwarden

# Joplin (optional)
# sudo apt install libfuse2 -y
# wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

# eduVPN
curl --proto '=https' --tlsv1.2 https://docs.eduvpn.org/client/linux/install.sh -O  
bash ./install.sh

sudo apt-get autoremove  
sudo apt-get clean

# =================================================================================================================
# === Step 3: IT-Security
# =================================================================================================================

# ----------------------------------------------------------------------------------------------------------
# --- Step 1: Set up firewall  
# ----------------------------------------------------------------------------------------------------------
sudo apt install ufw gufw -y           # ufw + GUI for ufw

sudo ufw limit 22/tcp                  # SSH:   OK
sudo ufw allow 80/tcp                  # HTTP:  OK
sudo ufw allow 443/tcp                 # HTTPS: OK
sudo ufw default deny incoming         # default: disable port in
sudo ufw default allow outgoing        # default: disable port out
sudo ufw enable                        # apply changes

echo "Firewall wurde aktiviert"

# ----------------------------------------------------------------------------------------------------------
# --- Substep 2: Enable automatic updates
# ----------------------------------------------------------------------------------------------------------

# automatische Updates einrichten
sudo apt install -y unattended-upgrades apt-listchanges

cat <<EOF | sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null
APT::Periodic::Update-Package-Lists "$APT_LIST_UPDATE_INTERVAL";
APT::Periodic::Unattended-Upgrade "$UNATTENDED_UPGRADE_INTERVAL";
EOF

SECURITY_REPO="${distro_id}:${distro_codename}-security"

cat <<EOF | sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null
Unattended-Upgrade::Allowed-Origins {
    "$SECURITY_REPO";
EOF

echo "    \"${distro_id}:${distro_codename}-updates\";" | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null
echo "};" | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null

sudo unattended-upgrade --dry-run

# ----------------------------------------------------------------------------------------------------------
# --- Substep 3: Install password manager
# ----------------------------------------------------------------------------------------------------------
sudo apt install keepassxc -y

# ----------------------------------------------------------------------------------------------------------
# --- Substep 4: Install tool to wipe data on HDDs
# ----------------------------------------------------------------------------------------------------------
sudo apt install nautilus-wipe -y

# ----------------------------------------------------------------------------------------------------------
# --- Substep 5: Set up ClamAV as antivirus software 
# -----------------------------------------------------------------------------------------------------------

# clamAV und clamtk als Antivirus-Software zur Malewareerkennung
echo "Installing ClamAV (and ClamTK)..."
sudo apt install -y clamav clamav-daemon clamav-freshclam clamtk

# Start freshclam service to get the latest virus definitions
echo "Starting freshclam service for virus definitions..."
systemctl enable freshclam
systemctl start freshclam

# Configure freshclam for automatic updates (Check every 24 hours)
echo "Configuring freshclam for automatic updates..."
sed -i 's/^Checks.*/Checks 24/' "/etc/clamav/freshclam.conf" 

# Configure ClamAV Daemon (clamd) for better performance and security
echo "Configuring ClamAV Daemon (clamd)..."
CLAMD_CONF="/etc/clamav/clamd.conf"

# Enable the ClamAV daemon to run as a service
sed -i 's/^#DisableDaemon yes/DisableDaemon no/' $CLAMD_CONF
sed -i 's/^#User clamav/User clamav/' $CLAMD_CONF                                   # Run as non-privileged user
sed -i 's/^#Group clamav/Group clamav/' $CLAMD_CONF                                 # Run as non-privileged group
sed -i 's/^#LocalSocket.*/LocalSocket \/var\/run\/clamav\/clamd.sock/' $CLAMD_CONF  # Use Unix socket for local connections
sed -i 's/^#LogFile.*/LogFile \/var\/log\/clamav\/clamd.log/' $CLAMD_CONF           # Log to file
sed -i 's/^#MaxScanSize.*/MaxScanSize 1G/' $CLAMD_CONF                              # Limit file scan size
sed -i 's/^#ScanArchive.*/ScanArchive yes/' $CLAMD_CONF                             # Enable archive scanning

# Restart the ClamAV daemon to apply changes
echo "Restarting ClamAV daemon..."
systemctl restart clamav-daemon

# setup up quarantine (root-only)
sudo mkdir -p /var/quarantine
sudo chmod 700 /var/quarantine  # Restrict access to the quarantine directory

echo "ClamAV setup and configuration complete!"

# Update ClamAV database
sudo freshclam               # Update ClamAV

# Display ClamAV version and status
echo "ClamAV version:"
clamd --version
echo "ClamAV service status:"
systemctl status clamav-daemon | head -n 10

# =================================================================================================================
# === Step 4: Finish 
# =================================================================================================================
echo "Finished setup"
