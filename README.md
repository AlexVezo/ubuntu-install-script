# About the project
This repository contains files on how I would set up a Ubuntu image using a virtual machine. 
It contains script files and user documentation for explaination.  

The image is set up as VM; then export to image via command:
`VBoxManage clonehd vm.vdi image.img --format RAW` 

# About install-ubuntu-software.sh
After the Ubuntu image is set up in a virtual machine, the script has to be run.
The scripts sets up and/or installes with necessarcy IT security features:

- _ufw_ as firewall
- unattended updates
- _KeePassXC_ as password manager
- nautilus-wipe as tool to wipe data securely
- _ClamAV_ as antivirus software 
- install additional software
  
# About the installed software
Here is a list of software that is set up using the script:

- [MS Office] Teams, OneNote, Outlook
- [Mozilla] Firefox, Thunderbird
- [Browser] Ungoogled-Chromium, LibreWolf
- [Chat] Signal, WhatsApp
- [Media] Pinta, GIMP, VLC, Shotcut
- [ITsec] KeePassXC, Bitwarden, ClamAV + ClamTK
- [Tools] Zenkit, LibreOffice, LibreCAD, Pomodoro, Meld, Czkawka, DrawIO
- [Lernen] Anki, Duolingo
- [Notes] Obsidian, Joplin
- [TeX] Calibre + LyX / Texmaker + JabRef + Zotero
- [Software] FlatStore, AppImageLauncher, Synaptics Package Manager

# About runUpdates.sh
runUpdates is a script that updates apt, snap, flatpak and ClamAV as .desktop file to run as Application.

# About expandLUKS.sh
The image is set up with LUKS encrypton on a virtual machine, the parition does not use full space when copied to a drive.
When run as live image, this script expands the partition sda3 to 100%. This way, all empty space after partition sda3 of the drive is used for sda3.

![luks](https://github.com/user-attachments/assets/77270e07-a6a4-4d2c-913d-d588190dd9ec)
