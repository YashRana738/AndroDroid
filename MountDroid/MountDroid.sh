#!/bin/bash

#Font
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
        echo "Enabling USB gadget with UDC: $UDC_NAME"
        echo "$UDC_NAME" > "$UDC_FILE_PATH"
        echo "USB gadget enabled successfully."
    else
        echo "No valid UDC name found. Unable to enable the USB gadget."
    fi
}

# Function to unmount the ISO
unmount_iso() {
    clear
    echo "Unmounting the image..."
    rm -rf "$LINK_TARGET"
    echo "" > "$LUN_FILE_PATH"
    echo "" > "$DEVICE_NAME"
    echo "0" > "$RO_FILE_PATH"
    echo "Reverted successfully."

    # Re-enable the USB gadget
    enable_usb_gadget
}

# Function to prompt user for read-only or read-write mode
set_mount_mode() {
    clear
    while true; do
        echo""
        echo -e "${BOLD}!! Use Read Only for installation media !!${RESET}"
        echo "Do you want to mount it as Read Only? (yes/no): "
        echo -n ""
        read MOUNT_MODE
        clear
        if [ "$MOUNT_MODE" == "yes" ] || [ "$MOUNT_MODE" == "y" ]; then
            echo "1" > "$RO_FILE_PATH"
            echo "The ISO will be mounted as read-only."
            break
        elif [ "$MOUNT_MODE" == "no" ] || [ "$MOUNT_MODE" == "n" ]; then
            echo "0" > "$RO_FILE_PATH"
            echo "The ISO will be mounted as read-write."
            break
        else
            echo "Invalid option. Please answer 'yes' or 'no'."
        fi
    done
}

# Function to mount the ISO
mount_iso() {
    echo ""
    echo "Disabling USB"
    echo "" > "$UDC_FILE_PATH"
    sleep 2

    # Write the ISO path to the file
    echo "Setting up Config"
    mkdir -p "$(dirname "$LUN_FILE_PATH")"
    echo "$ISO_PATH" > "$LUN_FILE_PATH"
    echo "${USER_DEVICE}'s AndroMount Media" > "$DEVICE_NAME"
    sleep 0.5
    echo "Mounting the ISO file..."
    ln -s "$MASS_STORAGE_PATH" "$LINK_TARGET"
    sleep 0.5
    echo "ISO file mounted successfully."
    sleep 0.5

    # Enable the USB gadget
    enable_usb_gadget
    echo ""
    echo "To unmount run this script again"
    echo "Reboot will also revert all mounts"
    echo ""
}
clear
# Main logic
while true; do
    # Check if the link exists
    if [ -L "$LINK_TARGET" ]; then
        echo ""
        echo "ISO Image is already mounted."
        echo ""
        echo "Currently mounted:"
        cat $LUN_FILE_PATH
        echo ""
        echo "Do you want to unmount the image? (yes/no): "
        echo -n ""
        read UNMOUNT_CHOICE
        if [ "$UNMOUNT_CHOICE" == "yes" ] || [ "$UNMOUNT_CHOICE" == "y" ]; then
         
          unmount_iso
          
        else
            echo "Unmount operation canceled."
        fi
        exit 0
    fi

    # No link exists, proceed to mount
    echo ""
    echo "No Mounted Iso Found"
    echo "Please provide the path to the ISO file to mount: "
    echo ""
    echo -n ""
    read ISO_PATH
    if [ ! -f "$ISO_PATH" ]; then
        echo "The file $ISO_PATH does not exist. Please try again."
        continue # Loop back to ask for the correct path
    fi

    set_mount_mode
    mount_iso
    exit 0
done