#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  STAR SHOP AUTO-INSTALLER v1.0
#  Repo: nuxy1466-blip/STARPLUS
#  Run:  bash <(curl -sL https://raw.githubusercontent.com/nuxy1466-blip/STARPLUS/main/star_shop.sh)
# ============================================================

# ---------- CONFIG ----------
OWNER_TAG="STAR SHOP"
REPO_OWNER="nuxy1466-blip"
REPO_NAME="STARPLUS"
SCRIPT_VERSION="v1.0"
DISCORD_LINK="https://discord.gg/your-invite"
MAX_ATTEMPTS=3

# Tier 1 password (main gate)
MAIN_PASSWORD="STAR99"

# Tier 2 password (only for "Delta No key" category)
VIP_PASSWORD="STARVVIP993"

# Release tag (use "latest" or specific tag like "V1.0")
RELEASE_TAG="${RELEASE_TAG:-V1.0}"

# Asset naming convention in GitHub Releases:
#   Delta.<N>.apk         -> Delta category
#   Delta.NoKey.<N>.apk   -> Delta No Key category
# Extension variants supported: .apk, .apk.enc (auto-decrypt)

# Decryption key for .apk.enc assets
DECRYPT_KEY="StarShop2025"

# ---------- COLORS (dark theme, sapphire accents) ----------
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_RED="\033[38;5;203m"
C_GREEN="\033[38;5;114m"
C_YELLOW="\033[38;5;221m"
C_BLUE="\033[38;5;75m"
C_PURPLE="\033[38;5;177m"
C_CYAN="\033[38;5;81m"
C_WHITE="\033[38;5;255m"
C_GRAY="\033[38;5;245m"
C_EMERALD="\033[38;5;42m"
C_PINK="\033[38;5;212m"
C_GOLD="\033[38;5;220m"
C_SAPPHIRE="\033[1;38;5;27m"

CR="\r\033[K"

C_DIV="══════════════════════════════════════════════════════════════════"
C_SUB="──────────────────────────────────────────────────────────────────"
C_DBL="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

hash -r 2>/dev/null
stty sane 2>/dev/null

type_text() {
    local text="$1"
    local color="$2"
    echo -ne "${CR}${color}"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep 0.015
    done
    echo -e "${C_RESET}"
}

print_banner() {
    clear
    echo -e "${C_SAPPHIRE}${C_DIV}${C_RESET}"
    echo -e "${C_SAPPHIRE}   ███████ ███████ ██  ██████  ██████  ███████ ███████      ${C_RESET}"
    echo -e "${C_SAPPHIRE}   ██      ██      ██ ██      ██    ██ ██      ██           ${C_RESET}"
    echo -e "${C_SAPPHIRE}   ███████ █████   ██ ██      ██    ██ █████   █████        ${C_RESET}"
    echo -e "${C_SAPPHIRE}        ██ ██      ██ ██      ██    ██ ██      ██           ${C_RESET}"
    echo -e "${C_SAPPHIRE}   ███████ ███████ ██  ██████  ██████  ███████ ███████      ${C_RESET}"
    echo -e "${C_SAPPHIRE}    ${C_YELLOW}⭐  S H O P   ${C_SAPPHIRE}[ ${SCRIPT_VERSION} ]                ${C_RESET}"
    echo -e "${C_SAPPHIRE}${C_DIV}${C_RESET}"
}

preflight() {
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${CR}${C_YELLOW}⚙️  Installing curl...${C_RESET}"
        pkg install curl -y >/dev/null 2>&1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        echo -ne "${CR}${C_YELLOW}⚙️  Installing jq...${C_RESET}"
        pkg install jq -y >/dev/null 2>&1
        echo -e " ${C_GREEN}OK${C_RESET}"
    fi
    if ! command -v openssl >/dev/null 2>&1; then
        echo -ne "${CR}${C_YELLOW}⚙️  Installing openssl...${C_RESET}"
        pkg install openssl-tool -y >/dev/null 2>&1
        echo -e " ${C_GREEN}OK${C_RESET}"
    fi
    if [ ! -d "/sdcard/Download" ] || ! touch "/sdcard/Download/.test_perm" 2>/dev/null; then
        echo -e "${CR}${C_YELLOW}⚠️  Storage permission required...${C_RESET}"
        echo -e "${CR}${C_CYAN}   Tap 'Allow' on the dialog${C_RESET}"
        termux-setup-storage
        sleep 3
    fi
    rm -f "/sdcard/Download/.test_perm" 2>/dev/null
}

get_device_info() {
    OS_VER=$(getprop ro.build.version.release 2>/dev/null || echo "?")
    ARCH=$(uname -m 2>/dev/null || echo "?")
    local RAM_KB=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
    if [ -n "$RAM_KB" ]; then
        RAM_GB=$(awk "BEGIN {printf \"%.1f\", $RAM_KB/1048576}" 2>/dev/null)" GB"
    else
        RAM_GB="?"
    fi
    local ROM_TOTAL=$(df -h /sdcard 2>/dev/null | awk 'NR==2 {print $2}')
    local ROM_FREE=$(df -h /sdcard 2>/dev/null | awk 'NR==2 {print $4}')
    if [ -n "$ROM_TOTAL" ]; then
        ROM_INFO="${ROM_TOTAL} (free ${ROM_FREE})"
    else
        ROM_INFO="?"
    fi
}

check_main_password() {
    print_banner
    echo -e "${C_SAPPHIRE}   ${C_DBL}${C_RESET}"
    echo -e "   ${C_SAPPHIRE}${C_BOLD}⭐  STAR SHOP — MEMBER ACCESS  ⭐${C_RESET}"
    echo -e "${C_SAPPHIRE}   ${C_DBL}${C_RESET}"
    echo ""
    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}   ${C_SAPPHIRE}🔑  Enter password: ${C_RESET}"
        read -s USER_PASS
        echo ""
        USER_PASS=$(echo "$USER_PASS" | tr -d '[:space:]' | tr -d '\r')
        if [ "$USER_PASS" == "$MAIN_PASSWORD" ]; then
            type_text "    ✔  Welcome to STAR SHOP!" "$C_EMERALD"
            sleep 0.8
            get_device_info
            return 0
        else
            echo -e "${CR}   ${C_RED}❌  Wrong password (attempts left: $((MAX_ATTEMPTS - ATTEMPTS - 1)))${C_RESET}"
            ATTEMPTS=$((ATTEMPTS + 1))
        fi
    done
    echo -e "${CR}   ${C_RED}🚫  Too many attempts. Locked temporarily.${C_RESET}"
    exit 1
}

check_vip_password() {
    echo -e "${CR}   ${C_PURPLE}${C_DBL}${C_RESET}"
    echo -e "   ${C_PURPLE}${C_BOLD}💎  VIP CATEGORY — EXTRA VERIFICATION  💎${C_RESET}"
    echo -e "${CR}   ${C_PURPLE}${C_DBL}${C_RESET}"
    echo ""
    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}   ${C_PURPLE}🔑  VIP password: ${C_RESET}"
        read -s VIP_PASS
        echo ""
        VIP_PASS=$(echo "$VIP_PASS" | tr -d '[:space:]' | tr -d '\r')
        if [ "$VIP_PASS" == "$VIP_PASSWORD" ]; then
            type_text "    ✔  VIP access granted!" "$C_EMERALD"
            sleep 0.5
            return 0
        else
            echo -e "${CR}   ${C_RED}❌  Wrong VIP password (attempts left: $((MAX_ATTEMPTS - ATTEMPTS - 1)))${C_RESET}"
            ATTEMPTS=$((ATTEMPTS + 1))
        fi
    done
    echo -e "${CR}   ${C_RED}🚫  VIP access denied. Returning to menu...${C_RESET}"
    sleep 1.5
    return 1
}

fetch_release_assets() {
    ASSET_NAMES=()
    ASSET_URLS=()
    ASSET_SIZES=()
    local API_URL
    if [ "$RELEASE_TAG" == "latest" ]; then
        API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    else
        API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${RELEASE_TAG}"
    fi
    type_text "    📡  Fetching catalog from GitHub..." "$C_CYAN"
    local RESPONSE
    RESPONSE=$(curl -sL -H "Accept: application/vnd.github+json" "$API_URL" 2>/dev/null)
    if [ -z "$RESPONSE" ]; then
        echo -e "${CR}   ${C_RED}❌  Cannot reach GitHub API.${C_RESET}"
        return 1
    fi
    local ERR_MSG
    ERR_MSG=$(echo "$RESPONSE" | jq -r '.message // empty' 2>/dev/null)
    if [ -n "$ERR_MSG" ] && [ "$ERR_MSG" != "null" ]; then
        echo -e "${CR}   ${C_RED}❌  GitHub API: $ERR_MSG${C_RESET}"
        echo -e "${CR}   ${C_GRAY}     Tag: $RELEASE_TAG  |  Repo: $REPO_OWNER/$REPO_NAME${C_RESET}"
        return 1
    fi
    local COUNT
    COUNT=$(echo "$RESPONSE" | jq -r '.assets | length' 2>/dev/null)
    if [ -z "$COUNT" ] || [ "$COUNT" == "null" ] || [ "$COUNT" -eq 0 ] 2>/dev/null; then
        echo -e "${CR}   ${C_YELLOW}⚠️  Release '$RELEASE_TAG' has no APK assets yet.${C_RESET}"
        return 1
    fi
    local i=0
    while [ $i -lt $COUNT ]; do
        local NAME URL SIZE_BYTES SIZE_HR
        NAME=$(echo "$RESPONSE" | jq -r ".assets[$i].name" 2>/dev/null)
        URL=$(echo "$RESPONSE" | jq -r ".assets[$i].browser_download_url" 2>/dev/null)
        SIZE_BYTES=$(echo "$RESPONSE" | jq -r ".assets[$i].size" 2>/dev/null)
        if [ -n "$SIZE_BYTES" ] && [ "$SIZE_BYTES" != "null" ]; then
            SIZE_HR=$(awk "BEGIN {printf \"%.1f MB\", $SIZE_BYTES/1048576}" 2>/dev/null)
        else
            SIZE_HR="?"
        fi
        ASSET_NAMES+=("$NAME")
        ASSET_URLS+=("$URL")
        ASSET_SIZES+=("$SIZE_HR")
        i=$((i + 1))
    done
    echo -e "${CR}   ${C_GREEN}✔  Found ${#ASSET_NAMES[@]} APK(s) in release '$RELEASE_TAG'${C_RESET}"
    sleep 0.4
    return 0
}

filter_by_category() {
    local PREFIX="$1"
    FILTERED_INDICES=()
    local i
    for i in "${!ASSET_NAMES[@]}"; do
        local N="${ASSET_NAMES[$i]}"
        case "$N" in
            "${PREFIX}"*)
                case "$N" in
                    "Delta.NoKey."*)  [ "$PREFIX" != "Delta.NoKey."  ] && continue ;;
                    "Delta_NoKey_"*)  [ "$PREFIX" != "Delta_NoKey_"  ] && continue ;;
                esac
                FILTERED_INDICES+=($i)
                ;;
        esac
    done
}