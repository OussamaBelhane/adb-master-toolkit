# 📱 ADB Master Toolkit

**Developed by:** Oussama Belhane  
**Environment:** Bash (Linux, WSL, Git Bash)  
**Version:** 1.0 (Premium Aesthetic Edition)

---

## 🚀 Overview
**ADB Master Toolkit** is a professional-grade Command Line Interface (CLI) utility designed to automate Android device management, monitoring, and security testing. It provides a streamlined workflow for both USB and wireless connections, featuring a high-end "Cyberpunk/Kali" aesthetic.

## ✨ Key Features

### 📡 Wireless Connectivity (Android 11+ & Legacy)
- **Automatic Pairing:** One-click pairing with pairing code support.
- **Auto-Connect Engine:** Instant connection stabilization immediately after successful pairing.
- **Dynamic Port Detection:** Intelligent mDNS service discovery to find dynamic ADB ports without user input.
- **Session Management:** Easy disconnection and reset of all active wireless sessions.

### 🔍 Network Reconnaissance & Exploitation
- **Hybrid Scanner:** Combined power of **mDNS** and **Nmap** to map out ADB-enabled devices on the local network.
- **Deep Port Scanning:** Specifically targets port 5555 and dynamic ports used by modern Android devices.
- **Smart Subnet Detection:** Automatically identifies your local network range while ignoring virtual adapters (VMware/VirtualBox).

### 📸 Multimedia & Surveillance
- **Stealth Screenshots:** Instant screen captures pulled directly to your computer.
- **Unique Naming:** Files are saved with precise timestamps (`screenshot_YYYYMMDD_HHMMSS.png`) to prevent data loss.
- **Screen Recording:** Capture 10-second video clips for UX analysis or forensic reporting.

### 🛠️ Advanced Tools (Full Control)
- **Remote Shell (SSH-like):** Full interactive terminal access to the Android Linux sub-system.
- **System Diagnostics:** Detailed OS version, battery health, and hardware hardware specifications.
- **App Management:** List, install, and uninstall packages with ease.
- **Log Sniffing:** Real-time logcat monitoring for sniffing device activity.
- **Input Injection:** Remotely simulate key presses, swipes, or text input for remote control.
- **File Explorer:** High-speed File Transfer Protocol (Push/Pull) between PC and Android.

---

## 📋 Requirements
- **ADB (Android Debug Bridge):** Ensure `adb` is in your system PATH.
- **Nmap (Optional):** Highly recommended for the "Deep Scan" feature.
- **Git Bash / WSL:** For Windows users, Git Bash is recommended for the best visual experience.

---

## 🔧 Technical Highlights (For Professors/Reviewers)
- **Path Expansion Fix:** Implemented `//sdcard/` double-slash notation to bypass Git Bash's automatic path conversion, ensuring stability across Windows/Android environments.
- **Dependency Resilience:** Built-in check for `nmap`, allowing for a graceful fallback to mDNS if dependencies are missing.
- **Global Discovery Array:** Implemented a shared data structure to allow the Pairing menu to reuse results from the Network Scanner.

---

## 📖 How to Use
1.  **Clone/Copy** the script `adb_toolkit.sh`.
2.  **Give execution rights:** `chmod +x adb_toolkit.sh`.
3.  **Run it:** `./adb_toolkit.sh`.
4.  **Follow the menu:** The script will guide you through device selection and action menus.

---
*Created for educational and professional Android management purposes.*
