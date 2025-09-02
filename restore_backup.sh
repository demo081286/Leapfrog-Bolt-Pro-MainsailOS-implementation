#!/bin/bash
set -e

REPO_DIR=~/Leapfrog-Bolt-Pro-MainsailOS-implementation
BACKUP_DIR=$REPO_DIR/backups

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}=== Backup Restore Utility ===${RESET}"

# Ensure backup folder exists
if [ ! -d "$BACKUP_DIR" ]; then
  echo -e "${RED}No backup folder found!${RESET}"
  exit 1
fi

echo -e "${GREEN}Available backups:${RESET}"
ls -1 "$BACKUP_DIR" | nl

echo -ne "${YELLOW}Enter the number of the backup to restore:${RESET} "
read SELECTION

FILE=$(ls -1 "$BACKUP_DIR" | sed -n "${SELECTION}p")

if [ -z "$FILE" ]; then
  echo -e "${RED}Invalid selection. Exiting.${RESET}"
  exit 1
fi

TARGET_FILE=$(echo "$FILE" | sed 's/\.[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}_[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}\.bak//')

echo -e "${YELLOW}Restoring ${GREEN}$FILE${YELLOW} to ${GREEN}$TARGET_FILE${RESET} ..."

cp "$BACKUP_DIR/$FILE" "$REPO_DIR/$TARGET_FILE"

echo -e "${GREEN}=== Restore complete! ===${RESET}"
echo "Remember to run 'update_repo.sh' to commit this rollback if desired."
