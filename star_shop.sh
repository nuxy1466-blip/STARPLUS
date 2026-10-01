#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  STAR SHOP v2.0 — original UI design
#  Repo: nuxy1466-blip/STARPLUS
#  Run:  bash <(curl -sL https://raw.githubusercontent.com/nuxy1466-blip/STARPLUS/main/star_shop.sh)
# ============================================================

# ---------- CONFIG ----------
OWNER_TAG="STAR SHOP"
REPO_OWNER="nuxy1466-blip"
REPO_NAME="STARPLUS"
SCRIPT_VERSION="v2.0"
DISCORD_LINK="https://discord.gg/your-invite"
MAX_ATTEMPTS=3

MAIN_PASSWORD="STAR99"
VIP_PASSWORD="STARVVIP993"
RELEASE_TAG="${RELEASE_TAG:-V1.0}"
DECRYPT_KEY="StarShop2025"

# ---------- COLORS ----------
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
C_PINK="\033[38;5;212m"
C_SAPPHIRE="\033[1;38;5;27m"

CR="\r\033[K"

# Borders
BT="╔══════════════════════════════════════════════════════════════════╗"
BM="║                                                                    ║"
BB="╚══════════════════════════════════════════════════════════════════╝"
S_T="┌──────────────────────────────────────────────────────────────────┐"
S_M="│                                                                  │"
S_B="└──────────────────────────────────────────────────────────────────┘"
DIV="══════════════════════════════════════════════════════════════════"
SUB="──────────────────────────────────────────────────────────────────"

hash -r 2>/dev/null
stty sane 2>/dev/null

type_text() {
    local text="$1"; local color="$2"
    echo -ne "${CR}${color}"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"; sleep 0.015
    done
    echo -e "${C_RESET}"
}

print_logo() {
    echo -e "${C_SAPPHIRE}   ╭──────────────────────────────────────────────────────────╮${C_RESET}"
    echo -e "${C_SAPPHIRE}   │  ${C_YELLOW}✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦${C_SAPPHIRE}                  │${C_RESET}"
    echo -e "${C_SAPPHIRE}   │                                                          │${C_RESET}"
    echo -e "${C_SAPPHIRE}   │     ${C_BOLD}★  ★  ★   S T A R   S H O P   ★  ★  ★${C_SAPPHIRE}          │${C_RESET}"
    echo -e "${C_SAPPHIRE}   │              ${C_YELLOW}⸻ ${C_WHITE}${SCRIPT_VERSION} ${C_YELLOW}⸻${C_SAPPHIRE}                       │${C_RESET}"
    echo -e "${C_SAPPHIRE}   │                                                          │${C_RESET}"
    echo -e "${C_SAPPHIRE}   │  ${C_YELLOW}✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦${C_SAPPHIRE}                  │${C_RESET}"
    echo -e "${C_SAPPHIRE}   ╰──────────────────────────────────────────────────────────╯${C_RESET}"
}

preflight() {
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${CR}${C_YELLOW}⚙  Installing curl...${C_RESET}"
        pkg install curl -y >/dev/null 2>&1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        echo -ne "${CR}${C_YELLOW}⚙  Installing jq...${C_RESET}"
        pkg install jq -y >/dev/null 2>&1
        echo -e " ${C_GREEN}OK${C_RESET}"
    fi
    if [ ! -d "/sdcard/Download" ] || ! touch "/sdcard/Download/.test_perm" 2>/dev/null; then
        echo -e "${CR}${C_YELLOW}⚠  Storage permission required...${C_RESET}"
        echo -e "${CR}${C_CYAN}  Tap 'Allow' on the dialog${C_RESET}"
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
    clear
    print_logo
    echo ""
    echo -e "${C_SAPPHIRE}   ┌──────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_SAPPHIRE}   │  ${C_BOLD}${C_YELLOW}⭐  MEMBER ACCESS GATE  ⭐${C_SAPPHIRE}                          │${C_RESET}"
    echo -e "${C_SAPPHIRE}   └──────────────────────────────────────────────────┘${C_RESET}"
    echo ""
    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}   ${C_SAPPHIRE}🔑  Password: ${C_RESET}"
        read -s USER_PASS
        echo ""
        USER_PASS=$(echo "$USER_PASS" | tr -d '[:space:]' | tr -d '\r')
        if [ "$USER_PASS" == "$MAIN_PASSWORD" ]; then
            type_text "   ✔  Welcome to STAR SHOP!" "$C_EMERALD"
            sleep 0.8
            get_device_info
            return 0
        else
            echo -e "${CR}   ${C_RED}✘  Wrong password (left: $((MAX_ATTEMPTS - ATTEMPTS - 1)))${C_RESET}"
            ATTEMPTS=$((ATTEMPTS + 1))
        fi
    done
    echo -e "${CR}   ${C_RED}🚫  Locked. Try again later.${C_RESET}"
    exit 1
}

check_vip_password() {
    echo ""
    echo -e "${C_PURPLE}   ┌──────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_PURPLE}   │  ${C_BOLD}💎  VIP VERIFICATION  💎${C_PURPLE}                            │${C_RESET}"
    echo -e "${C_PURPLE}   └──────────────────────────────────────────────────┘${C_RESET}"
    echo ""
    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}   ${C_PURPLE}🔑  VIP password: ${C_RESET}"
        read -s VIP_PASS
        echo ""
        VIP_PASS=$(echo "$VIP_PASS" | tr -d '[:space:]' | tr -d '\r')
        if [ "$VIP_PASS" == "$VIP_PASSWORD" ]; then
            type_text "   ✔  VIP access granted!" "$C_EMERALD"
            sleep 0.5
            return 0
        else
            echo -e "${CR}   ${C_RED}✘  Wrong VIP password (left: $((MAX_ATTEMPTS - ATTEMPTS - 1)))${C_RESET}"
            ATTEMPTS=$((ATTEMPTS + 1))
        fi
    done
    echo -e "${CR}   ${C_RED}🚫  VIP access denied. Back to menu...${C_RESET}"
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

    type_text "   📡  Fetching catalog from GitHub..." "$C_CYAN"
    local RESPONSE
    RESPONSE=$(curl -sL -H "Accept: application/vnd.github+json" "$API_URL" 2>/dev/null)

    if [ -z "$RESPONSE" ]; then
        echo -e "${CR}   ${C_RED}✘  Cannot reach GitHub API. Check internet.${C_RESET}"
        return 1
    fi

    local ERR_MSG
    ERR_MSG=$(echo "$RESPONSE" | jq -r '.message // empty' 2>/dev/null)
    if [ -n "$ERR_MSG" ] && [ "$ERR_MSG" != "null" ]; then
        case "$ERR_MSG" in
            "Not Found")
                echo -e "${CR}   ${C_YELLOW}⚠  No release '$RELEASE_TAG' found yet.${C_RESET}"
                echo -e "${CR}   ${C_GRAY}  Repo: $REPO_OWNER/$REPO_NAME${C_RESET}"
                echo ""
                echo -e "${CR}   ${C_CYAN}  📤 To fix:${C_RESET}"
                echo -e "${CR}   ${C_WHITE}  1. Go to https://github.com/$REPO_OWNER/$REPO_NAME/releases/new${C_RESET}"
                echo -e "${CR}   ${C_WHITE}  2. Tag: $RELEASE_TAG  →  Publish${C_RESET}"
                echo -e "${CR}   ${C_WHITE}  3. Upload APKs named: Delta.1.apk, Delta.NoKey.1.apk${C_RESET}"
                ;;
            "rate limit"*)
                echo -e "${CR}   ${C_RED}✘  GitHub API rate limit hit. Try again in 1 hour.${C_RESET}"
                ;;
            *)
                echo -e "${CR}   ${C_RED}✘  GitHub API: $ERR_MSG${C_RESET}"
                ;;
        esac
        return 1
    fi

    local COUNT
    COUNT=$(echo "$RESPONSE" | jq -r '.assets | length' 2>/dev/null)
    if [ -z "$COUNT" ] || [ "$COUNT" == "null" ] || [ "$COUNT" -eq 0 ] 2>/dev/null; then
        echo -e "${CR}   ${C_YELLOW}⚠  Release '$RELEASE_TAG' exists but has no APKs.${C_RESET}"
        echo -e "${CR}   ${C_GRAY}  Upload APKs named: Delta.1.apk, Delta.NoKey.1.apk${C_RESET}"
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

    echo -e "${CR}   ${C_GREEN}✔  Found ${#ASSET_NAMES[@]} APK(s) in '$RELEASE_TAG'${C_RESET}"
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

install_apk() {
    local NAME="$1"
    local URL="$2"
    local SIZE="$3"
    local TEMP_ENC="/sdcard/Download/starshop_temp.enc"
    local TEMP_APK="/sdcard/Download/starshop_temp.apk"
    local PID=""
    local DL_STATUS=0

    echo -e "${CR}   ${C_SAPPHIRE}${SUB}${C_RESET}"
    rm -f "$TEMP_ENC" "$TEMP_APK"

    local IS_ENC=0
    case "$NAME" in
        *.enc|*.ENC) IS_ENC=1; local DL_TARGET="$TEMP_ENC"; local TAG="enc" ;;
        *)           IS_ENC=0; local DL_TARGET="$TEMP_APK"; local TAG="apk" ;;
    esac

    curl -sL -A "Mozilla/5.0" "$URL" -o "$DL_TARGET" &
    PID=$!

    local DOTS=""
    while kill -0 $PID 2>/dev/null; do
        if [ ${#DOTS} -ge 3 ]; then DOTS=""; else DOTS+="."; fi
        echo -ne "${CR}   ${C_YELLOW}📥  $NAME ${C_GRAY}($SIZE, $TAG) ${C_CYAN}${DOTS}${C_RESET}"
        sleep 0.4
    done
    wait $PID
    DL_STATUS=$?

    if [ $DL_STATUS -ne 0 ] || [ ! -f "$DL_TARGET" ]; then
        echo -e "${CR}   ${C_RED}✘  Download failed (curl: $DL_STATUS)${C_RESET}"
        rm -f "$TEMP_ENC" "$TEMP_APK"
        return 1
    fi

    local FILE_SIZE_KB
    FILE_SIZE_KB=$(du -k "$DL_TARGET" | awk '{print $1}')
    if [ "$FILE_SIZE_KB" -le 1024 ]; then
        echo -e "${CR}   ${C_RED}✘  File too small (${FILE_SIZE_KB}KB) — bad URL?${C_RESET}"
        rm -f "$TEMP_ENC" "$TEMP_APK"
        return 1
    fi

    if [ $IS_ENC -eq 1 ]; then
        if ! command -v openssl >/dev/null 2>&1; then
            echo -e "${CR}   ${C_YELLOW}📦  Installing openssl (one-time, ~30-60s)...${C_RESET}"
            pkg install openssl-tool -y >/dev/null 2>&1
            if ! command -v openssl >/dev/null 2>&1; then
                echo -e "${CR}   ${C_RED}✘  openssl install failed${C_RESET}"
                rm -f "$TEMP_ENC" "$TEMP_APK"
                return 1
            fi
        fi
        echo -ne "${CR}   ${C_PURPLE}🔓  Decrypting...${C_RESET}"
        if ! openssl enc -d -aes-256-cbc -pbkdf2 \
                -in "$TEMP_ENC" -out "$TEMP_APK" \
                -pass "pass:$DECRYPT_KEY" 2>/dev/null; then
            echo -e " ${C_RED}FAIL${C_RESET}"
            rm -f "$TEMP_ENC" "$TEMP_APK"
            return 1
        fi
        echo -e " ${C_GREEN}OK${C_RESET}"
        rm -f "$TEMP_ENC"
    fi

    chmod 644 "$TEMP_APK" 2>/dev/null
    echo -e "${CR}   ${C_GREEN}⚡  Installing $NAME ...${C_RESET}"

    if command -v su >/dev/null 2>&1 && su -c "true" >/dev/null 2>&1; then
        su -c "pm install -r \"$TEMP_APK\"" >/dev/null 2>&1
        local PM_STATUS=$?
        stty sane 2>/dev/null
        if [ $PM_STATUS -eq 0 ]; then
            echo -e "${CR}   ${C_GREEN}✔  Installed (rooted)${C_RESET}"
        else
            echo -e "${CR}   ${C_YELLOW}⚠  Opening installer...${C_RESET}"
            termux-open --content-type "application/vnd.android.package-archive" "$TEMP_APK"
            stty sane 2>/dev/null
        fi
    else
        termux-open --content-type "application/vnd.android.package-archive" "$TEMP_APK"
        stty sane 2>/dev/null
        echo -e "${CR}   ${C_GREEN}✔  Installer opened. Tap 'Install'.${C_RESET}"
    fi
}

process_category() {
    local CATEGORY_LABEL="$1"
    local CATEGORY_PREFIX="$2"

    filter_by_category "$CATEGORY_PREFIX"
    local TOTAL=${#FILTERED_INDICES[@]}

    if [ "$TOTAL" -eq 0 ]; then
        echo ""
        echo -e "${C_SAPPHIRE}   ┌──────────────────────────────────────────────────┐${C_RESET}"
        echo -e "${C_SAPPHIRE}   │  ${C_YELLOW}📂  $CATEGORY_LABEL${C_RESET}"
        echo -e "${C_SAPPHIRE}   │  ${C_RED}empty${C_GRAY} — no APKs uploaded yet${C_RESET}"
        echo -e "${C_SAPPHIRE}   └──────────────────────────────────────────────────┘${C_RESET}"
        echo ""
        echo -e "   ${C_GRAY}Expected filename prefix: ${C_WHITE}$CATEGORY_PREFIX<N>.apk${C_RESET}"
        echo ""
        echo -ne "   ${C_YELLOW}Press Enter to go back...${C_RESET}"
        read
        return 0
    fi

    while true; do
        clear
        stty sane 2>/dev/null
        print_logo
        echo ""
        echo -e "${C_SAPPHIRE}   ┌──────────────────────────────────────────────────┐${C_RESET}"
        echo -e "${C_SAPPHIRE}   │  ${C_YELLOW}📂  CATEGORY: ${C_BOLD}$CATEGORY_LABEL${C_SAPPHIRE}  ($TOTAL)${C_RESET}"
        echo -e "${C_SAPPHIRE}   └──────────────────────────────────────────────────┘${C_RESET}"
        echo ""
        local i
        for i in "${!FILTERED_INDICES[@]}"; do
            local IDX="${FILTERED_INDICES[$i]}"
            local N="${ASSET_NAMES[$IDX]}"
            local S="${ASSET_SIZES[$IDX]}"
            echo -e "   ${C_PURPLE}[$((i+1))]${C_RESET} ${C_BLUE}▸${C_RESET} ${C_WHITE}$N${C_GRAY}  ($S)${C_RESET}"
        done
        echo ""
        echo -e "   ${C_GRAY}Pick: number / range (1-3) / 'all'  —  0 = back${C_RESET}"
        echo -ne "${CR}   ${C_GREEN}🎯  Choice: ${C_RESET}"
        read INPUT_CHOICE
        echo ""
        if [ "$INPUT_CHOICE" == "0" ]; then return 0; fi

        local SELECTED=()
        local VALID_INPUT=0
        if [ "$INPUT_CHOICE" == "all" ] || [ "$INPUT_CHOICE" == "ALL" ]; then
            for i in "${!FILTERED_INDICES[@]}"; do SELECTED+=($i); done
            VALID_INPUT=1
        else
            for ITEM in $INPUT_CHOICE; do
                if [[ "$ITEM" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                    local START=${BASH_REMATCH[1]}; local END=${BASH_REMATCH[2]}
                    if [ "$START" -gt "$END" ]; then local T=$START; START=$END; END=$T; fi
                    for ((j=START; j<=END; j++)); do
                        if [ $((j-1)) -ge 0 ] && [ $((j-1)) -lt $TOTAL ]; then
                            SELECTED+=($((j-1))); VALID_INPUT=1
                        fi
                    done
                elif [[ "$ITEM" =~ ^[0-9]+$ ]]; then
                    if [ $((ITEM-1)) -ge 0 ] && [ $((ITEM-1)) -lt $TOTAL ]; then
                        SELECTED+=($((ITEM-1))); VALID_INPUT=1
                    fi
                fi
            done
        fi

        if [ $VALID_INPUT -eq 1 ]; then
            clear
            echo ""
            echo -e "${C_SAPPHIRE}   ┌──────────────────────────────────────────────────┐${C_RESET}"
            echo -e "${C_SAPPHIRE}   │  ${C_GREEN}${C_BOLD}🚀  INSTALLING ${#SELECTED[@]} APK(s)${C_RESET}"
            echo -e "${C_SAPPHIRE}   └──────────────────────────────────────────────────┘${C_RESET}"
            echo ""
            for IDX_REL in "${SELECTED[@]}"; do
                local IDX_ABS="${FILTERED_INDICES[$IDX_REL]}"
                install_apk "${ASSET_NAMES[$IDX_ABS]}" "${ASSET_URLS[$IDX_ABS]}" "${ASSET_SIZES[$IDX_ABS]}"
            done
            echo ""
            echo -e "${C_SAPPHIRE}   ${SUB}${C_RESET}"
            echo -ne "   ${C_YELLOW}Press Enter to return...${C_RESET}"
            read
        else
            echo -e "${CR}   ${C_RED}✘  Invalid choice${C_RESET}"
            sleep 1.2
        fi
    done
}

main() {
    preflight
    check_main_password
    if ! fetch_release_assets; then
        echo ""
        echo -ne "   ${C_YELLOW}Press Enter to continue...${C_RESET}"
        read
    fi

    while true; do
        clear
        stty sane 2>/dev/null
        print_logo
        echo ""
        echo -e "${C_SAPPHIRE}   ┌──────────────────────────────────────────────────┐${C_RESET}"
        echo -e "${C_SAPPHIRE}   │  ${C_PINK}👑  Dev ${C_RESET}: ${C_WHITE}${OWNER_TAG}${C_RESET}                            ${C_SAPPHIRE}│${C_RESET}"
        echo -e "${C_SAPPHIRE}   │  ${C_PINK}💬  Disc ${C_RESET}: ${C_WHITE}${DISCORD_LINK}${C_RESET}      ${C_SAPPHIRE}│${C_RESET}"
        echo -e "${C_SAPPHIRE}   └──────────────────────────────────────────────────┘${C_RESET}"
        echo ""

        filter_by_category "Delta."
        local N_DELTA=${#FILTERED_INDICES[@]}
        filter_by_category "Delta.NoKey."
        local N_NOKEY=${#FILTERED_INDICES[@]}
        if [ "$N_NOKEY" -eq 0 ]; then
            filter_by_category "Delta_NoKey_"
            N_NOKEY=${#FILTERED_INDICES[@]}
        fi

        echo -e "${C_SAPPHIRE}   ┌──────────────────────────────────────────────────┐${C_RESET}"
        echo -e "${C_SAPPHIRE}   │  ${C_YELLOW}★  MENU${C_RESET}                                                ${C_SAPPHIRE}│${C_RESET}"
        echo -e "${C_SAPPHIRE}   ├──────────────────────────────────────────────────┤${C_RESET}"
        echo -e "${C_SAPPHIRE}   │   ${C_PURPLE}[1]${C_RESET} ${C_BLUE}▸${C_RESET} ${C_GREEN}Delta${C_RESET}              ${C_GRAY}($N_DELTA APK)${C_RESET}                  ${C_SAPPHIRE}│${C_RESET}"
        echo -e "${C_SAPPHIRE}   │   ${C_PURPLE}[2]${C_RESET} ${C_BLUE}▸${C_RESET} ${C_PINK}Delta No Key${C_RESET} ${C_YELLOW}💎${C_RESET}   ${C_GRAY}($N_NOKEY APK, VIP)${C_RESET}       ${C_SAPPHIRE}│${C_RESET}"
        echo -e "${C_SAPPHIRE}   │   ${C_RED}[0]${C_RESET} ${C_BLUE}⏏${C_RESET}  Exit                                          ${C_SAPPHIRE}│${C_RESET}"
        echo -e "${C_SAPPHIRE}   └──────────────────────────────────────────────────┘${C_RESET}"
        echo ""

        echo -ne "${CR}   ${C_GREEN}🎯  Choose (0-2): ${C_RESET}"
        read MAIN_CHOICE
        echo ""

        case "$MAIN_CHOICE" in
            1) process_category "Delta" "Delta." ;;
            2)
                if check_vip_password; then
                    local NOKEY_PREFIX="Delta.NoKey."
                    filter_by_category "$NOKEY_PREFIX"
                    if [ ${#FILTERED_INDICES[@]} -eq 0 ]; then
                        NOKEY_PREFIX="Delta_NoKey_"
                    fi
                    process_category "Delta No Key" "$NOKEY_PREFIX"
                fi
                ;;
            0) break ;;
            *)
                echo -e "${CR}   ${C_RED}✘  Invalid (0-2)${C_RESET}"
                sleep 1.2
                ;;
        esac
    done

    stty sane 2>/dev/null
    clear
    print_logo
    echo -e "${C_SAPPHIRE}   ┌──────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_SAPPHIRE}   │  ${C_GREEN}${C_BOLD}⭐  Thanks for using STAR SHOP!  ⭐${C_RESET}            ${C_SAPPHIRE}│${C_RESET}"
    echo -e "${C_SAPPHIRE}   └──────────────────────────────────────────────────┘${C_RESET}"
    echo ""
}

main "$@"