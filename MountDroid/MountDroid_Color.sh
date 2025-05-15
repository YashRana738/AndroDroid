#!/bin/bash

# Define color codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# Define the paths
GADGET_PATH="/config/usb_gadget/g1"

MASS_STORAGE_PATH="${GADGET_PATH}/functions/mass_storage.0"
LUN_FILE_PATH="${GADGET_PATH}/functions/mass_storage.0/lun.0/file"
RO_FILE_PATH="${GADGET_PATH}/functions/mass_storage.0/lun.0/ro"
LINK_TARGET="${GADGET_PATH}/configs/b.1/mass_storage.0"
UDC_FILE_PATH="${GADGET_PATH}/UDC"
UDC_SYS_PATH="/sys/class/udc/"
DEVICE_NAME="${GADGET_PATH}/functions/mass_storage.0/lun.0/inquiry_string"
USER_DEVICE=$(getprop ro.product.device)

# Function to find the first valid UDC name
get_udc_name() {
    for UDC in $(ls "$UDC_SYS_PATH"); do
        if [[ "$UDC" != *dummy* ]]; then
            echo "$UDC"
            return 0
        fi
    done
    return 1
}

# Function to enable the USB gadget
enable_usb_gadget() {
    UDC_NAME=$(get_udc_name)
    if [ -n "$UDC_NAME" ]; then
        echo -e "${BLUE}[*] Enabling USB gadget with UDC: ${YELLOW}$UDC_NAME${RESET}"
        echo "$UDC_NAME" > "$UDC_FILE_PATH"
        echo -e "${GREEN}[✔] USB gadget enabled successfully.${RESET}"
    else
        echo -e "${RED}[✘] No valid UDC name found. Unable to enable the USB gadget.${RESET}"
    fi
}

# Function to unmount the ISO
unmount_iso() {
    clear
    echo -e "${YELLOW}[*] Unmounting the image...${RESET}"
    rm -rf "$LINK_TARGET"
    echo "" > "$LUN_FILE_PATH"
    echo "" > "$DEVICE_NAME"
    echo "0" > "$RO_FILE_PATH"
    sleep 2
    echo -e "${GREEN}[✔] Reverted successfully.${RESET}"
    sleep 0.5

    enable_usb_gadget
}

# Prompt for read-only or read-write
set_mount_mode() {
    clear
    while true; do
        echo ""
        echo -e "${CYAN}${BOLD}!! Use Read Only for installation media !!${RESET}"
        echo -ne "${YELLOW}Do you want to mount it as Read Only? (yes/no): ${RESET}"
       echo ""
         read MOUNT_MODE
         clear
        case "$MOUNT_MODE" in
            yes|y)
                echo "1" > "$RO_FILE_PATH"
                echo -e "${GREEN}[✔] The ISO will be mounted as read-only.${RESET}"
                break
                ;;
            no|n)
                echo "0" > "$RO_FILE_PATH"
                echo -e "${GREEN}[✔] The ISO will be mounted as read-write.${RESET}"
                break
                ;;
            *)
                echo -e "${RED}[!] Invalid option. Please answer 'yes' or 'no'.${RESET}"
                ;;
        esac
    done
}

# Mount the ISO
mount_iso() {

    echo -e "\n${YELLOW}[*] Disabling USB...${RESET}"
    echo "" > "$UDC_FILE_PATH"
    sleep 2

    echo -e "${BLUE}[*] Setting up Config...${RESET}"
    mkdir -p "$(dirname "$LUN_FILE_PATH")"
    echo "$ISO_PATH" > "$LUN_FILE_PATH"
    echo "${USER_DEVICE}'s AndroMount Media" > "$DEVICE_NAME"
    sleep 0.5

    echo -e "${YELLOW}[*] Mounting the ISO file...${RESET}"
    ln -s "$MASS_STORAGE_PATH" "$LINK_TARGET"
    sleep 0.5

    echo -e "${GREEN}[✔] ISO file mounted successfully.${RESET}"
    sleep 0.5
    enable_usb_gadget

    echo -e "\n${CYAN}To unmount, run this script again."
    echo "A reboot will also revert the mount.${RESET}\n"
}

# Main logic
clear
while true; do
    if [ -L "$LINK_TARGET" ]; then
        echo -e "\n${YELLOW}ISO Image is already mounted.${RESET}"
        echo ""
        echo -e "${CYAN}Currently mounted:${GREEN}"
        cat $LUN_FILE_PATH
        echo -ne "\n${YELLOW}Do you want to unmount the image? (yes/no): ${RESET}"
        echo ""
        read UNMOUNT_CHOICE
        if [[ "$UNMOUNT_CHOICE" == "yes" || "$UNMOUNT_CHOICE" == "y" ]]; then
            unmount_iso
        else
            echo -e "${BLUE}[i] Unmount operation canceled.${RESET}"
        fi
        exit 0
    fi

    echo -e "\n${YELLOW}[*] No mounted ISO found.${RESET}"
    echo -ne "${CYAN}Please provide the path to the ISO file to mount: ${RESET}"
    echo ""
    read ISO_PATH

    if [ ! -f "$ISO_PATH" ]; then
        echo -e "${RED}[✘] The file '$ISO_PATH' does not exist. Please try again.${RESET}"
        continue
    fi

    set_mount_mode
    mount_iso
    exit 0
done
