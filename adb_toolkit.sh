#!/bin/bash
# ==========================================
# ADB-TOOLKIT - Developed by Oussama Belhane
# ==========================================

# ==========================================
# Variables globales
# ==========================================
DEVICE=""
DISCOVERED_IPS=()      # Liste pour la connexion (ports 5555 ou connect)
DISCOVERED_PAIRING=()  # Liste spécifique pour l'appairage (ports pairing)

# ==========================================
# Couleurs & Style (Cyberpunk/Kali)
# ==========================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Symboles
ST='⚡'
INFO='[i]'
WARN='[!]'
SUCC='[+]'
target_icon='💀'

# ==========================================
# Bannière ASCII Premium
# ==========================================
show_banner() {
    clear
    echo -e "${PURPLE}┌──────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}    _    ____  ____     _____ ___   ___  _     _  _____ _____ ${NC}"
    echo -e "${CYAN}   / \  |  _ \| __ )   |_   _/ _ \ / _ \| |   | |/ /_ _|_   _|${NC}"
    echo -e "${CYAN}  / _ \ | | | |  _ \     | || | | | | | | |   | ' / | |  | |  ${NC}"
    echo -e "${CYAN} / ___ \| |_| | |_) |    | || |_| | |_| | |___| . \ | |  | |  ${NC}"
    echo -e "${CYAN}/_/   \_\____/|____/     |_| \___/ \___/|_____|_|\_\___| |_|  ${NC}"
    echo -e "${PURPLE}└──────────────────────────────────────────────────────────────┘${NC}"
    echo -e "${YELLOW}           > Android Master Toolkit | Dev: Oussama Belhane <${NC}"
    echo ""
    if [ -n "$DEVICE" ]; then
        echo -e "   ${GREEN}${target_icon} CIBLE ACTIVE :${NC} ${WHITE}$DEVICE${NC}"
    else
        echo -e "   ${RED}${WARN} AUCUNE CIBLE SÉLECTIONNÉE${NC}"
    fi
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ==========================================
# Automatisation Complète (Détection & IP)
# ==========================================
pause() {
    echo ""
    read -p "Appuyez sur [Entrée] pour revenir au menu principal..."
}

auto_detect() {
    while true; do
        show_banner
        echo -e "${CYAN}[*] Recherche des appareils connectés...${NC}"
        adb start-server > /dev/null 2>&1
        sleep 1
        
        # Récupérer la liste brute des appareils
        local raw_list=$(adb devices | tail -n +2 | grep -v '^$')
        
        # Convertir en tableau
        IFS=$'\n' read -rd '' -a devices_array <<< "$raw_list"
        local dev_count=${#devices_array[@]}

        echo -e "   ${PURPLE}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "   ${PURPLE}║${NC} ${GREEN}${SUCC} APPAREILS DÉTECTÉS${NC}                              ${PURPLE}║${NC}"
        echo -e "   ${PURPLE}╠══════════════════════════════════════════════════════╣${NC}"
        local i=1
        for dev in "${devices_array[@]}"; do
            local dev_id=$(echo "$dev" | awk '{print $1}')
            local dev_status=$(echo "$dev" | awk '{print $2}')
            
            local status_text=""
            if [ "$dev_status" == "device" ]; then
                status_text="${GREEN}[ PRÊT ]${NC}"
            elif [ "$dev_status" == "unauthorized" ]; then
                status_text="${RED}[ NON AUTORISÉ ]${NC}"
            else
                status_text="${YELLOW}[ $dev_status ]${NC}"
            fi
            
            printf "   ${PURPLE}║${NC}  %2d) %-30s %-20s ${PURPLE}║${NC}\n" "$i" "$dev_id" "$status_text"
            ((i++))
        done

        local wireless_idx=$i
        printf "   ${PURPLE}║${NC}  %2d) ${CYAN}%-45s${NC} ${PURPLE}║${NC}\n" "$wireless_idx" "📡 [ Connexion SANS FIL (WiFi / Appairage) ]"
        ((i++))
        local quit_idx=$i
        printf "   ${PURPLE}║${NC}  %2d) %-45s ${PURPLE}║${NC}\n" "$quit_idx" "❌ Quitter"
        echo -e "   ${PURPLE}╚══════════════════════════════════════════════════════╝${NC}"
        
        read -p "   SÉLECTION > " selection

        if [ "$selection" == "$quit_idx" ] || [ "$selection" == "0" ]; then
            exit 0
        elif [ "$selection" == "$wireless_idx" ]; then
            menu_wireless
            continue # Reboucle pour voir l'appareil si connecté
        elif [ "$selection" -gt 0 ] && [ "$selection" -lt "$wireless_idx" ]; then
            local selected_line="${devices_array[$((selection-1))]}"
            local id=$(echo "$selected_line" | awk '{print $1}')
            local status=$(echo "$selected_line" | awk '{print $2}')
            
            if [ "$status" == "unauthorized" ]; then
                echo -e "${RED}[!] Cet appareil n'est pas autorisé. Validez le message sur le téléphone.${NC}"
                pause
            else
                DEVICE=$id
                echo -e "${GREEN}[+] Cible verrouillée : $DEVICE${NC}"
                sleep 1
                break
            fi
        else
            echo -e "${RED}[!] Sélection invalide.${NC}"
            sleep 1
        fi
    done
}

# ==========================================
# Menus d'actions
# ==========================================

menu_infos() {
    echo -e "${GREEN}[*] Récupération des informations système...${NC}"
    echo -e "${YELLOW}- Modèle :${NC} $(adb -s $DEVICE shell getprop ro.product.model | tr -d '\r')"
    echo -e "${YELLOW}- Fabricant :${NC} $(adb -s $DEVICE shell getprop ro.product.manufacturer | tr -d '\r')"
    echo -e "${YELLOW}- Version Android :${NC} $(adb -s $DEVICE shell getprop ro.build.version.release | tr -d '\r')"
    echo -e "${YELLOW}- Architecture CPU :${NC} $(adb -s $DEVICE shell getprop ro.product.cpu.abi | tr -d '\r')"
    echo -e "${YELLOW}- État Batterie :${NC}"
    adb -s $DEVICE shell dumpsys battery | grep -E "level|status" | tr -d '\r'
    pause
}

menu_apps() {
    echo -e "${CYAN}---[ GESTION DES APPLICATIONS ]---${NC}"
    echo "1. Lister toutes les applications"
    echo "2. Lister les applications tierces (installées par l'utilisateur)"
    echo "3. Lister les applications système"
    echo "4. Vider le cache/données d'une application"
    echo "5. Forcer l'arrêt d'une application"
    read -p "Votre choix : " app_choice

    case $app_choice in
        1) adb -s $DEVICE shell pm list packages ;;
        2) adb -s $DEVICE shell pm list packages -3 ;;
        3) adb -s $DEVICE shell pm list packages -s ;;
        4) read -p "Nom du package (ex: com.whatsapp) : " pkg; adb -s $DEVICE shell pm clear $pkg ;;
        5) read -p "Nom du package : " pkg; adb -s $DEVICE shell am force-stop $pkg ;;
    esac
    pause
}

menu_files() {
    echo -e "${CYAN}---[ FICHIERS & EXPLORATION ]---${NC}"
    echo "1. Explorer /sdcard (ls -la)"
    echo "2. PULL : Télécharger un fichier depuis le téléphone"
    echo "3. PUSH : Envoyer un fichier vers le téléphone"
    read -p "Votre choix : " file_choice

    case $file_choice in
        1) adb -s $DEVICE shell ls -la /sdcard/ ;;
        2) 
            read -p "Chemin sur le téléphone (ex: /sdcard/DCIM/photo.jpg) : " distant
            adb -s $DEVICE pull "$distant" ./ 
            ;;
        3) 
            read -p "Fichier local (ex: malware.apk) : " local
            adb -s $DEVICE push "$local" /sdcard/ 
            ;;
    esac
    pause
}

menu_logs() {
    echo -e "${CYAN}---[ LOGCAT & DÉBOGAGE ]---${NC}"
    echo "1. Afficher les logs en temps réel (Ctrl+C pour quitter)"
    echo "2. Afficher uniquement les ERREURS"
    echo "3. Sniffer : Rechercher 'password', 'token', 'key' dans les logs"
    read -p "Votre choix : " log_choice

    case $log_choice in
        1) adb -s $DEVICE logcat ;;
        2) adb -s $DEVICE logcat *:E ;;
        3) echo "[*] Recherche en cours..."; adb -s $DEVICE logcat -d | grep -iE "password|token|key|secret" ;;
    esac
    if [ "$log_choice" != "1" ]; then pause; fi
}

menu_screen() {
    echo -e "${CYAN}---[ CAPTURE & MULTIMÉDIA ]---${NC}"
    echo "1. Prendre une capture d'écran furtive"
    echo "2. Enregistrer l'écran en vidéo (10 secondes)"
    read -p "Votre choix : " screen_choice

    local timestamp=$(date +"%Y%m%d_%H%M%S")

    case $screen_choice in
        1) 
            local filename="screenshot_${timestamp}.png"
            # Utilisation de //sdcard/ pour éviter l'expansion Git Bash
            adb -s $DEVICE shell screencap -p //sdcard/screenshot.png
            adb -s $DEVICE pull //sdcard/screenshot.png "./$filename" > /dev/null 2>&1
            adb -s $DEVICE shell rm //sdcard/screenshot.png
            echo -e "${GREEN}${SUCC} Capture sauvegardée sous $filename !${NC}"
            ;;
        2) 
            local filename="video_${timestamp}.mp4"
            echo -e "${YELLOW}[*] Enregistrement en cours (10s)... Patientez.${NC}"
            adb -s $DEVICE shell screenrecord --time-limit 10 //sdcard/video.mp4
            adb -s $DEVICE pull //sdcard/video.mp4 "./$filename" > /dev/null 2>&1
            adb -s $DEVICE shell rm //sdcard/video.mp4
            echo -e "${GREEN}${SUCC} Vidéo sauvegardée sous $filename !${NC}"
            ;;
    esac
    pause
}

menu_input() {
    echo -e "${CYAN}---[ INJECTION D'ENTRÉES ]---${NC}"
    echo "1. Injecter du texte (ex: taper un mot de passe à distance)"
    echo "2. Simuler un appui sur HOME"
    echo "3. Simuler un appui sur RETOUR"
    read -p "Votre choix : " input_choice

    case $input_choice in
        1) read -p "Texte à injecter : " txt; adb -s $DEVICE shell input text "$txt" ;;
        2) adb -s $DEVICE shell input keyevent KEYCODE_HOME ;;
        3) adb -s $DEVICE shell input keyevent KEYCODE_BACK ;;
    esac
    pause
}

menu_wireless() {
    echo -e "${CYAN}---[ DÉBOGAGE SANS FIL ]---${NC}"
    echo "1. Se connecter à un appareil (IP:Port)"
    echo "2. Appairer un nouvel appareil (Android 11+ Pairing Code)"
    echo "3. Scanner le réseau local (mDNS / nmap)"
    echo "4. Tout déconnecter"
    read -p "Votre choix : " wl_choice

    case $wl_choice in
        1) 
            read -p "Adresse IP (ex: 192.168.1.50) : " ip
            read -p "Port (Défaut 5555) : " port
            port=${port:-5555}
            echo -e "${YELLOW}[*] Connexion à $ip:$port...${NC}"
            adb connect "$ip:$port"
            ;;
        2) 
            if [ ${#DISCOVERED_PAIRING[@]} -gt 0 ]; then
                echo -e "${GREEN}${SUCC} Appareil(s) prêt(s) pour l'appairage trouvés !${NC}"
                local i=1
                for item in "${DISCOVERED_PAIRING[@]}"; do
                    echo "  $i) $item"
                    ((i++))
                done
                echo "  m) Saisie manuelle"
                read -p "Sélection : " p_choice
                if [ "$p_choice" == "m" ]; then
                    read -p "Adresse IP:Port d'appairage : " ipport
                elif [ "$p_choice" -gt 0 ] && [ "$p_choice" -lt "$i" ]; then
                    ipport="${DISCOVERED_PAIRING[$((p_choice-1))]}"
                fi
            elif [ ${#DISCOVERED_IPS[@]} -gt 0 ]; then
                echo -e "${YELLOW}${INFO} Aucun port d'appairage détecté. Saisie manuelle du port requise.${NC}"
                local i=1
                for ip in "${DISCOVERED_IPS[@]}"; do
                    echo "  $i) $ip"
                    ((i++))
                done
                read -p "Choisissez l'IP (1-$((i-1))) : " p_choice
                if [ "$p_choice" -gt 0 ] && [ "$p_choice" -lt "$i" ]; then
                    local selected_ip=$(echo "${DISCOVERED_IPS[$((p_choice-1))]}" | cut -d: -f1)
                    read -p "Port d'appairage (affiché sur le téléphone) : " p_port
                    ipport="$selected_ip:$p_port"
                fi
            else
                read -p "Adresse IP:Port d'appairage (ex: 192.168.1.50:37891) : " ipport
            fi
            
            if [ -n "$ipport" ]; then
                read -p "Code d'appairage : " code
                echo -e "${YELLOW}[*] Appairage en cours...${NC}"
                if adb pair "$ipport" "$code" | grep -q "Successfully paired"; then
                    echo -e "${GREEN}${SUCC} Appairage RÉUSSI !${NC}"
                    echo -e "${CYAN}[*] Tentative de connexion automatique...${NC}"
                    # On essaie de se connecter. Note: le port de connexion est souvent différent du port d'appairage.
                    # On lance un scan rapide pour trouver le port de connexion
                    sleep 2
                    local connect_ip=$(echo "$ipport" | cut -d: -f1)
                    local connect_port=$(adb mdns services 2>/dev/null | grep "$connect_ip" | grep -E '_adb._tcp|_adb-tls-connect._tcp' | awk '{print $3}' | cut -d: -f2 | tr -d '\r')
                    
                    if [ -n "$connect_port" ]; then
                        adb connect "$connect_ip:$connect_port"
                    else
                        # Si mDNS ne répond pas assez vite, on tente le port par défaut ou le même port (parfois ça marche)
                        adb connect "$connect_ip:5555"
                    fi
                else
                    echo -e "${RED}${WARN} Échec de l'appairage.${NC}"
                fi
            fi
            ;;
        3) scan_network ;;
        4) 
            echo -e "${YELLOW}[*] Déconnexion de tous les appareils...${NC}"
            adb disconnect
            DEVICE=""
            ;;
    esac
    pause
}

scan_network() {
    echo -e "${CYAN}---[ SCAN RÉSEAU ADB ]---${NC}"
    
    DISCOVERED_IPS=()
    DISCOVERED_PAIRING=()
    
    # Étape 1 : mDNS
    echo -e "${YELLOW}[*] Étape 1 : Recherche via mDNS (Rapide)...${NC}"
    
    # Recherche Connect Services
    local mdns_connect=$(adb mdns services 2>/dev/null | grep -E '_adb._tcp|_adb-tls-connect._tcp' | awk '{print $3}' | tr -d '\r')
    for res in $mdns_connect; do
        if [[ ! " ${DISCOVERED_IPS[@]} " =~ " ${res} " ]]; then
            DISCOVERED_IPS+=("$res")
        fi
    done

    # Recherche Pairing Services
    local mdns_pairing=$(adb mdns services 2>/dev/null | grep '_adb-tls-pairing._tcp' | awk '{print $3}' | tr -d '\r')
    for res in $mdns_pairing; do
        if [[ ! " ${DISCOVERED_PAIRING[@]} " =~ " ${res} " ]]; then
            DISCOVERED_PAIRING+=("$res")
        fi
    done

    if [ ${#DISCOVERED_IPS[@]} -gt 0 ] || [ ${#DISCOVERED_PAIRING[@]} -gt 0 ]; then
        echo -e "${GREEN}[+] Appareils mDNS trouvés.${NC}"
    fi

    # Étape 2 : nmap
    echo -e "${CYAN}[*] Étape 2 : Recherche via nmap (Scan profond)...${NC}"
    
    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}${WARN} NMAP n'est pas installé sur votre système !${NC}"
        echo -e "${YELLOW}${INFO} Le scan profond est désactivé.${NC}"
        echo -e "${WHITE}Conseil : Installez nmap (https://nmap.org) pour découvrir${NC}"
        echo -e "${WHITE}automatiquement tous les appareils sur votre réseau.${NC}"
        sleep 2
    else
        # Détection intelligente du sous-réseau
        local potential_ips=$(ipconfig | grep -iE "IPv4 Address" | grep -vE "127.0.0.1|192.168.56.|192.168.200." | awk -F': ' '{print $2}' | tr -d '\r ')
        local subnet=""
        local ip_count=$(echo "$potential_ips" | wc -w)

        if [ "$ip_count" -eq 0 ]; then
            read -p "Entrez votre sous-réseau à scanner (ex: 192.168.1.0/24) : " subnet
        elif [ "$ip_count" -eq 1 ]; then
            subnet=$(echo $potential_ips | cut -d. -f1-3)".0/24"
        else
            local ip_array=($potential_ips)
            subnet=$(echo ${ip_array[0]} | cut -d. -f1-3)".0/24"
        fi

        if [ -n "$subnet" ]; then
            echo -e "${YELLOW}[*] Scan nmap de $subnet en cours...${NC}"
            local nmap_results=$(nmap -p 5555 --open -oG - "$subnet" 2>/dev/null | grep "Host:" | awk '{print $2}')
            for res in $nmap_results; do
                local full_ip="$res:5555"
                if [[ ! " ${DISCOVERED_IPS[@]} " =~ " ${full_ip} " ]]; then
                    DISCOVERED_IPS+=("$full_ip")
                fi
            done
        fi
    fi

    if [ ${#DISCOVERED_IPS[@]} -gt 0 ]; then
        echo -e "${GREEN}[+] Liste complète des appareils trouvés :${NC}"
        local i=1
        for ip in "${DISCOVERED_IPS[@]}"; do
            echo "  $i) $ip"
            ((i++))
        done
        echo "  0) Annuler"
        read -p "Sélectionnez un appareil : " scan_choice
        
        if [ "$scan_choice" -gt 0 ] && [ "$scan_choice" -lt "$i" ]; then
            local target_ip="${DISCOVERED_IPS[$((scan_choice-1))]}"
            echo -e "${CYAN}[*] Réinitialisation de la connexion...${NC}"
            adb disconnect "$target_ip" > /dev/null 2>&1
            sleep 1
            echo -e "${CYAN}[*] Tentative de connexion à $target_ip...${NC}"
            if adb connect "$target_ip" | grep -q "connected to"; then
                echo -e "${GREEN}${SUCC} Connecté avec succès !${NC}"
            else
                echo -e "${RED}${WARN} Échec de la connexion.${NC}"
                echo -e "${YELLOW}${INFO} ASTUCE : Si c'est un nouvel appareil, utilisez l'option 'Appairer' d'abord.${NC}"
            fi
        fi
    else
        echo -e "${RED}[!] Aucun appareil trouvé sur le réseau.${NC}"
    fi
}

# ==========================================
# Boucle principale
# ==========================================

auto_detect

while true; do
    show_banner
    echo -e "   ${CYAN}⚡ SÉLECTIONNEZ UN VECTEUR D'ANALYSE :${NC}"
    echo -e "   ${PURPLE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "   ${PURPLE}║${NC} ${WHITE}1) Informations Système (OS, Batterie, HW)   ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}║${NC} ${WHITE}2) Gestion des Applications (PM)             ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}║${NC} ${WHITE}3) Fichiers & Transferts (Push/Pull)         ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}║${NC} ${WHITE}4) Sniffing Logs (Logcat)                    ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}║${NC} ${WHITE}5) Espionnage Multimédia (Capture/Vidéo)      ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}║${NC} ${WHITE}6) Injection d'Entrées (Touches/Texte)        ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}║${NC} ${WHITE}7) Ouvrir une session SHELL interactive      ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}╠══════════════════════════════════════════════════╣${NC}"
    echo -e "   ${PURPLE}║${NC} ${YELLOW}99) Changer d'appareil / Sans fil            ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}║${NC} ${RED}0)  Quitter le Toolkit                       ${PURPLE}║${NC}"
    echo -e "   ${PURPLE}╚══════════════════════════════════════════════════╝${NC}"
    read -p "   ADB-TOOLKIT > " choice

    case $choice in
        1) menu_infos ;;
        2) menu_apps ;;
        3) menu_files ;;
        4) menu_logs ;;
        5) menu_screen ;;
        6) menu_input ;;
        7) 
            if [ -z "$DEVICE" ]; then
                echo -e "${RED}[!] Aucune cible sélectionnée.${NC}"
                sleep 1
            else
                echo -e "${GREEN}[*] Lancement du shell... Tapez 'exit' pour revenir.${NC}"
                adb -s $DEVICE shell
            fi
            ;;
        99) auto_detect ;;
        0) echo -e "${YELLOW}Fermeture. Bye !${NC}"; exit 0 ;;
        *) echo -e "${RED}Commande invalide.${NC}"; sleep 1 ;;
    esac
done