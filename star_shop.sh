#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  STAR SHOP AUTO-INSTALLER v1.0
#  Repo: nuxy1466-blip/STARPLUS
# ============================================================

OWNER_TAG="STAR SHOP"
REPO_OWNER="nuxy1466-blip"
REPO_NAME="STARPLUS"
SCRIPT_VERSION="v1.0"
DISCORD_LINK="https://discord.gg/mCF27C2eXn"
MAX_ATTEMPTS=3
MAIN_PASSWORD="STAR99"
VIP_PASSWORD="STARVVIP993"
RELEASE_TAG="${RELEASE_TAG:-V1.0}"
DECRYPT_KEY="StarShop2025"

C_RESET="\033[0m"; C_BOLD="\033[1m"
C_RED="\033[38;5;203m"; C_GREEN="\033[38;5;114m"; C_YELLOW="\033[38;5;221m"
C_BLUE="\033[38;5;75m"; C_PURPLE="\033[38;5;177m"; C_CYAN="\033[38;5;81m"
C_WHITE="\033[38;5;255m"; C_GRAY="\033[38;5;245m"; C_EMERALD="\033[38;5;42m"
C_PINK="\033[38;5;212m"; C_GOLD="\033[38;5;220m"
C_SAPPHIRE="\033[1;38;5;27m"; C_SAPPHIRE_LITE="\033[38;5;33m"
C_SAPPHIRE_BG="\033[1;48;5;27;38;5;231m"
CR="\r\033[K"
C_DIV="══════════════════════════════════════════════════════════════════"
C_SUB="──────────────────────────────────────────────────────────────────"
C_DBL="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

hash -r 2>/dev/null; stty sane 2>/dev/null

type_text() { local t="$1" c="$2"; echo -ne "${CR}${c}"; for ((i=0;i<${#t};i++)); do echo -ne "${t:$i:1}"; sleep 0.015; done; echo -e "${C_RESET}"; }

print_banner() {
    clear
    echo -e "${C_GOLD}  ${C_DIV}${C_RESET}"
    echo -e "  ${C_SAPPHIRE_BG}                                                                ${C_RESET}"
    echo -e "  ${C_SAPPHIRE_BG}    ${C_WHITE}${C_BOLD}  ★  S T A R   S H O P  ★                              ${C_RESET}"
    echo -e "  ${C_SAPPHIRE_BG}    ${C_YELLOW}       ${C_SAPPHIRE_LITE}[${C_YELLOW}${SCRIPT_VERSION}${C_SAPPHIRE_LITE}]  Automated APK Installer           ${C_RESET}"
    echo -e "  ${C_SAPPHIRE_BG}                                                                ${C_RESET}"
    echo -e "${C_GOLD}  ${C_DIV}${C_RESET}"
    echo ""
}

preflight() {
    command -v curl >/dev/null 2>&1 || { pkg install curl -y >/dev/null 2>&1; }
    if ! command -v jq >/dev/null 2>&1; then
        echo -ne "${CR}${C_YELLOW}⚙️  Installing jq...${C_RESET}"
        pkg install jq -y >/dev/null 2>&1; echo -e " ${C_GREEN}OK${C_RESET}"
    fi
    [ -d /sdcard/Download ] && touch /sdcard/Download/.t 2>/dev/null && rm -f /sdcard/Download/.t || { termux-setup-storage; sleep 3; }
}

get_device_info() {
    OS_VER=$(getprop ro.build.version.release 2>/dev/null || echo "?")
    ARCH=$(uname -m 2>/dev/null || echo "?")
}

check_main_password() {
    print_banner
    echo -e "   ${C_SAPPHIRE}${C_BOLD}★  MEMBER GATE  ★${C_RESET}"
    echo -e "   ${C_GRAY}Authorized access only${C_RESET}"
    echo ""
    local A=0
    while [ $A -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}   ${C_GOLD}🔑  Password: ${C_RESET}"
        read -s P; echo ""
        P=$(echo "$P" | tr -d '[:space:]')
        [ "$P" == "$MAIN_PASSWORD" ] && { type_text "    ✔  Welcome to STAR SHOP!" "$C_EMERALD"; sleep 0.8; get_device_info; return 0; }
        echo -e "${CR}   ${C_RED}❌  Wrong (left: $((MAX_ATTEMPTS-A-1)))${C_RESET}"
        A=$((A+1))
    done
    echo -e "${CR}   ${C_RED}🚫  Locked.${C_RESET}"; exit 1
}

check_vip_password() {
    echo -e "${CR}   ${C_PURPLE}${C_DBL}${C_RESET}"
    echo -e "   ${C_PURPLE}${C_BOLD}💎  VIP CATEGORY — EXTRA VERIFICATION  💎${C_RESET}"
    echo -e "${CR}   ${C_PURPLE}${C_DBL}${C_RESET}"
    echo ""
    local A=0
    while [ $A -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}   ${C_PURPLE}🔑  VIP password: ${C_RESET}"
        read -s P; echo ""
        P=$(echo "$P" | tr -d '[:space:]')
        [ "$P" == "$VIP_PASSWORD" ] && { type_text "    ✔  VIP granted!" "$C_EMERALD"; sleep 0.5; return 0; }
        echo -e "${CR}   ${C_RED}❌  Wrong VIP (left: $((MAX_ATTEMPTS-A-1)))${C_RESET}"
        A=$((A+1))
    done
    echo -e "${CR}   ${C_RED}🚫  VIP denied. Returning...${C_RESET}"; sleep 1.5; return 1
}

fetch_release_assets() {
    ASSET_NAMES=(); ASSET_URLS=(); ASSET_SIZES=()
    if [ "$RELEASE_TAG" == "latest" ]; then
        API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    else
        API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${RELEASE_TAG}"
    fi
    type_text "    📡  Fetching catalog from GitHub..." "$C_CYAN"
    local R
    R=$(curl -sL -H "Accept: application/vnd.github+json" "$API_URL" 2>/dev/null)
    [ -z "$R" ] && { echo -e "${CR}   ${C_RED}❌  Cannot reach GitHub API.${C_RESET}"; return 1; }
    local E
    E=$(echo "$R" | jq -r '.message // empty' 2>/dev/null)
    if [ -n "$E" ] && [ "$E" != "null" ]; then
        echo -e "${CR}   ${C_RED}❌  GitHub: $E${C_RESET}"
        if [ "$E" == "Not Found" ]; then
            echo ""
            echo -e "   ${C_YELLOW}⚠️  HOW TO FIX:${C_RESET}"
            echo -e "   ${C_GRAY}1. Go to: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/new${C_RESET}"
            echo -e "   ${C_GRAY}2. Set tag exactly: ${C_WHITE}${RELEASE_TAG}${C_GRAY} (case-sensitive!)${C_RESET}"
            echo -e "   ${C_GRAY}3. Upload APK files (Delta.1.apk, Delta.NoKey.1.apk, ...)${C_RESET}"
            echo -e "   ${C_GRAY}4. Click ${C_WHITE}Publish release${C_GRAY} (not draft)${C_RESET}"
            echo -e "   ${C_GRAY}5. Re-run this script${C_RESET}"
            echo ""
            echo -e "   ${C_GRAY}Tip: If using tag 'v1.0', edit RELEASE_TAG in script.${C_RESET}"
        fi
        return 1
    fi
    local C
    C=$(echo "$R" | jq -r '.assets | length' 2>/dev/null)
    if [ -z "$C" ] || [ "$C" == "null" ] || [ "$C" -eq 0 ] 2>/dev/null; then
        echo -e "${CR}   ${C_YELLOW}⚠️  Release '${RELEASE_TAG}' has no APKs yet.${C_RESET}"
        echo -e "${CR}   ${C_GRAY}     Upload at: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases${C_RESET}"
        return 1
    fi
    local i=0
    while [ $i -lt $C ]; do
        ASSET_NAMES+=("$(echo "$R" | jq -r ".assets[$i].name" 2>/dev/null)")
        ASSET_URLS+=("$(echo "$R" | jq -r ".assets[$i].browser_download_url" 2>/dev/null)")
        local SB=$(echo "$R" | jq -r ".assets[$i].size" 2>/dev/null)
        [ -n "$SB" ] && [ "$SB" != "null" ] && ASSET_SIZES+=("$(awk "BEGIN {printf \"%.1f MB\", $SB/1048576}" 2>/dev/null)") || ASSET_SIZES+=("?")
        i=$((i+1))
    done
    echo -e "${CR}   ${C_GREEN}✔  Found ${#ASSET_NAMES[@]} APK(s) in '${RELEASE_TAG}'${C_RESET}"
    sleep 0.4
    return 0
}

filter_by_category() {
    local P="$1"; FILTERED_INDICES=()
    for i in "${!ASSET_NAMES[@]}"; do
        local N="${ASSET_NAMES[$i]}"
        case "$N" in
            "${P}"*)
                case "$N" in
                    "Delta.NoKey."*)  [ "$P" != "Delta.NoKey."  ] && continue ;;
                    "Delta_NoKey_"*)  [ "$P" != "Delta_NoKey_"  ] && continue ;;
                esac
                FILTERED_INDICES+=($i);;
        esac
    done
}

install_apk() {
    local NAME="$1" URL="$2" SIZE="$3"
    local TE="/sdcard/Download/starshop_temp.enc" TA="/sdcard/Download/starshop_temp.apk"
    echo -e "${CR}${C_CYAN}   ${C_SUB}${C_RESET}"
    rm -f "$TE" "$TA"
    local IS_ENC=0 DT="$TA" TG="plain"
    case "$NAME" in *.enc|*.ENC) IS_ENC=1; DT="$TE"; TG="encrypted";; esac
    curl -sL -A "Mozilla/5.0" "$URL" -o "$DT" &
    local PID=$! DOTS=""
    while kill -0 $PID 2>/dev/null; do
        [ ${#DOTS} -ge 3 ] && DOTS="" || DOTS+="."
        echo -ne "${CR}   ${C_YELLOW}📥  Downloading: ${C_WHITE}$NAME ${C_GRAY}(${SIZE}, ${TG}) ${C_CYAN}${DOTS}${C_RESET}"
        sleep 0.4
    done
    wait $PID; local S=$?
    echo -e "${CR}   ${C_YELLOW}📥  Downloaded: ${C_WHITE}$NAME${C_RESET}"
    if [ $S -ne 0 ] || [ ! -f "$DT" ]; then
        echo -e "${CR}   ${C_RED}❌  Download failed (curl: $S)${C_RESET}"
        rm -f "$TE" "$TA"; return 1
    fi
    local FK=$(du -k "$DT" | awk '{print $1}')
    if [ "$FK" -le 1024 ]; then
        echo -e "${CR}   ${C_RED}❌  Too small (${FK}KB). 404 page?${C_RESET}"
        rm -f "$TE" "$TA"; return 1
    fi
    if [ $IS_ENC -eq 1 ]; then
        if ! command -v openssl >/dev/null 2>&1; then
            echo -e "${CR}   ${C_YELLOW}📦  Installing openssl (~30-60s)...${C_RESET}"
            pkg install openssl-tool -y >/dev/null 2>&1
            command -v openssl >/dev/null 2>&1 || { echo -e "${CR}   ${C_RED}❌  openssl install failed${C_RESET}"; rm -f "$TE" "$TA"; return 1; }
            echo -e "${CR}   ${C_GREEN}✔  openssl ready${C_RESET}"
        fi
        echo -ne "${CR}   ${C_PURPLE}🔓  Decrypting...${C_RESET}"
        openssl enc -d -aes-256-cbc -pbkdf2 -in "$TE" -out "$TA" -pass "pass:$DECRYPT_KEY" 2>/dev/null || {
            echo -e " ${C_RED}FAIL${C_RESET}"; echo -e "${CR}   ${C_RED}❌  Decryption failed${C_RESET}"; rm -f "$TE" "$TA"; return 1; }
        echo -e " ${C_GREEN}OK${C_RESET}"; rm -f "$TE"
        FK=$(du -k "$TA" | awk '{print $1}')
        [ "$FK" -le 1024 ] && { echo -e "${CR}   ${C_RED}❌  Decrypted too small${C_RESET}"; rm -f "$TA"; return 1; }
    fi
    chmod 644 "$TA" 2>/dev/null
    echo -e "${CR}   ${C_GREEN}⚡  Installing: ${C_RESET}$NAME ..."
    if command -v su >/dev/null 2>&1 && su -c "true" >/dev/null 2>&1; then
        su -c "pm install -r \"$TA\"" >/dev/null 2>&1
        local PS=$?
        stty sane 2>/dev/null
        [ $PS -eq 0 ] && echo -e "${CR}   ${C_GREEN}✅  Installed silently (rooted)${C_RESET}" || {
            echo -e "${CR}   ${C_RED}❌  Silent failed, opening installer...${C_RESET}"
            termux-open --content-type "application/vnd.android.package-archive" "$TA"; stty sane 2>/dev/null; }
    else
        termux-open --content-type "application/vnd.android.package-archive" "$TA"
        stty sane 2>/dev/null
        echo -e "${CR}   ${C_GREEN}✅  Installer opened. Tap 'Install'.${C_RESET}"
    fi
}

process_category() {
    local L="$1" P="$2"
    filter_by_category "$P"
    local T=${#FILTERED_INDICES[@]}
    if [ "$T" -eq 0 ]; then
        echo -e "${CR}   ${C_YELLOW}⚠️  No APKs in this category yet ($L).${C_RESET}"
        echo -e "${CR}   ${C_GRAY}     Prefix: '$P'${C_RESET}"
        echo -e "${CR}   ${C_GRAY}     Upload: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases${C_RESET}"
        echo -ne "${CR}   ${C_YELLOW}Press Enter...${C_RESET}"; read; return 0
    fi
    while true; do
        clear; stty sane 2>/dev/null
        echo -e "${C_SAPPHIRE}   ${C_DIV}${C_RESET}"
        echo -e "       ${C_YELLOW}${C_BOLD}📁  CATEGORY: ${L}${C_RESET}"
        echo -e "       ${C_GRAY}(${T} APK${T:+s})${C_RESET}"
        echo -e "${C_SAPPHIRE}   ${C_DIV}${C_RESET}"; echo ""
        for i in "${!FILTERED_INDICES[@]}"; do
            local IDX="${FILTERED_INDICES[$i]}"
            echo -e "${CR}   ${C_PURPLE}[$((i+1))]${C_RESET} ${C_BLUE}▸${C_RESET} ${C_WHITE}${ASSET_NAMES[$IDX]}${C_GRAY} (${ASSET_SIZES[$IDX]})${C_RESET}"
        done
        echo -e "${CR}   ${C_SUB}${C_RESET}"
        echo -e "${CR}   ${C_YELLOW}💡  Pick: number (1-${T}), range (1-3), or 'all'${C_RESET}"
        echo -e "${CR}       ${C_WHITE}(0 = back)${C_RESET}"
        echo -e "${CR}   ${C_SUB}${C_RESET}"
        echo -ne "${CR}   ${C_GREEN}🎯  Choice: ${C_RESET}"; read I; echo ""
        [ "$I" == "0" ] && return 0
        local SEL=() VI=0
        if [ "$I" == "all" ] || [ "$I" == "ALL" ]; then
            for i in "${!FILTERED_INDICES[@]}"; do SEL+=($i); done; VI=1
        else
            for X in $I; do
                if [[ "$X" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                    local S=${BASH_REMATCH[1]} E=${BASH_REMATCH[2]}
                    [ "$S" -gt "$E" ] && { local T2=$S; S=$E; E=$T2; }
                    for ((j=S; j<=E; j++)); do
                        [ $((j-1)) -ge 0 ] && [ $((j-1)) -lt $T ] && { SEL+=($((j-1))); VI=1; }
                    done
                elif [[ "$X" =~ ^[0-9]+$ ]]; then
                    [ $((X-1)) -ge 0 ] && [ $((X-1)) -lt $T ] && { SEL+=($((X-1))); VI=1; }
                fi
            done
        fi
        if [ $VI -eq 1 ]; then
            clear; stty sane 2>/dev/null
            echo -e "${C_SAPPHIRE}   ${C_DIV}${C_RESET}"
            echo -e "       ${C_GREEN}${C_BOLD}🚀  Installing ${#SEL[@]} APK${#SEL[@]:+s}${C_RESET}"
            echo -e "${C_SAPPHIRE}   ${C_DIV}${C_RESET}"
            for R in "${SEL[@]}"; do
                local A="${FILTERED_INDICES[$R]}"
                install_apk "${ASSET_NAMES[$A]}" "${ASSET_URLS[$A]}" "${ASSET_SIZES[$A]}"
            done
            echo -e "${CR}   ${C_SUB}${C_RESET}"
            echo -ne "${CR}   ${C_YELLOW}✨  Press Enter...${C_RESET}"; read
        else
            echo -e "${CR}   ${C_RED}[!]  Invalid (1-${T}, range, or all)${C_RESET}"; sleep 1.2
        fi
    done
}

main() {
    preflight
    check_main_password
    if ! fetch_release_assets; then
        echo -ne "${CR}   ${C_YELLOW}Press Enter...${C_RESET}"; read
    fi
    while true; do
        clear; stty sane 2>/dev/null
        echo -e "${C_GOLD}  ${C_DIV}${C_RESET}"
        echo -e "  ${C_SAPPHIRE_BG}                                                                ${C_RESET}"
        echo -e "  ${C_SAPPHIRE_BG}    ${C_WHITE}${C_BOLD}  ★  S T A R   S H O P  ★                              ${C_RESET}"
        echo -e "  ${C_SAPPHIRE_BG}    ${C_YELLOW}       ${C_SAPPHIRE_LITE}[${C_YELLOW}${SCRIPT_VERSION}${C_SAPPHIRE_LITE}]  Automated APK Installer           ${C_RESET}"
        echo -e "  ${C_SAPPHIRE_BG}                                                                ${C_RESET}"
        echo -e "${C_GOLD}  ${C_DIV}${C_RESET}"; echo ""
        echo -e "   ${C_PINK}👑  Dev ${C_RESET} : ${C_WHITE}${OWNER_TAG}${C_RESET}"
        echo -e "   ${C_PINK}💬  Disc ${C_RESET}: ${C_WHITE}${DISCORD_LINK}${C_RESET}"
        echo -e "   ${C_SAPPHIRE}   ${C_SUB}${C_RESET}"; echo ""
        filter_by_category "Delta."; local N_D=${#FILTERED_INDICES[@]}
        filter_by_category "Delta.NoKey."; local N_N=${#FILTERED_INDICES[@]}
        [ "$N_N" -eq 0 ] && { filter_by_category "Delta_NoKey_"; N_N=${#FILTERED_INDICES[@]}; }
        echo -e "   ${C_SAPPHIRE}┌${C_SUB}┐${C_RESET}"
        echo -e "   ${C_SAPPHIRE}│${C_RESET}  ${C_GRAY}CATEGORIES${C_RESET}                                            ${C_SAPPHIRE}│${C_RESET}"
        echo -e "   ${C_SAPPHIRE}├${C_SUB}┤${C_RESET}"
        echo -e "   ${C_SAPPHIRE}│${C_RESET}  ${C_PURPLE}[1]${C_RESET} ${C_GREEN}Delta${C_RESET}              ${C_GRAY}(${N_D} APK${N_D:+s})${C_RESET}                       ${C_SAPPHIRE}│${C_RESET}"
        echo -e "   ${C_SAPPHIRE}│${C_RESET}  ${C_PURPLE}[2]${C_RESET} ${C_PINK}Delta No Key 💎${C_RESET}  ${C_GRAY}(${N_N} APK${N_N:+s})  ${C_YELLOW}[VIP]${C_RESET}                ${C_SAPPHIRE}│${C_RESET}"
        echo -e "   ${C_SAPPHIRE}│${C_RESET}  ${C_RED}   [0]${C_RESET} ${C_RED}Exit${C_RESET}                                              ${C_SAPPHIRE}│${C_RESET}"
        echo -e "   ${C_SAPPHIRE}└${C_SUB}┘${C_RESET}"; echo ""
        echo -ne "${CR}   ${C_GREEN}🎯  Choose (0-2): ${C_RESET}"; read M; echo ""
        case "$M" in
            1) process_category "Delta" "Delta.";;
            2) if check_vip_password; then
                   local NP="Delta.NoKey."; filter_by_category "$NP"
                   [ ${#FILTERED_INDICES[@]} -eq 0 ] && NP="Delta_NoKey_"
                   process_category "Delta No Key" "$NP"
               fi;;
            0) break;;
            *) echo -e "${CR}   ${C_RED}[!]  Invalid (0-2)${C_RESET}"; sleep 1.2;;
        esac
    done
    stty sane 2>/dev/null; clear
    echo -e "${C_SAPPHIRE}  ${C_DIV}${C_RESET}"
    echo -e "  ${C_SAPPHIRE_BG}    ${C_WHITE}${C_BOLD}  ★  Thanks for using STAR SHOP!  ★       ${C_RESET}"
    echo -e "${C_SAPPHIRE}  ${C_DIV}${C_RESET}"
    echo ""
}

main "$@"