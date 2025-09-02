#!/bin/bash
set -e

REPO_DIR=~/Leapfrog-Bolt-Pro-MainsailOS-implementation
BACKUP_DIR=$REPO_DIR/backups
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

# --- Colors ---
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}=== Navigating to repository directory ===${RESET}"
cd "$REPO_DIR"

echo -e "${GREEN}=== Checking Git identity ===${RESET}"
if ! git config user.name >/dev/null; then
  echo -e "${YELLOW}Git name not set. Please run:${RESET}"
  echo "  git config --global user.name \"Your Name\""
  exit 1
fi
if ! git config user.email >/dev/null; then
  echo -e "${YELLOW}Git email not set. Please run:${RESET}"
  echo "  git config --global user.email \"your@email.com\""
  exit 1
fi

echo -e "${GREEN}=== Pulling latest changes from GitHub ===${RESET}"
git pull --rebase

echo -e "${GREEN}=== Creating backup directory if missing ===${RESET}"
mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}=== Backing up current configs ===${RESET}"
for FILE in printer.cfg macros.cfg led_state.py powerbutton.py update_klipper.sh; do
  if [ -f "$REPO_DIR/$FILE" ]; then
    cp "$REPO_DIR/$FILE" "$BACKUP_DIR/${FILE}.${TIMESTAMP}.bak"
    echo -e "${YELLOW}Backed up $FILE to $BACKUP_DIR/${FILE}.${TIMESTAMP}.bak${RESET}"
  fi
done

echo -e "${GREEN}=== Copying latest local config files ===${RESET}"
cp ~/printer_data/config/printer.cfg ./printer.cfg
cp ~/printer_data/config/macros.cfg ./macros.cfg
cp /home/pi/leapfrog/led_control/led_state.py ./led_state.py
cp /home/pi/leapfrog/powerbutton.py ./powerbutton.py
cp /home/pi/update_klipper.sh ./update_klipper.sh

echo -e "${GREEN}=== Checking for changes ===${RESET}"
if git status --porcelain | grep .; then
  echo -e "${GREEN}=== Staging and committing changes ===${RESET}"
  git add .
  git commit -m "Auto-update: $TIMESTAMP"
  echo -e "${GREEN}=== Pushing to GitHub ===${RESET}"
  git push
  echo -e "${GREEN}=== Done! Repository synced with GitHub ===${RESET}"
else
  echo -e "${YELLOW}No changes detected. Nothing to commit.${RESET}"
fi
