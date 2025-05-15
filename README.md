# MountDroid

**MountDroid** is a shell script for rooted Android devices that allows you to **mount ISO files** and expose them over USB as a virtual disk — enabling you to **boot your PC directly from an ISO stored on your phone**. No USB pendrive required!

It uses the Linux USB Gadget framework to emulate a USB Mass Storage device, acting like a physical bootable drive.

---

## 🚀 Why MountDroid?

📌 **DriveDroid doesn't work** on most modern Android versions due to changes in USB handling and security.  
✅ **MountDroid** is a perfect replacement — script-based, no GUI bloat, works on newer kernels and ROMs.

> ✔️ **Tested on:**
> - **Android 15 AOSP**
> - **Nothing OS (Nothing Phone 2)**

---

## 📦 Features

- 🔗 Mount ISO files from internal storage or SD card
- 🖥 Bootable on Windows, Linux, or any ISO-supported OS
- 🔒 Supports **read-only** and **read-write** mounting
- ♻️ Automatically reverts on reboot
- 🚫 No need for USB OTG or pendrives

---

## 🛠 Requirements

- Rooted Android device
- Kernel support for `configfs` and `usb_gadget`
- BusyBox (recommended)
- USB-C to USB-A cable (to connect phone to PC)

---

## 📥 Installation & Usage

1. Download the `MountDroid.sh` script to your device.
2. Run it using **Termux** or any terminal emulator **with root permissions**:
   ```sh
   su -c ./MountDroid.sh
