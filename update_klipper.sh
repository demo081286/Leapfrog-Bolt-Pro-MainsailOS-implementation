#!/bin/bash
set -e

echo "=== Updating Klipper repo ==="
cd ~/klipper
git fetch origin
git reset --hard origin/master

echo "=== Cleaning and building firmware ==="
make clean
make menuconfig   # adjust if MCU changes
make

echo "=== Flashing firmware to MCU ==="
make flash FLASH_DEVICE=/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_AL03EL2W-if00-port0

echo "=== Restarting Klipper ==="
sudo systemctl restart klipper

echo "=== Done! Klipper is now up to date ==="
