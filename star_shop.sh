#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  STAR SHOP AUTO-INSTALLER (plain .sh, no base64)
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
#   Delta.lite.<N>.apk    -> Delta Lite category
# Extension variants supported: .apk, .apk.enc (auto-decrypt with DECRYPT_KEY)

# Decryption key for .apk.enc assets (must match the key used to encrypt)
DECRYPT_KEY="StarShop2025"

# ---------- COLORS (dark theme, vivid accents) ----------
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_DIM="\033[2m"
C_RED="\033[38;5;203m"
C_GREEN="\033[38;5;114m"
C_YELLOW="\033[38;5;221m"
C_BLUE="\033[38;5;75m"
C_PURPLE="\033[38;5;177m"
C_CYAN="\033[38;5;81m"
C_WHITE="\033[38;5;255m"
C_GRAY="\033[38;5;245m"
C_EMERALD="\033[38;5;42m"
C_ORANGE="\033[38;5;215m"
C_PINK="\033[38;5;212m"
C_GOLD="\033[38;5;220m"

CR="\r\033[K"

# Borders (width 70)
C_DIV="══════════════════════════════════════════════════════════════════"
C_SUB="──────────────────────────────────────────────────────────────────"
C_DBL="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ---------- HELPERS ----------
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
    echo -e "${C_GOLD}${C_DIV}${C_RESET}"
    echo -e "${C_GOLD}   ███████ ███████ ██  ██████  ██████  ███████ ███████      ${C_RESET}"
    echo -e "${C_GOLD}   ██      ██      ██ ██      ██    ██ ██      ██           ${C_RESET}"
    echo -e "${C_GOLD}   ███████ █████   ██ ██      ██    ██ █████   █████        ${C_RESET}"
    echo -e "${C_GOLD}        ██ ██      ██ ██      ██    ██ ██      ██           ${C_RESET}"
    echo -e "${C_GOLD}   ███████ ███████ ██  ██████  ██████  ███████ ███████      ${C_RESET}"
    echo -e "${C_GOLD}    ${C_YELLOW}⭐  S H O P   ${C_GOLD}[ ${SCRIPT_VERSION} ]                ${C_RESET}"
    echo -e "${C_GOLD}${C_DIV}${C_RESET}"
}

# ---------- PRE-FLIGHT ----------
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

# ---------- DEVICE INFO ----------
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

# ---------- TIER 1 PASSWORD ----------
check_main_password() {
    print_banner
    echo -e "${C_GOLD}   ${C_DBL}${C_RESET}"
    echo -e "   ${C_GOLD}${C_BOLD}⭐  STAR SHOP — MEMBER ACCESS  ⭐${C_RESET}"
    echo -e "${C_GOLD}   ${C_DBL}${C_RESET}"
    echo ""

    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}   ${C_GOLD}🔑  Enter password: ${C_RESET}"
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

# ---------- TIER 2 VIP PASSWORD (only for Delta No Key) ----------
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

# ---------- GITHUB RELEASE FETCHER ----------
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

# ---------- CATEGORY FILTER ----------
filter_by_category() {
    local PREFIX="$1"
    FILTERED_INDICES=()
    local i
    for i in "${!ASSET_NAMES[@]}"; do
        local N="${ASSET_NAMES[$i]}"
        case "$N" in
            "${PREFIX}"*)
                case "$N" in
                    "Delta.lite."*)   [ "$PREFIX" != "Delta.lite."   ] && continue ;;
                    "Delta.NoKey."*)  [ "$PREFIX" != "Delta.NoKey."  ] && continue ;;
                    "Delta_NoKey_"*)  [ "$PREFIX" != "Delta_NoKey_"  ] && continue ;;
                    "Delta_lite_"*)   [ "$PREFIX" != "Delta_lite_"   ] && continue ;;
                esac
                FILTERED_INDICES+=($i)
                ;;
        esac
    done
}

# ---------- APK INSTALL ----------
install_apk() {
    local NAME="$1"
    local URL="$2"
    local SIZE="$3"
    local TEMP_ENC="/sdcard/Download/starshop_temp.enc"
    local TEMP_APK="/sdcard/Download/starshop_temp.apk"
    local PID=""
    local DL_STATUS=0

    echo -e "${CR}${C_CYAN}   ${C_SUB}${C_RESET}"
    rm -f "$TEMP_ENC" "$TEMP_APK"

    local IS_ENC=0
    case "$NAME" in
        *.enc|*.ENC)
            IS_ENC=1
            local DL_TARGET="$TEMP_ENC"
            local TAG="encrypted"
            ;;
        *)
            IS_ENC=0
            local DL_TARGET="$TEMP_APK"
            local TAG="plain"
            ;;
    esac

    curl -sL -A "Mozilla/5.0" "$URL" -o "$DL_TARGET" &
    PID=$!

    local DOTS=""
    while kill -0 $PID 2>/dev/null; do
        if [ ${#DOTS} -ge 3 ]; then DOTS=""; else DOTS+="."; fi
        echo -ne "${CR}   ${C_YELLOW}📥  Downloading: ${C_WHITE}$NAME ${C_GRAY}(${SIZE}, ${TAG}) ${C_CYAN}${DOTS}${C_RESET}"
        sleep 0.4
    done
    wait $PID
    DL_STATUS=$?

    echo -e "${CR}   ${C_YELLOW}📥  Downloaded: ${C_WHITE}$NAME${C_RESET}"

    if [ $DL_STATUS -ne 0 ] || [ ! -f "$DL_TARGET" ]; then
        echo -e "${CR}   ${C_RED}❌  Download failed (curl exit: $DL_STATUS)${C_RESET}"
        rm -f "$TEMP_ENC" "$TEMP_APK"
        return 1
    fi

    local FILE_SIZE_KB
    FILE_SIZE_KB=$(du -k "$DL_TARGET" | awk '{print $1}')
    if [ "$FILE_SIZE_KB" -le 1024 ]; then
        echo -e "${CR}   ${C_RED}❌  File too small (${FILE_SIZE_KB}KB). Possibly a 404 page.${C_RESET}"
        rm -f "$TEMP_ENC" "$TEMP_APK"
        return 1
    fi

    if [ $IS_ENC -eq 1 ]; then
        if ! command -v openssl >/dev/null 2>&1; then
            echo -e "${CR}   ${C_RED}❌  openssl not installed (needed for .enc)${C_RESET}"
            rm -f "$TEMP_ENC" "$TEMP_APK"
            return 1
        fi
        echo -ne "${CR}   ${C_PURPLE}🔓  Decrypting: ${C_WHITE}$NAME ${C_PURPLE}...${C_RESET}"
        if ! openssl enc -d -aes-256-cbc -pbkdf2 \
                -in "$TEMP_ENC" \
                -out "$TEMP_APK" \
                -pass "pass:$DECRYPT_KEY" 2>/dev/null; then
            echo -e " ${C_RED}FAIL${C_RESET}"
            echo -e "${CR}   ${C_RED}❌  Decryption failed (wrong key or corrupted)${C_RESET}"
            rm -f "$TEMP_ENC" "$TEMP_APK"
            return 1
        fi
        echo -e " ${C_GREEN}OK${C_RESET}"
        rm -f "$TEMP_ENC"
        FILE_SIZE_KB=$(du -k "$TEMP_APK" | awk '{print $1}')
        if [ "$FILE_SIZE_KB" -le 1024 ]; then
            echo -e "${CR}   ${C_RED}❌  Decrypted file too small (${FILE_SIZE_KB}KB)${C_RESET}"
            rm -f "$TEMP_APK"
            return 1
        fi
    fi

    chmod 644 "$TEMP_APK" 2>/dev/null
    echo -e "${CR}   ${C_GREEN}⚡  Installing: ${C_RESET}$NAME ..."

    if command -v su >/dev/null 2>&1 && su -c "true" >/dev/null 2>&1; then
        su -c "pm install -r \"$TEMP_APK\"" >/dev/null 2>&1
        local PM_STATUS=$?
        stty sane 2>/dev/null
        if [ $PM_STATUS -eq 0 ]; then
            echo -e "${CR}   ${C_GREEN}✅  Installed silently (rooted)${C_RESET}"
        else
            echo -e "${CR}   ${C_RED}❌  Silent install failed, opening installer...${C_RESET}"
            termux-open --content-type "application/vnd.android.package-archive" "$TEMP_APK"
            stty sane 2>/dev/null
        fi
    else
        termux-open --content-type "application/vnd.android.package-archive" "$TEMP_APK"
        stty sane 2>/dev/null
        echo -e "${CR}   ${C_GREEN}✅  Installer opened. Tap 'Install' on screen.${C_RESET}"
    fi
}

# ---------- CATEGORY BROWSER ----------
process_category() {
    local CATEGORY_LABEL="$1"
    local CATEGORY_PREFIX="$2"

    filter_by_category "$CATEGORY_PREFIX"
    local TOTAL=${#FILTERED_INDICES[@]}

    if [ "$TOTAL" -eq 0 ]; then
        echo -e "${CR}   ${C_YELLOW}⚠️  No APKs in this category yet ($CATEGORY_LABEL).${C_RESET}"
        echo -e "${CR}   ${C_GRAY}     Expected prefix: '$CATEGORY_PREFIX'${C_RESET}"
        echo -ne "${CR}   ✨  Press Enter to continue...${C_RESET}"
        read
        return 0
    fi

    while true; do
        clear
        stty sane 2>/dev/null
        echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"
        echo -e "       ${C_YELLOW}${C_BOLD}📁  CATEGORY: ${CATEGORY_LABEL}${C_RESET}"
        echo -e "       ${C_GRAY}(${TOTAL} APK${TOTAL:+s} available)${C_RESET}"
        echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"
        echo ""

        local i
        for i in "${!FILTERED_INDICES[@]}"; do
            local IDX="${FILTERED_INDICES[$i]}"
            local N="${ASSET_NAMES[$IDX]}"
            local S="${ASSET_SIZES[$IDX]}"
            echo -e "${CR}   ${C_PURPLE}[$((i+1))]${C_RESET} ${C_BLUE}▸${C_RESET} ${C_WHITE}${N}${C_GRAY} (${S})${C_RESET}"
        done

        echo -e "${CR}   ${C_SUB}${C_RESET}"
        echo -e "${CR}   💡  ${C_YELLOW}Pick: number (1-${TOTAL}), range (1-3), or 'all'${C_RESET}"
        echo -e "${CR}       ${C_WHITE}(0 = back to main menu)${C_RESET}"
        echo -e "${CR}   ${C_SUB}${C_RESET}"

        echo -ne "${CR}   🎯  ${C_GREEN}Choice: ${C_RESET}"
        read INPUT_CHOICE
        echo ""

        if [ "$INPUT_CHOICE" == "0" ]; then
            return 0
        fi

        local SELECTED=()
        local VALID_INPUT=0

        if [ "$INPUT_CHOICE" == "all" ] || [ "$INPUT_CHOICE" == "ALL" ]; then
            for i in "${!FILTERED_INDICES[@]}"; do
                SELECTED+=($i)
            done
            VALID_INPUT=1
        else
            for ITEM in $INPUT_CHOICE; do
                if [[ "$ITEM" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                    local START=${BASH_REMATCH[1]}
                    local END=${BASH_REMATCH[2]}
                    if [ "$START" -gt "$END" ]; then
                        local T=$START; START=$END; END=$T
                    fi
                    for ((j=START; j<=END; j++)); do
                        if [ $((j-1)) -ge 0 ] && [ $((j-1)) -lt $TOTAL ]; then
                            SELECTED+=($((j-1)))
                            VALID_INPUT=1
                        fi
                    done
                elif [[ "$ITEM" =~ ^[0-9]+$ ]]; then
                    if [ $((ITEM-1)) -ge 0 ] && [ $((ITEM-1)) -lt $TOTAL ]; then
                        SELECTED+=($((ITEM-1)))
                        VALID_INPUT=1
                    fi
                fi
            done
        fi

        if [ $VALID_INPUT -eq 1 ]; then
            clear
            stty sane 2>/dev/null
            echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"
            echo -e "       ${C_GREEN}${C_BOLD}🚀  Installing ${#SELECTED[@]} APK${#SELECTED[@]:+s}${C_RESET}"
            echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"

            for IDX_REL in "${SELECTED[@]}"; do
                local IDX_ABS="${FILTERED_INDICES[$IDX_REL]}"
                install_apk "${ASSET_NAMES[$IDX_ABS]}" \
                            "${ASSET_URLS[$IDX_ABS]}" \
                            "${ASSET_SIZES[$IDX_ABS]}"
            done

            echo -e "${CR}   ${C_SUB}${C_RESET}"
            echo -ne "${CR}   ✨  ${C_YELLOW}Press Enter to return...${C_RESET}"
            read
        else
            echo -e "${CR}   ${C_RED}[!]  Invalid choice (1-${TOTAL}, range, or all)${C_RESET}"
            sleep 1.2
        fi
    done
}

# ---------- MAIN ----------
main() {
    preflight
    check_main_password

    if ! fetch_release_assets; then
        echo -ne "${CR}   ✨  ${C_YELLOW}Press Enter to continue...${C_RESET}"
        read
    fi

    while true; do
        clear
        stty sane 2>/dev/null
        echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"
        echo -e "${C_GOLD}   ██╗  ██╗ █████╗ ███████╗████████╗    ███████╗██████╗ ██╗${C_RESET}"
        echo -e "${C_GOLD}   ██║  ██║██╔══██╗██╔════╝╚══██╔══╝    ██╔════╝██╔══██╗██║${C_RESET}"
        echo -e "${C_GOLD}   ███████║███████║███████╗   ██║       █████╗  ██║  ██║██║${C_RESET}"
        echo -e "${C_GOLD}   ██╔══██║██╔══██║╚════██║   ██║       ██╔══╝  ██║  ██║╚═╝${C_RESET}"
        echo -e "${C_GOLD}   ██║  ██║██║  ██║███████║   ██║       ███████╗██████╔╝ ██╗${C_RESET}"
        echo -e "${C_GOLD}   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚══════╝╚═════╝  ╚═╝${C_RESET}"
        echo -e "   ${C_YELLOW}⭐  S T A R   S H O P ${C_GOLD} [${SCRIPT_VERSION}] ${C_RESET}"
        echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"
        echo -e "   ${C_PINK}👑  Dev ${C_RESET}: ${C_WHITE}${OWNER_TAG}${C_RESET}"
        echo -e "   ${C_PINK}💬  Disc ${C_RESET}: ${C_WHITE}${DISCORD_LINK}${C_RESET}"
        echo -e "${C_GOLD}   ${C_SUB}${C_RESET}"
        echo -e "   ${C_BLUE}📱  OS ${C_RESET} : Android ${OS_VER} | ${ARCH}"
        echo -e "   ${C_BLUE}💾  MEM ${C_RESET}: RAM ${RAM_GB} | ROM ${ROM_INFO}"
        echo -e "   ${C_BLUE}📦  Tag ${C_RESET}: ${RELEASE_TAG}"
        echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"
        echo ""

        # Compute counts for each category
        filter_by_category "Delta."
        local N_DELTA=${#FILTERED_INDICES[@]}
        filter_by_category "Delta.lite."
        local N_LITE=${#FILTERED_INDICES[@]}
        filter_by_category "Delta.NoKey."
        local N_NOKEY=${#FILTERED_INDICES[@]}
        if [ "$N_NOKEY" -eq 0 ]; then
            filter_by_category "Delta_NoKey_"
            N_NOKEY=${#FILTERED_INDICES[@]}
        fi

        echo -e "   ${C_PURPLE}[1]${C_RESET} ${C_WHITE}▸${C_RESET} ${C_GREEN}Delta${C_RESET}            ${C_GRAY}(${N_DELTA} APK${N_DELTA:+s})${C_RESET}"
        echo -e "   ${C_PURPLE}[2]${C_RESET} ${C_WHITE}▸${C_RESET} ${C_PINK}Delta No Key 💎${C_RESET}  ${C_GRAY}(${N_NOKEY} APK${N_NOKEY:+s} - VIP)${C_RESET}"
        echo -e "   ${C_PURPLE}[3]${C_RESET} ${C_WHITE}▸${C_RESET} ${C_GREEN}Delta Lite${C_RESET}        ${C_GRAY}(${N_LITE} APK${N_LITE:+s})${C_RESET}"
        echo -e "   ${C_RED}   [0]${C_RESET} Exit"
        echo -e "${CR}   ${C_SUB}${C_RESET}"

        echo -ne "${CR}   🎯  ${C_GREEN}Choose category (0-3): ${C_RESET}"
        read MAIN_CHOICE
        echo ""

        case "$MAIN_CHOICE" in
            1) process_category "Delta" "Delta." ;;
            2)
                # VIP category - requires second password
                if check_vip_password; then
                    # Determine which prefix actually matched
                    local NOKEY_PREFIX="Delta.NoKey."
                    filter_by_category "$NOKEY_PREFIX"
                    if [ ${#FILTERED_INDICES[@]} -eq 0 ]; then
                        NOKEY_PREFIX="Delta_NoKey_"
                    fi
                    process_category "Delta No Key" "$NOKEY_PREFIX"
                fi
                ;;
            3) process_category "Delta Lite" "Delta.lite." ;;
            0) break ;;
            *)
                echo -e "${CR}   ${C_RED}[!]  Invalid (choose 0-3)${C_RESET}"
                sleep 1.2
                ;;
        esac
    done

    stty sane 2>/dev/null
    clear
    echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"
    echo -e "       ${C_GOLD}${C_BOLD}⭐  Thanks for using STAR SHOP!  ⭐${C_RESET}"
    echo -e "${C_GOLD}   ${C_DIV}${C_RESET}"
    echo ""
}

main "$@"
