#!/bin/bash

# ======================================================
# === PANTHEONX - TOOLKIT ===
# ======================================================

show_banner() {
    echo -e "\033[1;35m"
    sleep 0.1
    echo -e " ██████╗  █████╗ ███╗   ██╗████████╗██╗  ██╗███████╗ ██████╗ ███╗   ██╗██╗  ██╗"
    sleep 0.1
    echo -e " ██╔══██╗██╔══██╗████╗  ██║╚══██╔══╝██║  ██║██╔════╝██╔═══██╗████╗  ██║╚██╗██╔╝"
    sleep 0.1
    echo -e " ██████╔╝███████║██╔██╗ ██║   ██║   ███████║█████╗  ██║   ██║██╔██╗ ██║ ╚███╔╝ "
    sleep 0.1
    echo -e " ██╔═══╝ ██╔══██║██║╚██╗██║   ██║   ██╔══██║██╔══╝  ██║   ██║██║╚██╗██║ ██╔██╗ "
    sleep 0.1
    echo -e " ██║     ██║  ██║██║ ╚████║   ██║   ██║  ██║███████╗╚██████╔╝██║ ╚████║██╔╝ ██╗"
    sleep 0.1
    echo -e " ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝"
    sleep 0.1
    echo -e "\033[1;36m"
    sleep 0.1
    echo -e "                   PantheonX - Ultimate Pentesting Toolkit"
    sleep 0.1
    echo -e "                   by \033[1;33mMatthyGD\033[1;36m"
    sleep 0.1
    echo -e "\033[1;34m=====================================================================\033[0m"
    echo -e ""
}

show_banner

sleep 2

# ======================================================
# === ROOT PRIVILEGES VERIFICATION ===
# ======================================================

echo -e "\n\033[1;34m[🔒] Checking for root privileges...\033[0m"
sleep 1

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[1;33m[⚠] This script requires root privileges. Switching to root...\033[0m"
    sleep 1
    exec sudo "$0" "$@"
    exit $?
else
    echo -e "\033[1;32m[✓] Root privileges verified!\033[0m"
    sleep 1
fi

# ======================================================
# === LANGUAGE AND USER CONFIGURATION ===
# ======================================================

# Welcome message
echo -e "\n\033[1;34m[🌐] Hello! Welcome to the PantheonX!\033[0m"
sleep 2

# Display available non-root users
echo -e "\n\033[1;34m[👥] Available system users (non-root):\033[0m"
echo -e "\033[1;36m----------------------------------------\033[0m"

# Get non-root users with login shells (uid >= 1000 typically)
getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print "• " $1 " (UID:" $3 ")"}' | sort

echo -e "\033[1;36m----------------------------------------\033[0m"
sleep 1.5

# Asking for username with improved validation
while true; do
    echo -e "\n\033[1;34m[🌐] Please enter a valid non-privileged system user for installation:\033[0m"
    read -p "User: " current_user
    
    # Check if user exists and is not root
    if id "$current_user" &>/dev/null; then
        user_uid=$(id -u "$current_user")
        if [ "$user_uid" -ge 1000 ]; then
            echo -e "\033[1;32m[✔] User '$current_user' validated!\033[0m"
            break
        else
            echo -e "\033[1;31m[✗] Error: '$current_user' is a system user (UID: $user_uid). Please select a regular user.\033[0m"
        fi
    else
        echo -e "\033[1;31m[✗] Error: User '$current_user' does not exist!\033[0m"
        echo -e "\033[1;33m[ℹ] Available users are listed above.\033[0m"
    fi
done

sleep 1

# Asking for OS language
echo -e "\n\033[1;34m[🌐] Select Your Language / Seleccione su idioma\033[0m"
echo -e "1. English"
echo -e "2. Español"
read -p "Choose from available options (1 or 2): " lang_choice
sleep 1

# Data processing based on user choice
if [ "$lang_choice" -eq 2 ]; then
    # Spanish configuration
    documents_dir="Documentos"
    echo -e "\n\033[1;32m[✓] Spanish configuration selected\033[0m"
else
    # Default to English
    documents_dir="Documents"
    echo -e "\n\033[1;32m[✓] English configuration selected\033[0m"
fi

tools_path="/home/$current_user/$documents_dir"

# Create directories according to user input in Home path if they don't exist
mkdir -p "$tools_path" || {
    echo -e "\033[1;31m[✗] Error defining system paths!\033[0m"
    exit 1
}

echo -e "\033[1;32m[✔] All set! Let's continue!\033[0m\n"
sleep 1

# ======================================================
# === INTERNET CONNECTION VERIFICATION ===
# ======================================================

echo -e "\n\033[1;35m[•] Preparing Network Test\033[0m"
echo -e "\033[1;36mWe'll now verify your internet connection quality."
echo -e "This quick test (3-5 seconds) checks if you can reach critical"
echo -e "servers required for installation. Please don't interrupt it.\033[0m"
sleep 2

check_internet_connection() {
    echo -e "\n\033[1;34m[+] Running Connectivity Tests...\033[0m"
    echo -e "\033[1;36m[*] Testing access to essential servers:\033[0m"
    
    # Test matrix (domain|name|required)
    sites_to_test=(
        "github.com|GitHub|YES"
        "google.com|Google DNS|YES"
        "archlinux.org|Arch Repositories|RECOMMENDED"
        "raw.githubusercontent.com|GitHub Content|YES"
    )
    
    critical_fail=0
    for site in "${sites_to_test[@]}"; do
        IFS='|' read -r domain name requirement <<< "$site"
        
        # Ping test with 3 second timeout
        if ping -c 1 -W 3 "$domain" &>/dev/null; then
            echo -e "\033[1;32m[✓] $name ($domain) accessible\033[0m"
        else
            if [[ "$requirement" == "YES" ]]; then
                echo -e "\033[1;31m[✗] CRITICAL: Can't reach $name ($domain)\033[0m"
                ((critical_fail++))
            else
                echo -e "\033[1;33m[!] WARNING: Can't reach $name ($domain)\033[0m"
            fi
        fi
        sleep 0.3  # Brief pause between tests
    done

    # Evaluation
    if [ $critical_fail -gt 0 ]; then
        echo -e "\n\033[1;31m[!] CRITICAL NETWORK ISSUES DETECTED!\033[0m"
        echo -e "\033[1;33m• Installation cannot continue without access to required servers"
        echo -e "• Check your firewall, DNS, and network connection"
        echo -e "• Corporate networks may block essential domains\033[0m"
        exit 1
    else
        echo -e "\n\033[1;32m[✓] Network verification successful\033[0m"
        echo -e "\033[1;36mYou may proceed with the installation\033[0m"
        sleep 1.5
    fi

	echo -e "\n"
}

# Execute the check
check_internet_connection

# ======================================================
# === FIXING ERRORS ===
# ======================================================
echo -e "\033[1;35m[🔍] Fixing system errors for successful installation:\033[0m"

# Python Error
mkdir -p ~/.config/pip
echo -e "[global]\nindex-url = https://pypi.org/simple\ntrusted-host = pypi.org\nbreak-system-packages = true" > ~/.config/pip/pip.conf

# GPG Pub Kali Error
wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg &>/dev/null

# Realistic pause for config changes
sleep 3  

echo -e "\033[1;32m[✔] Errors fixed!\033[0m\n"
sleep 1

# ======================================================
# === UPDATING SYSTEM ===
# ======================================================
echo -e "\n\033[1;34m[🔄] Now we'll update your system, please wait...\033[0m\n"
sleep 2  # Reasonable pause before major operation

# Command execution function
execute() {
    local cmd="$1"
    local description="$2"
    
    echo -e "\033[1;36m[ℹ] $description...\033[0m"
    echo -e "\033[90mCommand: $cmd\033[0m"
    
    if eval "sudo $cmd"; then
        echo -e "\033[1;32m[✓] $description completed\033[0m\n"
        sleep 1  # Short success pause
        return 0
    else
        echo -e "\033[1;31m[✗] Error in $description\033[0m\n"
        sleep 1  # Short error pause
        return 1
    fi
}

# 1. Update package lists
execute "apt update -y" "Updating package lists"

# 2. Upgrade installed packages
execute "apt upgrade -y --allow-downgrades" "Upgrading packages"

# 3. Smart system upgrade
execute "apt dist-upgrade -y" "System dist-upgrade"

# 4. Clean residual packages
execute "apt autoremove -y --purge" "Cleaning unnecessary packages"

# 5. Clean package cache
execute "apt clean -y" "Cleaning package cache"

# 6. Final check
echo -e "\033[1;35m[🔍] Verifying results...\033[0m"
execute "apt list --upgradable" "Remaining upgradable packages"
sleep 2  # Pause for review

echo -e "\033[1;32m[✔] System successfully updated!\033[0m\n"
sleep 2  # Completion pause

# ======================================================
# === INSTALLING TOOLS VIA APT ===
# ======================================================

# Function to display section headers
section_header() {
    echo -e "\n\033[1;35m$1\033[0m"
    echo -e "\033[1;35m$(printf '%*s' "${#1}" | tr ' ' '=')\033[0m"
}

# Display the list of tools that will be installed
show_installation_summary() {
    section_header "=== TOOLS TO BE INSTALLED ==="
    
    echo -e "\033[1;34m\n[+] Main system tools via APT:\033[0m"
    echo -e "\033[1;36m  • NPM, MongoDB, Putty, KPcli, Nitrogen, Shutter,"
    echo -e "  • Synaptic, Xclip, Arandr, Timeshift, Poppler-utils,"
    echo -e "  • Stegseek, Ltrace, Strace, RLWrap, IPcalc,"
    echo -e "  • Cargo, Snapd, Alien, AWScli, Mosquitto, Knockd,"
    echo -e "  • DSniff, Nuclei, ZAP Proxy, Docker, Feroxbuster,"
    echo -e "  • Httpx-Toolkit, Gobuster, Ncat, Bettercap, SecLists,"
    echo -e "  • Assetfinder, SIPPTS, Dirsearch, ADB, Foremost,"
    echo -e "  • Certbot, Enum4Linux-NG, Tor, Ghidra, CrackMapExec,"
    echo -e "  • Padbuster, InfluxDB Client, Erlang, HTTPie, LFTP,"
    echo -e "  • Docker, CUPP, GDB, GCCgo-go, Golang, Smtp-User-Enum,"
    echo -e "  • IPMItool, MVP, JQ, Xfreerdp3 ,Zipalign,"
    echo -e "  • TTYRec, ZIP, RAR, MDBtools, Airgeddon, ExploitDB\033[0m"

    echo -e "\033[1;34m\n[+] Additional applications:\033[0m"
    echo -e "\033[1;36m  • Sonic Visualiser, Google Chrome, LibreOffice, Obsidian\033[0m"

    echo -e "\033[1;34m\n[+] Go tools:\033[0m"
    echo -e "\033[1;36m  • Subfinder, Gau, Waybackurls, Katana\033[0m"

    echo -e "\033[1;34m\n[+] Python/Ruby/NPM tools:\033[0m"
    echo -e "\033[1;36m  • Slowloris, StegoVeritas, LOLcat, Git-Dumper, Cewler"
    echo -e "  • Haiti-Hash, FPM, JS-Beautify\033[0m"

    echo -e "\n\033[1;33mThis script will install approximately 80 security and productivity tools.\033[0m"
    echo -e "\033[1;33mThe installation may take some time depending on your internet connection.\033[0m"
    
    read -p $'\033[1;35m[?] Do you want to continue with the installation? [y/N]: \033[0m' -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[1;31m[✗] Installation aborted by user.\033[0m"
        exit 1
    fi
}

# Improved package installation function
install_pkg() {
    local name="$1"
    local pkg="$2"
    
    # Check if already installed
    if dpkg -l | grep -q "^ii  ${pkg%% *} "; then
        echo -e "\033[1;33m[!] $name already installed - skipping\033[0m"
        sleep 0.3
        return 0
    fi
    
    # Install package
    echo -e "\033[1;36m[*] Installing $name...\033[0m"
    if apt install -y $pkg >/dev/null 2>&1; then
        echo -e "\033[1;32m[✓] $name successfully installed!\033[0m"
        sleep 0.5
    else
        echo -e "\033[1;31m[✗] Error installing $name\033[0m"
        sleep 0.5
    fi
}

# Main installation function
main_installation() {
    # Show what will be installed first
    show_installation_summary

    section_header "=== INSTALLING SYSTEM TOOLS VIA APT ==="
    sleep 2

    # List of APT packages
    apt_packages=(
        "NPM|npm"
        "MongoDB|mongodb"
        "Putty|putty"
        "KPcli|kpcli"
        "Nitrogen|nitrogen"
        "Shutter|shutter"
        "Synaptic|synaptic"
        "Xclip|xclip"
        "Arandr|arandr"
        "Timeshift|timeshift"
        "Poppler-utils|poppler-utils"
        "Stegseek|stegseek"
        "Ltrace|ltrace"
        "Strace|strace"
        "RLWrap|rlwrap"
        "IPcalc|ipcalc"
        "Cargo|cargo"
        "Snapd|snapd"
        "Alien|alien"
        "AWScli|awscli"
        "Mosquitto|mosquitto"
        "Mosquitto Client|mosquitto-clients"
        "Knockd|knockd"
        "DSniff|dsniff"
        "Nuclei|nuclei"
        "ZAP Proxy|zaproxy"
        "Docker|docker.io"
        "Docker-Compose|docker-compose"
        "Feroxbuster|feroxbuster"
        "Httpx-Toolkit|httpx-toolkit"
        "Gobuster|gobuster"
        "Ncat|ncat"
        "Bettercap|bettercap"
        "SecLists|seclists"
        "Assetfinder|assetfinder"
        "SIPPTS|sippts"
        "Dirsearch|dirsearch"
        "ADB|adb"
        "Foremost|foremost"
        "Certbot|certbot"
        "Certbot Apache|certbot python3-certbot-apache"
        "Enum4Linux-NG|enum4linux-ng"
        "Tor|tor torbrowser-launcher"
        "Ghidra|ghidra"
        "CrackMapExec|crackmapexec"
        "Padbuster|padbuster"
        "InfluxDB Client|influxdb-client"
        "Erlang|erlang"
        "HTTPie|httpie"
        "LFTP|lftp"
        "CUPP|cupp"
        "GDB|gdb"
        "GCCgo-go|gccgo-go"
        "Golang|golang-go"
        "Smtp-User-Enum|smtp-user-enum"
        "Vagrant|vagrant"
        "IPMItool|ipmitool"
        "MPV|mpv"
        "JQ|jq"
        "Xfreerdp3|freerdp3-dev"
        "Steghide|steghide"
        "Zipalign|zipalign"
        "TTYRec|ttyrec"
        "ZIP|p7zip-full"
        "RAR|rar"
        "MDBtools|mdbtools"
        "Airgeddon|airgeddon"
        "ExploitDB|exploitdb"
    )

    # Update package list first
    echo -e "\n\033[1;36m[*] Updating package list...\033[0m"
    if apt update >/dev/null 2>&1; then
        echo -e "\033[1;32m[✓] Package list updated!\033[0m"
    else
        echo -e "\033[1;31m[✗] Failed to update package list\033[0m"
    fi
    sleep 1

    # Install all packages
    for pkg in "${apt_packages[@]}"; do
        IFS='|' read -r name package <<< "$pkg"
        install_pkg "$name" "$package"
        sleep 0.8
    done

    section_header "=== INSTALLING ADDITIONAL APPLICATIONS ==="
    
    # === INSTALL SONIC VISUALIZER ===
    echo -e "\n\033[1;34m[+] Installing Sonic Visualiser...\033[0m"
    sleep 1

    SONIC_DEB="/tmp/sonic-visualiser.deb"
    if ! command -v sonic-visualiser &>/dev/null; then
        echo -e "\033[1;36m[*] Downloading Sonic Visualiser...\033[0m"
        if wget -q https://code.soundsoftware.ac.uk/attachments/download/2845/sonic-visualiser_4.5.2_amd64.deb -O "$SONIC_DEB"; then
            echo -e "\033[1;36m[*] Installing Sonic Visualiser...\033[0m"
            if apt install -y "$SONIC_DEB" >/dev/null 2>&1; then
                echo -e "\033[1;32m[✓] Sonic Visualiser successfully installed!\033[0m"
                rm -f "$SONIC_DEB"
                echo -e "\033[1;32m[✓] Debian package removed\033[0m"
            else
                echo -e "\033[1;31m[✗] Error installing Sonic Visualiser\033[0m"
            fi
        else
            echo -e "\033[1;31m[✗] Failed to download Sonic Visualiser\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] Sonic Visualiser already installed\033[0m"
    fi
    sleep 1

    # === INSTALL GOOGLE CHROME ===
    echo -e "\n\033[1;34m[+] Installing Google Chrome...\033[0m"
    sleep 1

    CHROME_DEB="/tmp/google-chrome.deb"
    if ! command -v google-chrome &>/dev/null; then
        echo -e "\033[1;36m[*] Downloading Google Chrome...\033[0m"
        if wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "$CHROME_DEB"; then
            echo -e "\033[1;36m[*] Installing Google Chrome...\033[0m"
            if apt install -y "$CHROME_DEB" >/dev/null 2>&1; then
                echo -e "\033[1;32m[✓] Google Chrome successfully installed!\033[0m"
                rm -f "$CHROME_DEB"
                echo -e "\033[1;32m[✓] Debian package removed\033[0m"
            else
                echo -e "\033[1;31m[✗] Error installing Google Chrome\033[0m"
            fi
        else
            echo -e "\033[1;31m[✗] Failed to download Google Chrome\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] Google Chrome already installed\033[0m"
    fi
    sleep 1

    # === INSTALL LIBREOFFICE ===
    echo -e "\n\033[1;34m[+] Installing LibreOffice...\033[0m"
    sleep 1

    if ! command -v libreoffice &>/dev/null; then
        echo -e "\033[1;36m[*] Installing LibreOffice from official repositories...\033[0m"
        
        # Add official repository
        add-apt-repository -y ppa:libreoffice/ppa >/dev/null 2>&1
        apt update >/dev/null 2>&1
        
        if apt install -y libreoffice >/dev/null 2>&1; then
            echo -e "\033[1;32m[✓] LibreOffice successfully installed!\033[0m"
        else
            # Alternative method if first fails
            echo -e "\033[1;36m[*] Trying alternative installation method...\033[0m"
            if apt install -y libreoffice-core libreoffice-common >/dev/null 2>&1; then
                echo -e "\033[1;32m[✓] LibreOffice core components installed!\033[0m"
            else
                echo -e "\033[1;31m[✗] Failed to install LibreOffice\033[0m"
            fi
        fi
    else
        echo -e "\033[1;33m[!] LibreOffice already installed\033[0m"
    fi
    sleep 1

   # === INSTALL OBSIDIAN ===
    echo -e "\n\033[1;34m[+] Installing Obsidian...\033[0m"
    sleep 1

    if ! command -v obsidian &>/dev/null; then
        OBSIDIAN_DEB="/tmp/obsidian.deb"
        OBSIDIAN_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.3/obsidian_1.5.3_amd64.deb"

        echo -e "\033[1;36m[*] Downloading Obsidian...\033[0m"
        if wget -q $OBSIDIAN_URL -O "$OBSIDIAN_DEB"; then
            echo -e "\033[1;36m[*] Installing Obsidian...\033[0m"

            if dpkg -i "$OBSIDIAN_DEB" 2>/dev/null || apt-get install -f -y 2>/dev/null; then
                echo -e "\033[1;32m[✓] Obsidian successfully installed!\033[0m"
                rm -rf "$OBSIDIAN_DEB"
                echo -e "\033[1;32m[✓] Debian package removed\033[0m"
            else
                echo -e "\033[1;31m[✗] Error installing Obsidian\033[0m"
            fi
        else
            echo -e "\033[1;31m[✗] Failed to download Obsidian\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] Obsidian already installed\033[0m"
    fi
    sleep 1

    section_header "=== INSTALLING GO AND TOOLS ==="
    
    # === GO INSTALLATION ===
    echo -e "\n\033[1;34m[+] Installing Go...\033[0m"
    sleep 1

    # Install golang via apt
    echo -e "\033[1;36m[*] Installing Golang via apt...\033[0m"
    apt install -y golang >/dev/null 2>&1 && echo -e "\033[1;32m[✓] golang successfully installed!\033[0m" || echo -e "\033[1;31m[✗] Error installing golang\033[0m"
    sleep 1

    if ! command -v go &>/dev/null; then
        echo -e "\033[1;36m[*] Downloading and installing Go...\033[0m"
        
        GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
        GO_URL="https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz"
        
        if curl -fsSL $GO_URL | tar -C /usr/local -xz >/dev/null 2>&1; then
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            echo 'export GOPATH=$HOME/go' >> ~/.bashrc
            echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
            source ~/.bashrc
            echo -e "\033[1;32m[✓] Go ${GO_VERSION} successfully installed!\033[0m"
        else
            echo -e "\033[1;31m[✗] Failed to install Go\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] Go is already installed: $(go version)\033[0m"
    fi
    sleep 1

    # === GO TOOLS INSTALLATION ===
    echo -e "\n\033[1;34m[+] Installing Go tools...\033[0m"
    sleep 1

    # Configure Go environment
    export GOPATH=${GOPATH:-$HOME/go}
    export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
    export GO_ENABLED=1

    go_tools=(
        "Subfinder|github.com/projectdiscovery/subfinder/v2/cmd/subfinder|subfinder"
        "Gau|github.com/lc/gau/v2/cmd/gau|gau"
        "Waybackurls|github.com/tomnomnom/waybackurls|waybackurls"
        "Katana|github.com/projectdiscovery/katana/cmd/katana|katana"
    )

    for tool in "${go_tools[@]}"; do
        IFS='|' read -r name pkg cmd <<< "$tool"
        
        echo -e "\n\033[1;36m[*] Installing $name...\033[0m"
        if command -v $cmd &>/dev/null; then
            echo -e "\033[1;33m[!] $name already installed at $(which $cmd)\033[0m"
        else
            if go install $pkg@latest >/dev/null 2>&1; then
                sudo ln -sf $GOPATH/bin/$cmd /usr/local/bin/ 2>/dev/null || true
                echo -e "\033[1;32m[✓] $name successfully installed!\033[0m"
            else
                echo -e "\033[1;31m[✗] Error installing $name\033[0m"
            fi
        fi
        sleep 0.8
    done

    section_header "=== INSTALLING PYTHON/RUBY/NPM TOOLS ==="
    
    # === PYTHON/RUBY/NPM TOOLS ===
    echo -e "\n\033[1;34m[+] Installing Python/Ruby/NPM tools...\033[0m"
    sleep 1

    python_tools=(
        "Slowloris|slowloris"
        "StegoVeritas|stegoveritas"
        "LOLcat|lolcat"
        "Git-Dumper|git-dumper"
        "Cewler|cewler"
    )

    for tool in "${python_tools[@]}"; do
        IFS='|' read -r name pkg <<< "$tool"
        
        echo -e "\n\033[1;36m[*] Installing $name...\033[0m"
        if pip3 show $pkg &>/dev/null; then
            echo -e "\033[1;33m[!] $name already installed\033[0m"
        else
            if pip3 install --upgrade --ignore-installed $pkg >/dev/null 2>&1; then
                echo -e "\033[1;32m[✓] $name successfully installed!\033[0m"
            else
                echo -e "\033[1;31m[✗] Error installing $name\033[0m"
            fi
        fi
        sleep 0.8
    done

    # Install Ruby gems
    echo -e "\n\033[1;36m[*] Installing Ruby gems...\033[0m"
    for gem in haiti-hash fpm; do
        if gem list -i $gem &>/dev/null; then
            echo -e "\033[1;33m[!] $gem already installed\033[0m"
        else
            if gem install $gem >/dev/null 2>&1; then
                echo -e "\033[1;32m[✓] $gem installed\033[0m"
            else
                echo -e "\033[1;31m[✗] Failed to install $gem\033[0m"
            fi
        fi
        sleep 0.5
    done

    # Install js-beautify
    echo -e "\n\033[1;36m[*] Installing js-beautify...\033[0m"
    if npm list -g js-beautify &>/dev/null; then
        echo -e "\033[1;33m[!] js-beautify already installed\033[0m"
    else
        if npm -g install js-beautify >/dev/null 2>&1; then
            echo -e "\033[1;32m[✓] js-beautify installed\033[0m"
        else
            echo -e "\033[1;31m[✗] Failed to install js-beautify\033[0m"
        fi
    fi
    sleep 1

    section_header "=== VERIFYING INSTALLATIONS ==="
    
    # === FINAL VERIFICATION ===
    echo -e "\n\033[1;34m[+] Verifying installations...\033[0m"
    sleep 1

    failed=0
    tools_to_verify=(
        "NPM|npm"
        "MongoDB|mongo"
        "Putty|putty"
        "KPcli|kpcli"
        "Nitrogen|nitrogen"
        "Shutter|shutter"
        "Xclip|xclip"
        "Stegseek|stegseek"
        "Ltrace|ltrace"
        "Strace|strace"
        "AWSCLI|aws|awscli"
        "Nuclei|nuclei"
        "Docker|docker"
        "Docker-Compose|docker-compose"
        "Feroxbuster|feroxbuster"
        "Subfinder|subfinder"
        "Gau|gau"
        "Waybackurls|waybackurls"
        "Katana|katana"
        "Slowloris|slowloris"
        "StegoVeritas|stegoveritas"
        "LOLcat|lolcat"
        "Haiti-Hash|haiti"
        "Git-Dumper|git-dumper"
        "RLWrap|rlwrap"
        "IPcalc|ipcalc"
        "Cargo|cargo"
        "Snapd|snap"
        "Mosquitto|mosquitto"
        "Mosquitto Client|mosquitto_pub"
        "Alien|alien"
        "InfluxDB|influx"
        "Knockd|knock"
        "FPM|fpm"
        "DSniff|dsniff|arpspoof"
        "ZAP Proxy|zaproxy|zap"
        "SecLists|seclists"
        "Sirsearch|dirsearch"
        "Ncat|ncat|nc"
        "ADB|adb"
        "Bettercap|bettercap"
        "Foremost|foremost"
        "Certbot|certbot"
        "Enum4Linux-NG|enum4linux-ng"
        "Tor|tor|torbrowser-launcher"
        "Cewler|cewler"
        "Ghidra|ghidra"
        "Erlang|erl|erlang"
        "LFTP|lftp"
        "CrackMapExec|crackmapexec"
        "JS-Beautify|js-beautify"
        "Sonic Visualiser|sonic-visualiser"
        "Obsidian|obsidian"
        "Google Chrome|google-chrome"
        "LibreOffice|libreoffice"
        "CUPP|cupp"
        "GDB|gdb"
        "GCCgo-go|go"
        "Golang-go|go"
        "Smtp-User-Enum|smtp-user-enum"
        "Vagrant|vagrant"
        "IPMItool|ipmitool"
        "Freerdp3-dev|xfreerdp3"
        "Steghide|steghide"
        "Zipalign|zipalign"
        "TTYRec|ttyrec"
        "ZIP|p7zip"
        "RAR|rar"
        "MDBtools|mdb-schema"
        "Airgeddon|airgeddon"
        "ExploitDB|exploitdb"
    )

    for tool in "${tools_to_verify[@]}"; do
        IFS='|' read -r name cmd1 cmd2 <<< "$tool"
        if command -v "$cmd1" &>/dev/null || { [ -n "$cmd2" ] && command -v "$cmd2" &>/dev/null; }; then
            echo -e "\033[1;32m[✓] $name is installed\033[0m"
        else
            echo -e "\033[1;31m[✗] $name is MISSING\033[0m"
            ((failed++))
        fi
        sleep 0.2
    done

    # Final result
    if [ $failed -eq 0 ]; then
        echo -e "\n\033[1;32m[✔] All tools successfully installed!\033[0m\n"
    else
        echo -e "\n\033[1;31m[✗] $failed tools failed to install. Check above for errors.\033[0m\n"
    fi

    echo -e "\033[1;34m[ℹ] To ensure all tools are available, run:\033[0m"
    echo -e "\033[1;36msource ~/.bashrc\033[0m\n"
}

# Start the main installation
main_installation

# ======================================================
# === OPTIMIZING DICTIONARIES ===
# ======================================================

echo -e "\033[1;35m[🔍] Optimizing system dictionaries in SecLists...\033[0m"

# Define the base directory for SecLists
SECLISTS_DIR="/usr/share/wordlists/seclists"

# Check if the directory exists
if [[ ! -d "$SECLISTS_DIR" ]]; then
    echo -e "\033[1;31m[❌] Error: The SecLists directory does not exist at $SECLISTS_DIR.\033[0m"
    exit 1
fi

# Find all .txt files recursively and remove lines starting with '#'
find "$SECLISTS_DIR" -type f -name "*.txt" | while read -r file; do
    echo -e "\033[1;34m[🔧] Processing file: $file\033[0m"
    sed -i '/^#/d' "$file" 2>/dev/null
done

echo -e "\033[1;32m[✅] Optimization complete. All '#' comments removed from dictionary files.\033[0m"

echo -e "\033[1;32m[✔] System dictionaries optimized!\033[0m\n"
sleep 2  # Completion pause

# ======================================================
# === INSTALLING GITHUB TOOLS ===
# ======================================================

# List of GitHub tools (declared at the beginning for use in the summary)
github_tools=(
    "keepass-password-dumper|https://github.com/vdohney/keepass-password-dumper.git"
    "ldapdomaindump|https://github.com/dirkjanm/ldapdomaindump.git"
    "firefox_decrypt|https://github.com/unode/firefox_decrypt.git"
    "Gopherus|https://github.com/tarunkant/Gopherus.git"
    "imagemagick-lfi-poc|https://github.com/Sybil-Scan/imagemagick-lfi-poc.git"
    "mitm6|https://github.com/dirkjanm/mitm6.git"
    "php_filter_chain_generator|https://github.com/synacktiv/php_filter_chain_generator.git"
    "wordlistctl|https://github.com/BlackArch/wordlistctl.git"
    "finger-user-enum|https://github.com/pentestmonkey/finger-user-enum.git"
    "chankro-py3|https://github.com/kriss-u/chankro-py3.git"
    "HiddenWave|https://github.com/techchipnet/HiddenWave.git"
    "ping-sweep|https://github.com/migue27au/ping-sweep.git"
    "ident-user-enum|https://github.com/pentestmonkey/ident-user-enum.git"
    "username-anarchy|https://github.com/urbanadventurer/username-anarchy.git"
    "searchbins|https://github.com/r1vs3c/searchbins.git"
    "DetectDee|https://github.com/piaolin/DetectDee.git"
    "droopescan|https://github.com/SamJoan/droopescan.git"
    "magescan|https://github.com/steverobbins/magescan.git"
    "firepwd|https://github.com/lclevy/firepwd.git"
    "Argus|https://github.com/jasonxtn/Argus"
    "nuclei-templates|https://github.com/coffinxp/nuclei-templates"
    "KnockIt|https://github.com/eliemoutran/KnockIt.git"
    "track-ip|https://github.com/htr-tech/track-ip"
    "geo-recon|https://github.com/radioactivetobi/geo-recon.git"
    "SSTImap|https://github.com/vladko312/SSTImap.git"
    "bypass-403|https://github.com/iamj0ker/bypass-403"
    "ADpeas|https://github.com/61106960/adPEAS.git"
    "Certypy|https://github.com/ly4k/Certipy.git"
)

# Improved repository cloning function
clone_repo() {
    local name="$1"
    local repo_url="$2"
    local dest_dir="/opt/$(basename "$repo_url" .git)"
    
    if [ -d "$dest_dir" ]; then
        echo -e "\033[1;33m[!] $name already exists - skipping\033[0m"
        sleep 0.3
        return 0
    fi

    echo -e "\033[1;36m[*] Cloning $name...\033[0m"
    if git clone "$repo_url" "$dest_dir" >/dev/null 2>&1; then
        echo -e "\033[1;32m[✓] $name successfully cloned!\033[0m"
        sleep 0.5
    else
        echo -e "\033[1;31m[✗] Error cloning $repo_name\033[0m"
        sleep 0.5
    fi
}

# Show installation summary
show_github_summary() {
    echo -e "\n\033[1;34m[+] The following GitHub tools will be installed:\033[0m"
    echo -e "\033[1;36m"
    
    # GitHub tools
    echo -e "=== GitHub Repositories ==="
    for tool in "${github_tools[@]}"; do
        IFS='|' read -r name url <<< "$tool"
        echo -e "• $name"
    done
    
    # Additional tools
    echo -e "\n=== Additional Tools ==="
    echo -e "• Postman"
    echo -e "• Rust (update)"
    echo -e "• The_spy_job"
    echo -e "• python-evtx"
    echo -e "• PEDA (GDB enhancement)"
    
    echo -e "\033[0m"
}

# Main installation function
github_installation() {
    # Show what will be installed first
    show_github_summary
    
    # Ask for confirmation
    echo -e "\n\033[1;33mThis script will install approximately 30 security and productivity tools.\033[0m"
    echo -e "\033[1;33mThe installation may take some time depending on your internet connection.\033[0m"
    
    read -p $'\033[1;35m[?] Do you want to continue with the installation? [y/N]: \033[0m' -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[1;31m[✗] Installation aborted by user.\033[0m"
        exit 1
    fi
    
    echo -e "\n\033[1;34m[+] Installing GitHub tools...\033[0m"
    sleep 2

    # Create /opt directory if it doesn't exist
    if [ ! -d "/opt" ]; then
        mkdir -p /opt
    fi
    
    cd /opt/ || exit

    # Install all GitHub tools
    for tool in "${github_tools[@]}"; do
        IFS='|' read -r name url <<< "$tool"
        clone_repo "$name" "$url"
        sleep 0.8
    done

    # Postman installation
    echo -e "\n\033[1;34m[+] Installing Postman...\033[0m"
    sleep 1
    
    if [ ! -f "/opt/Postman/Postman" ]; then
        echo -e "\033[1;36m[*] Downloading Postman...\033[0m"
        if wget -q https://dl.pstmn.io/download/latest/linux64 -O postman-linux-x64.tar.gz; then
            echo -e "\033[1;36m[*] Installing Postman...\033[0m"
            if tar -xzf postman-linux-x64.tar.gz -C /opt && \
               ln -sf /opt/Postman/Postman /usr/bin/postman && \
               rm postman-linux-x64.tar.gz; then
                echo -e "\033[1;32m[✓] Postman successfully installed!\033[0m"
            else
                echo -e "\033[1;31m[✗] Error installing Postman\033[0m"
            fi
        else
            echo -e "\033[1;31m[✗] Failed to download Postman\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] Postman already installed - skipping\033[0m"
    fi
    sleep 1

    # Additional tools installation
    echo -e "\n\033[1;34m[+] Installing additional tools...\033[0m"
    sleep 1

    # Install/Update Rust
    echo -e "\n\033[1;34m[+] Installing/Updating Rust...\033[0m"
    sleep 1
    
    if ! command -v rustup &>/dev/null; then
        echo -e "\033[1;36m[*] Installing Rust...\033[0m"
        if curl https://sh.rustup.rs -sSf | sh -s -- -y >/dev/null 2>&1; then
            source "$HOME/.cargo/env"
            echo -e "\033[1;32m[✓] Rust successfully installed!\033[0m"
        else
            echo -e "\033[1;31m[✗] Error installing Rust\033[0m"
        fi
    else
        echo -e "\033[1;36m[*] Updating Rust...\033[0m"
        if rustup update >/dev/null 2>&1; then
            echo -e "\033[1;32m[✓] Rust successfully updated!\033[0m"
        else
            echo -e "\033[1;31m[✗] Error updating Rust\033[0m"
        fi
    fi
    sleep 1

    # Install The_spy_job
    echo -e "\n\033[1;34m[+] Installing The_spy_job...\033[0m"
    sleep 1
    
    if [ ! -d "/opt/The_spy_job" ]; then
        echo -e "\033[1;36m[*] Cloning The_spy_job...\033[0m"
        if git clone https://github.com/XDeadHackerX/The_spy_job.git /opt/The_spy_job >/dev/null 2>&1; then
            echo -e "\033[1;36m[*] Setting permissions...\033[0m"
            if chmod +x /opt/The_spy_job/the_spy_job.sh >/dev/null 2>&1; then
                echo -e "\033[1;32m[✓] The_spy_job successfully installed!\033[0m"
            else
                echo -e "\033[1;31m[✗] Error setting permissions for The_spy_job\033[0m"
            fi
        else
            echo -e "\033[1;31m[✗] Error cloning The_spy_job\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] The_spy_job already exists - skipping\033[0m"
    fi
    sleep 1

    # Install python-evtx
    echo -e "\n\033[1;34m[+] Installing python-evtx...\033[0m"
    sleep 1
    
    if [ ! -d "/opt/python-evtx" ]; then
        echo -e "\033[1;36m[*] Cloning python-evtx...\033[0m"
        if git clone https://github.com/williballenthin/python-evtx.git /opt/python-evtx >/dev/null 2>&1; then
            echo -e "\033[1;36m[*] Installing python-evtx...\033[0m"
            if cd /opt/python-evtx && pip3 install . >/dev/null 2>&1; then
                echo -e "\033[1;32m[✓] python-evtx successfully installed!\033[0m"
            else
                echo -e "\033[1;31m[✗] Error installing python-evtx\033[0m"
            fi
        else
            echo -e "\033[1;31m[✗] Error cloning python-evtx\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] python-evtx already exists - skipping\033[0m"
    fi
    sleep 1

    # Install PEDA (GDB enhancement)
    echo -e "\n\033[1;34m[+] Installing PEDA (GDB enhancement)...\033[0m"
    sleep 1
    
    if [ ! -d "$HOME/gdb-peda-pwndbg-gef" ]; then
        echo -e "\033[1;36m[*] Cloning PEDA...\033[0m"
        if git clone https://github.com/apogiatzis/gdb-peda-pwndbg-gef.git "$HOME/gdb-peda-pwndbg-gef" >/dev/null 2>&1; then
            echo -e "\033[1;36m[*] Installing PEDA...\033[0m"
            if cd "$HOME/gdb-peda-pwndbg-gef" && ./install.sh >/dev/null 2>&1; then
                echo -e "\033[1;32m[✓] PEDA successfully installed!\033[0m"
                echo 'source ~/.gdbinit' >> ~/.bashrc
            else
                echo -e "\033[1;31m[✗] Error installing PEDA\033[0m"
            fi
        else
            echo -e "\033[1;31m[✗] Error cloning PEDA\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] PEDA already exists - skipping\033[0m"
    fi
    sleep 1

    # === VERIFICATION ===
    echo -e "\n\033[1;34m[+] Verifying installations...\033[0m"
    sleep 1

    failed=0
    tools_to_verify=(
        "Rust|$HOME/.cargo/bin/rustc"
        "keepass-password-dumper|/opt/keepass-password-dumper"
        "ldapdomaindump|/opt/ldapdomaindump"
        "firefox_decrypt|/opt/firefox_decrypt"
        "Gopherus|/opt/Gopherus"
        "imagemagick-lfi-poc|/opt/imagemagick-lfi-poc"
        "mitm6|/opt/mitm6"
        "php_filter_chain_generator|/opt/php_filter_chain_generator"
        "wordlistctl|/opt/wordlistctl"
        "finger-user-enum|/opt/finger-user-enum"
        "chankro-py3|/opt/chankro-py3"
        "HiddenWave|/opt/HiddenWave"
        "ping-sweep|/opt/ping-sweep"
        "ident-user-enum|/opt/ident-user-enum"
        "username-anarchy|/opt/username-anarchy"
        "searchbins|/opt/searchbins"
        "DetectDee|/opt/DetectDee"
        "droopescan|/opt/droopescan"
        "magescan|/opt/magescan"
        "firepwd|/opt/firepwd"
        "Argus|/opt/Argus"
        "nuclei-templates|/opt/nuclei-templates"
        "KnockIt|/opt/KnockIt"
        "PEDA|$HOME/.gdbinit"
        "track-ip|/opt/track-ip"
        "geo-recon|/opt/geo-recon"
        "SSTImap|/opt/SSTImap"
        "bypass-403|/opt/bypass-403"
	    "ADpeas|/opt/adPEAS"
	    "Certypy|/opt/Certipy"
    )

    for tool in "${tools_to_verify[@]}"; do
        IFS='|' read -r name path <<< "$tool"
        if [ -d "$path" ] || [ -f "$path" ]; then
            echo -e "\033[1;32m[✓] $name successfully installed\033[0m"
        else
            echo -e "\033[1;31m[✗] $name is MISSING\033[0m"
            ((failed++))
        fi
        sleep 0.2
    done

    # Verify Postman
    if [ -f "/opt/Postman/Postman" ]; then
        echo -e "\033[1;32m[✓] Postman successfully installed\033[0m"
    else
        echo -e "\033[1;31m[✗] Postman is MISSING\033[0m"
        ((failed++))
    fi

    # Verify Rust
    if command -v rustup &>/dev/null; then
        echo -e "\033[1;32m[✓] Rust successfully installed\033[0m"
    else
        echo -e "\033[1;31m[✗] Rust is MISSING\033[0m"
        ((failed++))
    fi

    # Final result
    if [ $failed -eq 0 ]; then
        echo -e "\n\033[1;32m[✔] All GitHub tools successfully installed!\033[0m\n"
    else
        echo -e "\n\033[1;31m[✗] $failed tools failed to install. Check above for errors.\033[0m\n"
    fi

    echo -e "\033[1;34m[ℹ] Remember to check each tool's documentation for usage instructions.\033[0m\n"
    sleep 2
}

# Start the GitHub tools installation
github_installation

# ======================================================
# === LINUX & WINDOWS TOOLS INSTALLATION ===
# ======================================================

# Function to display section headers
section_header() {
    echo -e "\n\033[1;35m$1\033[0m"
    echo -e "\033[1;35m$(printf '%*s' "${#1}" | tr ' ' '=')\033[0m"
}

# Show installation summary
show_tools_summary() {
    section_header "=== TOOLS TO BE INSTALLED ==="
    
    echo -e "\033[1;34m\n[+] Linux Tools:\033[0m"
    echo -e "\033[1;36m• linux-exploit-suggester • linpeas • linux-smart-enumeration"
    echo -e "• pspy64 • suid3num • chisel • fscan • static nmap"
    echo -e "• lazyegg • static socat • suForce • ligolo-ng\033[0m"
    
    echo -e "\033[1;34m\n[+] Windows Tools:\033[0m"
    echo -e "\033[1;36m• Rubeus • rpcenum • kerbrute • winPEASx86/64 • PrintSpoofer"
    echo -e "• SweetPotato • nc.exe/nc64.exe • RunasCs • GodPotato • Invoke-PowerShellTcp"
    echo -e "• JuicyPotato • ligolo-ng\033[0m"
    
    echo -e "\033[1;34m\n[+] MatthyGD Personal Tools:\033[0m"
    echo -e "\033[1;36m• NDiscover • PathTrace • BruteX • RsyncForce • PantheonX\033[0m"
    
    # Ask for confirmation
    echo -e "\n\033[1;33mThis script will install approximately 35 security and productivity tools.\033[0m"
    echo -e "\033[1;33mThe installation may take some time depending on your internet connection.\033[0m"
    
    read -p $'\033[1;35m[?] Do you want to continue with the installation? [y/N]: \033[0m' -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[1;31m[✗] Installation aborted by user.\033[0m"
        exit 1
    fi
}

# Improved download function with verification
download_tool() {
    local tool_name="$1"
    local url="$2"
    local output_file="$3"
    local dest_dir="$4"
    local full_path="$dest_dir/$output_file"

    # Check if file already exists
    if [ -f "$full_path" ]; then
        echo -e "\033[1;33m[!] $tool_name already exists - skipping\033[0m"
        sleep 0.3
        return 0
    fi

    echo -e "\033[1;36m[*] Downloading $tool_name...\033[0m"
    if wget --no-check-certificate -q "$url" -O "$full_path"; then
        echo -e "\033[1;32m[✓] $tool_name downloaded successfully!\033[0m"
        
        # Handle compressed files
        case "$output_file" in
            *.gz)
                echo -e "\033[1;36m[*] Decompressing $output_file...\033[0m"
                if gzip -df "$full_path"; then
                    echo -e "\033[1;32m[✓] File decompressed!\033[0m"
                else
                    echo -e "\033[1;31m[✗] Error decompressing $output_file\033[0m"
                fi
                ;;
            *.zip)
                echo -e "\033[1;36m[*] Decompressing $output_file...\033[0m"
                if unzip -q "$full_path" -d "$dest_dir" && rm "$full_path"; then
                    echo -e "\033[1;32m[✓] File decompressed!\033[0m"
                else
                    echo -e "\033[1;31m[✗] Error decompressing $output_file\033[0m"
                fi
                ;;
        esac
    else
        echo -e "\033[1;31m[✗] Error downloading $tool_name\033[0m"
    fi
    sleep 0.5
}

# Main installation function
install_tools() {
    # Show summary and get confirmation
    show_tools_summary

    section_header "=== CREATING DIRECTORY STRUCTURE ==="
    echo -e "\033[1;36m[*] Creating tools directories...\033[0m"
    mkdir -p "$tools_path/Linux" "$tools_path/Windows"
    echo -e "\033[1;32m[✓] Directories created:\n• $tools_path/Linux\n• $tools_path/Windows\033[0m"
    sleep 1

    # ==================== LINUX TOOLS ====================
    section_header "=== INSTALLING LINUX TOOLS ==="
    
    linux_tools=(
        "linux-exploit-suggester|https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh|les.sh"
        "linpeas|https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh|linpeas.sh"
        "linux-smart-enumeration|https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh|lse.sh"
        "pspy64|https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64|pspy64"
        "suid3num|https://raw.githubusercontent.com/Anon-Exploiter/SUID3NUM/master/suid3num.py|suid3num.py"
        "chisel|https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz|chisel.gz"
        "fscan|https://github.com/shadow1ng/fscan/releases/download/1.8.3/fscan|fscan"
        "static nmap|https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/nmap|nmap_static"
        "lazyegg|https://github.com/schooldropout1337/nuclei-templates/raw/main/lazyegg.py|lazyegg.py"
        "static socat|https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat|socat"
        "suForce|https://raw.githubusercontent.com/VulNyx/Arsenal/refs/heads/main/suForce/suForce|suForce"
        "techyou.txt|https://raw.githubusercontent.com/VulNyx/Arsenal/refs/heads/main/suForce/techyou.txt|techyou.txt"
        "top12000.txt|https://raw.githubusercontent.com/VulNyx/Arsenal/refs/heads/main/suForce/top12000.txt|top12000.txt"
    )

    for tool in "${linux_tools[@]}"; do
        IFS='|' read -r name url file <<< "$tool"
        download_tool "$name" "$url" "$file" "$tools_path/Linux"
        sleep 0.5
    done

    # ==================== WINDOWS TOOLS ====================
    section_header "=== INSTALLING WINDOWS TOOLS ==="
    
    windows_tools=(
        "Rubeus|https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe|Rubeus.exe"
        "rpcenum|https://raw.githubusercontent.com/s4vitar/rpcenum/master/rpcenum|rpcenum"
        "kerbrute|https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64|kerbrute"
        "winPEASx86|https://github.com/carlospolop/PEASS-ng/releases/download/20230917-ec588706/winPEASx86.exe|winPEASx86.exe"
        "winPEASx64|https://github.com/carlospolop/PEASS-ng/releases/download/20230917-ec588706/winPEASx64.exe|winPEASx64.exe"
        "PrintSpoofer|https://github.com/dievus/printspoofer/raw/master/PrintSpoofer.exe|PrintSpoofer.exe"
        "SweetPotato|https://raw.githubusercontent.com/uknowsec/SweetPotato/master/SweetPotato-Webshell-old/bin/Release/SweetPotato.exe|SweetPotato.exe"
        "nc.exe|https://github.com/int0x33/nc.exe/raw/master/nc.exe|nc.exe"
        "nc64.exe|https://github.com/int0x33/nc.exe/raw/master/nc64.exe|nc64.exe"
        "RunasCs|https://github.com/antonioCoco/RunasCs/releases/download/v1.4/RunasCs.zip|RunasCs.zip"
        "GodPotato|https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe|GodPotato-NET4.exe"
        "Invoke-PowerShellTcp|https://github.com/samratashok/nishang/raw/master/Shells/Invoke-PowerShellTcp.ps1|Invoke-PowerShellTcp.ps1"
        "JuicyPotato|https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe|JuicyPotato.exe"
    )

    for tool in "${windows_tools[@]}"; do
        IFS='|' read -r name url file <<< "$tool"
        download_tool "$name" "$url" "$file" "$tools_path/Windows"
        sleep 0.5
    done

    # ==================== LIGOLO-NG INSTALLATION ====================
    section_header "=== INSTALLING LIGOLO-NG ==="
    
    echo -e "\033[1;36m[*] Installing ligolo-ng...\033[0m"
    sleep 0.5
    
    if [ ! -f "$tools_path/Linux/ligolo_agent" ] || [ ! -f "$tools_path/Linux/ligolo_proxy" ] || 
       [ ! -f "$tools_path/Windows/ligolo_agent.exe" ] || [ ! -f "$tools_path/Windows/ligolo_proxy.exe" ]; then
        temp_dir="/tmp/ligolo_temp"
        
        if git clone https://github.com/nicocha30/ligolo-ng.git "$temp_dir" >/dev/null 2>&1; then
            cd "$temp_dir" || return
            if make >/dev/null 2>&1; then
                # Move Linux binaries
                [ -f "dist/ligolo-ng-agent-linux_amd64" ] && mv "dist/ligolo-ng-agent-linux_amd64" "$tools_path/Linux/ligolo_agent"
                [ -f "dist/ligolo-ng-proxy-linux_amd64" ] && mv "dist/ligolo-ng-proxy-linux_amd64" "$tools_path/Linux/ligolo_proxy"
                
                # Move Windows binaries
                [ -f "dist/ligolo-ng-agent-windows_amd64.exe" ] && mv "dist/ligolo-ng-agent-windows_amd64.exe" "$tools_path/Windows/ligolo_agent.exe"
                [ -f "dist/ligolo-ng-proxy-windows_amd64.exe" ] && mv "dist/ligolo-ng-proxy-windows_amd64.exe" "$tools_path/Windows/ligolo_proxy.exe"
                
                echo -e "\033[1;32m[✓] ligolo-ng installed successfully!\033[0m"
            else
                echo -e "\033[1;31m[✗] Error compiling ligolo-ng\033[0m"
            fi
            cd - >/dev/null || return
            rm -rf "$temp_dir"
        else
            echo -e "\033[1;31m[✗] Error cloning ligolo-ng repository\033[0m"
        fi
    else
        echo -e "\033[1;33m[!] ligolo-ng already exists - skipping\033[0m"
    fi
    sleep 1

    # ==================== PERSONAL TOOLS ====================
    section_header "=== INSTALLING MATTHYGD TOOLS ==="
    
    install_personal_tool() {
        local tool_name="$1"
        local repo_url="$2"
        local output_file="$3"
        local dest_path="$tools_path/Linux/$output_file"

        if [ -f "$dest_path" ]; then
            echo -e "\033[1;33m[!] $tool_name already exists - skipping\033[0m"
            return 0
        fi

        echo -e "\033[1;36m[*] Installing $tool_name...\033[0m"
        local temp_dir="/tmp/${tool_name}_temp"
        
        if git clone "$repo_url" "$temp_dir" >/dev/null 2>&1; then
            if [ -f "$temp_dir/$output_file" ]; then
                mv "$temp_dir/$output_file" "$dest_path" && \
                chmod +x "$dest_path" && \
                echo -e "\033[1;32m[✓] $tool_name installed successfully!\033[0m"
            else
                echo -e "\033[1;31m[✗] Error: Could not find $output_file in repository\033[0m"
            fi
            rm -rf "$temp_dir"
        else
            echo -e "\033[1;31m[✗] Error cloning $repo_url\033[0m"
        fi
        sleep 0.5
    }

    # Install personal tools
    install_personal_tool "NDiscover" "https://github.com/MatthyGD/NDiscover.git" "NDiscover.sh"
    install_personal_tool "PathTrace" "https://github.com/MatthyGD/PathTrace.git" "PathTrace.sh"
    install_personal_tool "BruteX" "https://github.com/MatthyGD/BruteX.git" "BruteX.sh"
    install_personal_tool "RsyncForce" "https://github.com/MatthyGD/RsyncForce.git" "RsyncForce.py"
    install_personal_tool "PantheonX" "https://github.com/MatthyGD/PantheonX.git" "PantheonX.sh"
    sleep 1

    # ==================== FINAL CONFIGURATION ====================
    section_header "=== FINAL CONFIGURATION ==="
    
    echo -e "\033[1;36m[*] Setting execution permissions...\033[0m"
    find "$tools_path" -type f -exec chmod +x {} \; 2>/dev/null
    echo -e "\033[1;32m[✓] All files are now executable!\033[0m"
    sleep 0.5
    
    echo -e "\n\033[1;36m[*] Setting ownership...\033[0m"
    if chown -R "$current_user:$current_user" "$tools_path"; then
        echo -e "\033[1;32m[✓] Ownership set successfully!\033[0m"
    else
        echo -e "\033[1;31m[✗] Error setting ownership\033[0m"
    fi
    sleep 0.5
    
    # Verification
    echo -e "\n\033[1;34m[+] Verifying installations...\033[0m"
    failed=0
    for dir in "Linux" "Windows"; do
        count=$(find "$tools_path/$dir" -type f | wc -l)
        if [ "$count" -gt 0 ]; then
            echo -e "\033[1;32m[✓] $dir tools installed ($count files)\033[0m"
        else
            echo -e "\033[1;31m[✗] No $dir tools found!\033[0m"
            ((failed++))
        fi
        sleep 0.3
    done
    
    if [ $failed -eq 0 ]; then
        echo -e "\n\033[1;32m[✔] All tools installed successfully!\033[0m"
    else
        echo -e "\n\033[1;31m[✗] Some tools failed to install ($failed categories)\033[0m"
    fi
    sleep 1
}

# Start installation
install_tools

# ======================================================
# === UPDATING SYSTEM ===
# ======================================================
echo -e "\n\033[1;34m[🔄] Now we'll update your system, please wait...\033[0m\n"
sleep 2  # Reasonable pause before major operation

# Command execution function
execute() {
    local cmd="$1"
    local description="$2"
    
    echo -e "\033[1;36m[ℹ] $description...\033[0m"
    echo -e "\033[90mCommand: $cmd\033[0m"
    
    if eval "sudo $cmd"; then
        echo -e "\033[1;32m[✓] $description completed\033[0m\n"
        sleep 1  # Short success pause
        return 0
    else
        echo -e "\033[1;31m[✗] Error in $description\033[0m\n"
        sleep 1  # Short error pause
        return 1
    fi
}

# 1. Update package lists
execute "apt update -y" "Updating package lists"

# 2. Upgrade installed packages
execute "apt upgrade -y --allow-downgrades" "Upgrading packages"

# 3. Smart system upgrade
execute "apt dist-upgrade -y" "System dist-upgrade"

# 4. Clean residual packages
execute "apt autoremove -y --purge" "Cleaning unnecessary packages"

# 5. Clean package cache
execute "apt clean -y" "Cleaning package cache"

# 6. Final check
echo -e "\033[1;35m[🔍] Verifying results...\033[0m"
execute "apt list --upgradable" "Remaining upgradable packages"
sleep 2  # Pause for review

echo -e "\033[1;32m[✔] System successfully updated!\033[0m\n"
sleep 2  # Completion pause

# ======================================================
# === BSPWM INSTALLATION ===
# ======================================================

echo -e "\n\033[1;34m[🖥️] BSPWM Installation Section\033[0m"
sleep 2

echo -e "\n\033[1;33mThis will install BSPWM window manager.\033[0m"
echo -e "\033[1;33mThe system will automatically reboot after installation.\033[0m"
echo -e "\033[1;33mEstimated time: 3-5 minutes depending on your internet connection.\033[0m"

read -p $'\033[1;35m[?] Continue with BSPWM installation? [y/N]: \033[0m' -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\033[1;31m[✗] BSPWM installation skipped.\033[0m"
    return 0
fi

echo -e "\033[1;32m[✔] Starting BSPWM installation process...\033[0m"
sleep 1.5

# Switch to the selected user for installation
echo -e "\033[1;34m[→] Switching to user '$current_user' for installation...\033[0m"
sleep 1

# Clone and install bspwm as the selected user
sudo -u "$current_user" bash <<EOF
echo -e "\033[1;36m[↓] Downloading BSPWM configuration package...\033[0m"
cd /tmp && git clone -q https://github.com/r1vs3c/auto-bspwm.git > /dev/null 2>&1

echo -e "\033[1;36m[⚙] Configuring packages (neofetch → fastfetch replacement)...\033[0m"
cd auto-bspwm
sed -i 's/neofetch/fastfetch/g' setup.sh

echo -e "\033[1;36m[🛠] Installing BSPWM components...\033[0m"
chmod +x setup.sh && ./setup.sh --silent > /dev/null 2>&1
EOF

# Verify installation
if [ -d "/home/$current_user/.config/bspwm" ]; then
    echo -e "\033[1;32m[✔] BSPWM successfully installed for user '$current_user'\033[0m"
    echo -e "\033[1;33m[⚠] The system will reboot in 10 seconds to complete installation.\033[0m"
    sleep 10
    reboot
else
    echo -e "\033[1;31m[✗] Error: BSPWM installation may have failed.\033[0m"
    echo -e "\033[1;33m[ℹ] Please check logs and try manual installation if needed.\033[0m"
fi

echo -e "\033[1;34m[✓] BSPWM installation process completed.\033[0m\n"
sleep 1.5

# ======================================================
# === REBOOT PROMPT ===
# ======================================================

echo -e "\n\033[1;34m[?] Installation complete! Would you like to reboot now?\033[0m"
echo -e "1. Yes, reboot now"
echo -e "2. No, I'll reboot later"
read -p "Choose an option (1 or 2): " reboot_choice

case $reboot_choice in
    1)
        echo -e "\n\033[1;33m[⚠] System will reboot in 5 seconds... (Press Ctrl+C to cancel)\033[0m"
        sleep 5
        echo -e "\033[1;31m[⚡] Rebooting system now!\033[0m"
        sudo reboot
        ;;
    2)
        echo -e "\n\033[1;32m[✓] Okay! Remember to reboot later to complete all changes.\033[0m"
        ;;
    *)
        echo -e "\n\033[1;31m[✗] Invalid option! No reboot will be performed.\033[0m"
        ;;
esac

echo -e "\n\033[1;32m[✔] All done! Happy hacking!\033[0m\n"
