#!/bin/bash
set -e

REPO_DIR=~/Leapfrog-Bolt-Pro-MainsailOS-implementation
BACKUP_DIR=~/Leapfrog-Bolt-Pro-MainsailOS-implementation/backups
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

echo "=== Navigating to repository directory ==="
cd $REPO_DIR

echo "=== Pulling latest changes from GitHub ==="
git pull --rebase

echo "=== Creating backup directory if missing ==="
mkdir -p $BACKUP_DIR

echo "=== Backing up current configs ==="
for FILE in printer.cfg macros.cfg led_state.py powerbutton.py update_klipper.sh; do
  if [ -f "$REPO_DIR/$FILE" ]; then
    cp "$REPO_DIR/$FILE" "$BACKUP_DIR/${FILE}.${TIMESTAMP}.bak"
    echo "Backed up $FILE to $BACKUP_DIR/${FILE}.${TIMESTAMP}.bak"
  fi
done

echo "=== Copying latest local config files ==="
cp ~/printer_data/config/printer.cfg ./printer.cfg
cp ~/printer_data/config/macros.cfg ./macros.cfg
cp /home/pi/leapfrog/led_control/led_state.py ./led_state.py
cp /home/pi/leapfrog/powerbutton.py ./powerbutton.py
cp /home/pi/update_klipper.sh ./update_klipper.sh

echo "=== Staging changes for commit ==="
git add .

git commit -m "Auto-update: $TIMESTAMP" || echo "No changes to commit."

echo "=== Pushing to GitHub ==="
git push

echo "=== Done! Repository is now synced with backup. ==="
