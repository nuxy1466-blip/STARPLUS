#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  STARPLUS AUTO-INSTALLER
#  Dynamic APK Installer for Termux
#  Repo: nuxy1466-blip/STARPLUS
# ============================================================

# ---------- CONFIG ----------
OWNER_TAG="STARPLUS"
REPO_OWNER="nuxy1466-blip"
REPO_NAME="STARPLUS"
SCRIPT_VERSION="v2.0"
DISCORD_LINK="https://discord.gg/your-invite"
MAX_ATTEMPTS=3

# Password list (change before publishing!)
VALID_PASSWORDS=("star2025" "plus" "nuxy" "1466")

# Release tag to query (use "latest" or a specific tag)
RELEASE_TAG="${RELEASE_TAG:-V1.0}"

# Naming convention for assets in GitHub Releases:
#   Delta.<N>.apk          -> Delta category
#   Delta.lite.<N>.apk     -> Delta lite category
#   Delta.NoKey.<N>.apk    -> Delta NoKey category
# (any extension is fine; the script filters by prefix)

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
    echo -e "${C_CYAN}${C_DIV}${C_RESET}"
    echo -e "${C_CYAN}   ███████ ███████ ██  ██████  ██████  ███████ ███████      ${C_RESET}"
    echo -e "${C_CYAN}   ██      ██      ██ ██      ██    ██ ██      ██           ${C_RESET}"
    echo -e "${C_CYAN}   ███████ █████   ██ ██      ██    ██ █████   █████        ${C_RESET}"
    echo -e "${C_CYAN}        ██ ██      ██ ██      ██    ██ ██      ██           ${C_RESET}"
    echo -e "${C_CYAN}   ███████ ███████ ██  ██████  ██████  ███████ ███████      ${C_RESET}"
    echo -e "${C_CYAN}   ${C_YELLOW}[ AUTO-INSTALLER ${SCRIPT_VERSION} ]${C_CYAN}                            ${C_RESET}"
    echo -e "${C_CYAN}${C_DIV}${C_RESET}"
}

# ---------- PRE-FLIGHT ----------
preflight() {
    # Install curl if missing
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${CR}${C_YELLOW}⚙️  Installing curl...${C_RESET}"
        pkg install curl -y >/dev/null 2>&1
    fi
    # Install jq if missing
    if ! command -v jq >/dev/null 2>&1; then
        echo -ne "${CR}${C_YELLOW}⚙️  Installing jq (JSON parser)...${C_RESET}"
        pkg install jq -y >/dev/null 2>&1
        echo -e " ${C_GREEN}OK${C_RESET}"
    fi
    # Storage permission
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

# ---------- PASSWORD GATE ----------
check_password() {
    print_banner
    echo -e "${C_EMERALD}   ${C_DBL}${C_RESET}"
    echo -e "   ${C_GREEN}${C_BOLD}⚡  SECURE SYSTEM AUTHENTICATION  ⚡${C_RESET}"
    echo -e "${C_EMERALD}   ${C_DBL}${C_RESET}"
    echo ""

    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}   ${C_EMERALD}🔑  Enter password: ${C_RESET}"
        read -s USER_PASS
        echo ""
        USER_PASS=$(echo "$USER_PASS" | tr -d '[:space:]' | tr -d '\r')

        local IS_CORRECT=0
        for PASS in "${VALID_PASSWORDS[@]}"; do
            if [ "$USER_PASS" == "$PASS" ]; then
                IS_CORRECT=1
                break
            fi
        done

        if [ $IS_CORRECT -eq 1 ]; then
            type_text "    ✔  Access granted. Connecting..." "$C_EMERALD"
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

# ---------- GITHUB RELEASE FETCHER ----------
# Globals populated by fetch_release_assets():
#   ASSET_NAMES[]   = "Delta.1.apk"
#   ASSET_URLS[]    = "https://.../Delta.1.apk"
#   ASSET_SIZES[]   = "194.3 MB"
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

    type_text "    📡  Fetching release catalog from GitHub..." "$C_CYAN"
    local RESPONSE
    RESPONSE=$(curl -sL -H "Accept: application/vnd.github+json" "$API_URL" 2>/dev/null)

    if [ -z "$RESPONSE" ]; then
        echo -e "${CR}   ${C_RED}❌  Cannot reach GitHub API. Check internet connection.${C_RESET}"
        return 1
    fi

    # Detect API error message
    local ERR_MSG
    ERR_MSG=$(echo "$RESPONSE" | jq -r '.message // empty' 2>/dev/null)
    if [ -n "$ERR_MSG" ] && [ "$ERR_MSG" != "null" ]; then
        echo -e "${CR}   ${C_RED}❌  GitHub API: $ERR_MSG${C_RESET}"
        echo -e "${CR}   ${C_GRAY}     Tag: $RELEASE_TAG  |  Repo: $REPO_OWNER/$REPO_NAME${C_RESET}"
        return 1
    fi

    # Parse all assets using jq
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
# filter_by_category <prefix>
# Populates FILTERED_INDICES[] with indexes whose name starts with $prefix
# (but excludes entries that also match the more-specific prefixes)
filter_by_category() {
    local PREFIX="$1"
    FILTERED_INDICES=()
    local i
    for i in "${!ASSET_NAMES[@]}"; do
        local N="${ASSET_NAMES[$i]}"
        case "$N" in
            "${PREFIX}"*)
                # Exclude more-specific subcategories when querying parent
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
    local TEMP_FILE="/sdcard/Download/starplus_temp.apk"
    local PID=""
    local DL_STATUS=0

    echo -e "${CR}${C_CYAN}   ${C_SUB}${C_RESET}"
    rm -f "$TEMP_FILE"

    curl -sL -A "Mozilla/5.0" "$URL" -o "$TEMP_FILE" &
    PID=$!

    local DOTS=""
    while kill -0 $PID 2>/dev/null; do
        if [ ${#DOTS} -ge 3 ]; then DOTS=""; else DOTS+="."; fi
        echo -ne "${CR}   ${C_YELLOW}📥  Downloading: ${C_WHITE}$NAME ${C_GRAY}(${SIZE}) ${C_CYAN}${DOTS}${C_RESET}"
        sleep 0.4
    done
    wait $PID
    DL_STATUS=$?

    echo -e "${CR}   ${C_YELLOW}📥  Downloaded: ${C_WHITE}$NAME${C_RESET}"

    if [ $DL_STATUS -eq 0 ] && [ -f "$TEMP_FILE" ]; then
        local FILE_SIZE_KB
        FILE_SIZE_KB=$(du -k "$TEMP_FILE" | awk '{print $1}')
        if [ "$FILE_SIZE_KB" -gt 1024 ]; then
            chmod 644 "$TEMP_FILE" 2>/dev/null
            echo -e "${CR}   ${C_GREEN}⚡  Installing: ${C_RESET}$NAME ..."

            if command -v su >/dev/null 2>&1 && su -c "true" >/dev/null 2>&1; then
                su -c "pm install -r \"$TEMP_FILE\"" >/dev/null 2>&1
                local PM_STATUS=$?
                stty sane 2>/dev/null
                if [ $PM_STATUS -eq 0 ]; then
                    echo -e "${CR}   ${C_GREEN}✅  Installed silently (rooted)${C_RESET}"
                else
                    echo -e "${CR}   ${C_RED}❌  Silent install failed, opening installer...${C_RESET}"
                    termux-open --content-type "application/vnd.android.package-archive" "$TEMP_FILE"
                    stty sane 2>/dev/null
                fi
            else
                termux-open --content-type "application/vnd.android.package-archive" "$TEMP_FILE"
                stty sane 2>/dev/null
                echo -e "${CR}   ${C_GREEN}✅  Installer opened. Tap 'Install' on screen.${C_RESET}"
            fi
        else
            echo -e "${CR}   ${C_RED}❌  File too small (${FILE_SIZE_KB}KB). Possibly a 404 page.${C_RESET}"
            rm -f "$TEMP_FILE"
        fi
    else
        echo -e "${CR}   ${C_RED}❌  Download failed (curl exit: $DL_STATUS)${C_RESET}"
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
        echo -e "${CR}   ${C_GRAY}     Prefix expected: '$CATEGORY_PREFIX'${C_RESET}"
        echo -ne "${CR}   ✨  Press Enter to continue...${C_RESET}"
        read
        return 0
    fi

    while true; do
        clear
        stty sane 2>/dev/null
        echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"
        echo -e "       ${C_YELLOW}${C_BOLD}📁  CATEGORY: ${CATEGORY_LABEL}${C_RESET}"
        echo -e "       ${C_GRAY}(${TOTAL} APK${TOTAL:+s} available)${C_RESET}"
        echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"
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
            echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"
            echo -e "       ${C_GREEN}${C_BOLD}🚀  Installing ${#SELECTED[@]} APK${#SELECTED[@]:+s}${C_RESET}"
            echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"

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
    check_password

    if ! fetch_release_assets; then
        echo -ne "${CR}   ✨  ${C_YELLOW}Press Enter to continue...${C_RESET}"
        read
    fi

    while true; do
        clear
        stty sane 2>/dev/null
        echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"
        echo -e "${C_CYAN}   ██╗  ██╗ █████╗ ███████╗████████╗    ███████╗██████╗ ██╗${C_RESET}"
        echo -e "${C_CYAN}   ██║  ██║██╔══██╗██╔════╝╚══██╔══╝    ██╔════╝██╔══██╗██║${C_RESET}"
        echo -e "${C_CYAN}   ███████║███████║███████╗   ██║       █████╗  ██║  ██║██║${C_RESET}"
        echo -e "${C_CYAN}   ██╔══██║██╔══██║╚════██║   ██║       ██╔══╝  ██║  ██║╚═╝${C_RESET}"
        echo -e "${C_CYAN}   ██║  ██║██║  ██║███████║   ██║       ███████╗██████╔╝ ██╗${C_RESET}"
        echo -e "${C_CYAN}   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚══════╝╚═════╝  ╚═╝${C_RESET}"
        echo -e "   ${C_YELLOW}${C_BOLD}[ STARPLUS AUTO-INSTALLER ${SCRIPT_VERSION} ]${C_RESET}"
        echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"
        echo -e "   ${C_PINK}👑  Dev ${C_RESET}: ${C_WHITE}${OWNER_TAG}${C_RESET}"
        echo -e "   ${C_PINK}💬  Disc${C_RESET}: ${C_WHITE}${DISCORD_LINK}${C_RESET}"
        echo -e "   ${C_CYAN}   ${C_SUB}${C_RESET}"
        echo -e "   ${C_BLUE}📱  OS ${C_RESET}  : Android ${OS_VER} | ${ARCH}"
        echo -e "   ${C_BLUE}💾  MEM ${C_RESET}: RAM ${RAM_GB} | ROM ${ROM_INFO}"
        echo -e "   ${C_BLUE}📦  Tag ${C_RESET}: ${RELEASE_TAG}"
        echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"
        echo ""

        # Compute counts for each category
        filter_by_category "Delta."
        local N_DELTA=${#FILTERED_INDICES[@]}
        filter_by_category "Delta.lite."
        local N_LITE=${#FILTERED_INDICES[@]}
        filter_by_category "Delta.NoKey."
        local N_NOKEY=${#FILTERED_INDICES[@]}
        # Also try alternate naming with underscores if NoKey count is 0
        if [ "$N_NOKEY" -eq 0 ]; then
            filter_by_category "Delta_NoKey_"
            N_NOKEY=${#FILTERED_INDICES[@]}
        fi

        echo -e "   ${C_PURPLE}[1]${C_RESET} ${C_WHITE}▸${C_RESET} ${C_GREEN}Delta${C_RESET}        ${C_GRAY}(${N_DELTA} APK${N_DELTA:+s})${C_RESET}"
        echo -e "   ${C_PURPLE}[2]${C_RESET} ${C_WHITE}▸${C_RESET} ${C_GREEN}Delta Lite${C_RESET}    ${C_GRAY}(${N_LITE} APK${N_LITE:+s})${C_RESET}"
        echo -e "   ${C_PURPLE}[3]${C_RESET} ${C_WHITE}▸${C_RESET} ${C_GREEN}Delta NoKey${C_RESET}  ${C_GRAY}(${N_NOKEY} APK${N_NOKEY:+s})${C_RESET}"
        echo -e "   ${C_RED}   [0]${C_RESET} Exit"
        echo -e "${CR}   ${C_SUB}${C_RESET}"

        echo -ne "${CR}   🎯  ${C_GREEN}Choose category (0-3): ${C_RESET}"
        read MAIN_CHOICE
        echo ""

        case "$MAIN_CHOICE" in
            1) process_category "Delta"        "Delta." ;;
            2) process_category "Delta Lite"   "Delta.lite." ;;
            3) if [ "$N_NOKEY" -gt 0 ]; then
                   # Determine which prefix actually matched
                   local NOKEY_PREFIX="Delta.NoKey."
                   filter_by_category "$NOKEY_PREFIX"
                   if [ ${#FILTERED_INDICES[@]} -eq 0 ]; then
                       NOKEY_PREFIX="Delta_NoKey_"
                   fi
                   process_category "Delta NoKey" "$NOKEY_PREFIX"
               else
                   # Try both prefix variants and run installer
                   filter_by_category "Delta.NoKey."
                   if [ ${#FILTERED_INDICES[@]} -eq 0 ]; then
                       filter_by_category "Delta_NoKey_"
                       process_category "Delta NoKey" "Delta_NoKey_"
                   else
                       process_category "Delta NoKey" "Delta.NoKey."
                   fi
               fi
               ;;
            0) break ;;
            *)
                echo -e "${CR}   ${C_RED}[!]  Invalid (choose 0-3)${C_RESET}"
                sleep 1.2
                ;;
        esac
    done

    stty sane 2>/dev/null
    clear
    echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"
    echo -e "       ${C_GREEN}${C_BOLD}✨  Logged out. See you next time!  ✨${C_RESET}"
    echo -e "${C_CYAN}   ${C_DIV}${C_RESET}"
    echo ""
}

main "$@"
