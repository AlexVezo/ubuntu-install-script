#!/bin/bash

# =================================================================================================================
# === About:     A script to expand the LUKS partition /dev/sda3/ to 100% 
# === Author:    AlexVezo
# === Date:      19.12.2024
# === Version:   v4
# === Licence:   MIT
# =================================================================================================================

echo "======================================================================"
echo "=== Expand LUKS Partiton                                              " 
echo "======================================================================"
echo "== Step 1: Type ' '          + press Enter                            " 
echo "== Step 2: Type 'resizepart' + press Enter                            "
echo "== Step 3: Type 'fix'        + press Enter                            "
echo "== Step 4: Type '3'          + press Enter                            "
echo "== Step 5: Type '100%'       + press Enter                            "
echo "== Step 6: Type 'quit'       + press Enter                            "
echo "== Step 7: Type ' '          + press Enter                            " 
echo "== Step 8: Wait a few seconds                                         "
echo "== Step 9: Press any key to close the script                          "
echo "======================================================================"

# ===================================================================================================
# === Commands to expand the LUKS drive in /dev/sda3/ 
# ===================================================================================================
sudo cryptsetup luksOpen /dev/sda3 ubuntu                 # Open LUKS drive sda3 as ubuntu [Step 1  ]
sudo parted /dev/sda                                      # ... to 100% free space         [Step 2-6] 
sudo cryptsetup resize ubuntu                             # auto-resize to max. free space
sudo vgchange -a y                                        # activate VG "ubuntu-vg"
sudo pvresize /dev/mapper/ubuntu                          # resize PV
sudo lvresize -l+100%FREE /dev/ubuntu-vg                  # Resize LV for /home to 100%
sudo e2fsck -f /dev/mapper/ubuntu--vg-ubuntu--lv          # Resize the filesystem to 100%
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv          # Resize the filesystem to 100%

# ===================================================================================================
# === Finish: Close script after user input
# ===================================================================================================
echo "Finished. Click any key to close the script"
read -n 1 -s
