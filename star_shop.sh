OWNER_TAG="STAR SHOP"
REPO_OWNER="nuxy1466-blip"
REPO_NAME="STARPLUS"
SCRIPT_VERSION="v1.1"
DISCORD_LINK="https://discord.gg/your-invite"
MAX_ATTEMPTS=3
MAIN_PASSWORD="STAR99"
VIP_PASSWORD="STARVVIP993"
RELEASE_TAG="${RELEASE_TAG:-V1.0}"
DECRYPT_KEY="StarShop2025"

# ---------- COLORS ----------
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
C_BLUE_BRIGHT="\033[1;38;5;33m"

CR="\r\033[K"
C_DIV="══════════════════════════════════════════════════════════════════"
C_SUB="──────────────────────────────────────────────────────────────────"

hash -r 2>/dev/null
stty sane 2>/dev/null

# ---------- Progress bar ----------
draw_progress() {
    local pct="$1"
    local label="$2"
    local width=40
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local bar=""
    local i
    for (( i=0; i<filled; i++ )); do bar+="█"; done
    for (( i=0; i<empty; i++ )); do bar+=" "; done
    echo -ne "${CR}  ${C_BLUE_BRIGHT}${bar}${C_RESET} ${C_WHITE}${pct}%${C_RESET} ${C_GREEN}✓${C_RESET} ${C_GRAY}${label}${C_RESET}        "
}

# ---------- Banner (บล็อกล้วน — ไม่มี backslash ไม่มีทางเพี้ยน) ----------
print_banner() {
    clear
    echo -e "${C_SAPPHIRE}${C_DIV}${C_RESET}"
    echo -e "${C_GOLD}  ███████╗████████╗ █████╗ ██████╗ ${C_RESET}"
    echo -e "${C_GOLD}  ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗ ${C_RESET}"
    echo -e "${C_GOLD}  ███████╗   ██║   ███████║██████╔╝ ${C_RESET}"
    echo -e "${C_GOLD}  ╚════██║   ██║   ██╔══██║██╔══██╗ ${C_RESET}"
    echo -e "${C_GOLD}  ███████║   ██║   ██║  ██║██║  ██║ ${C_RESET}"
    echo -e "${C_GOLD}  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ${C_RESET}"
    echo -e "${C_BLUE_BRIGHT}        ███████╗ ██████╗ ██████╗ ██████╗${C_RESET}"
    echo -e "${C_BLUE_BRIGHT}        ██╔════╝██╔════╝██╔═══██╗██╔══██╗${C_RESET}"
    echo -e "${C_BLUE_BRIGHT}        ███████╗██║     ██║   ██║██████╔╝${C_RESET}"
    echo -e "${C_BLUE_BRIGHT}        ╚════██║██║     ██║   ██║██╔═══╝${C_RESET}"
    echo -e "${C_BLUE_BRIGHT}        ███████║╚██████╗╚██████╔╝██║${C_RESET}"
    echo -e "${C_BLUE_BRIGHT}        ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}★  STAR SHOP ${C_SAPPHIRE}[${C_YELLOW}${SCRIPT_VERSION}${C_SAPPHIRE}]  ${C_GRAY}Automated APK Installer  ★${C_RESET}"
    echo -e "${C_SAPPHIRE}${C_DIV}${C_RESET}"
}

preflight() {
    print_banner
    echo -e "  ${C_WHITE}${C_BOLD}🚀  การเตรียมระบบ${C_RESET}"
    echo -e "  ${C_GRAY}Loading dependencies...${C_RESET}"
    echo ""

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "  ${C_RED}● ${C_WHITE}โหลด: curl${C_RESET}"
        pkg install curl -y >/dev/null 2>&1
        draw_progress 25 "curl"
        echo ""
    else
        draw_progress 25 "curl ready"
        echo ""
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo -e "  ${C_RED}● ${C_WHITE}โหลด: jq (JSON parser)${C_RESET}"
        pkg install jq -y >/dev/null 2>&1
        draw_progress 50 "jq"
        echo ""
    else
        draw_progress 50 "jq ready"
        echo ""
    fi

    if [ ! -d "/sdcard/Download" ] || ! touch "/sdcard/Download/.test_perm" 2>/dev/null; then
        echo -e "  ${C_YELLOW}● ${C_WHITE}ขอสิทธิ์ storage...${C_RESET}"
        echo -e "  ${C_GRAY}กด 'Allow' บนหน้าจอ${C_RESET}"
        termux-setup-storage
        sleep 3
        draw_progress 75 "storage"
        echo ""
    else
        draw_progress 75 "storage ready"
        echo ""
    fi
    rm -f "/sdcard/Download/.test_perm" 2>/dev/null

    draw_progress 100 "openssl (lazy)"
    echo ""
    echo ""
    echo -e "  ${C_GREEN}${C_BOLD}✔ พร้อมใช้งาน!${C_RESET}"
    sleep 0.8
}

get_device_info() {
    OS_VER=$(getprop ro.build.version.release 2>/dev/null || echo "?")
    ARCH=$(uname -m 2>/dev/null || echo "?")
}

check_main_password() {
    clear
    print_banner
    echo -e "  ${C_WHITE}${C_BOLD}🔒  MEMBER GATE${C_RESET}"
    echo ""

    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}  ${C_YELLOW}🔑 ${C_WHITE}กรอกรหัสผ่าน ${C_GRAY}(เหลือ $((MAX_ATTEMPTS - ATTEMPTS)) ครั้ง): ${C_RESET}"
        read -s USER_PASS
        echo ""
        USER_PASS=$(echo "$USER_PASS" | tr -d '[:space:]' | tr -d '\r')

        if [ "$USER_PASS" == "$MAIN_PASSWORD" ]; then
            local i=0
            while [ $i -le 100 ]; do
                draw_progress $i "ACCESS GRANTED"
                i=$((i + 5))
                sleep 0.02
            done
            echo ""
            echo ""
            echo -e "  ${C_GREEN}${C_BOLD}✔ ACCESS GRANTED ✔${C_RESET}"
            echo -e "  ${C_GRAY}Welcome to STAR SHOP${C_RESET}"
            sleep 1
            get_device_info
            return 0
        else
            echo -e "  ${C_RED}● ${C_WHITE}รหัสผ่านผิด! ${C_RED}(เหลือ $((MAX_ATTEMPTS - ATTEMPTS - 1)) ครั้ง)${C_RESET}"
            ATTEMPTS=$((ATTEMPTS + 1))
            sleep 0.8
        fi
    done
    echo ""
    echo -e "  ${C_RED}${C_BOLD}🚫 กรอกผิดเกินกำหนด. ล็อคชั่วคราว.${C_RESET}"
    exit 1
}

check_vip_password() {
    echo ""
    echo -e "  ${C_PURPLE}${C_BOLD}💎 VIP CATEGORY — EXTRA VERIFICATION 💎${C_RESET}"
    echo ""

    local ATTEMPTS=0
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
        echo -ne "${CR}  ${C_PURPLE}🔑 ${C_WHITE}VIP password ${C_GRAY}(เหลือ $((MAX_ATTEMPTS - ATTEMPTS)) ครั้ง): ${C_RESET}"
        read -s VIP_PASS
        echo ""
        VIP_PASS=$(echo "$VIP_PASS" | tr -d '[:space:]' | tr -d '\r')

        if [ "$VIP_PASS" == "$VIP_PASSWORD" ]; then
            local i=0
            while [ $i -le 100 ]; do
                draw_progress $i "VIP ACCESS GRANTED"
                i=$((i + 5))
                sleep 0.02
            done
            echo ""
            echo ""
            echo -e "  ${C_GREEN}${C_BOLD}✔ VIP ACCESS GRANTED ✔${C_RESET}"
            sleep 0.8
            return 0
        else
            echo -e "  ${C_RED}● ${C_WHITE}VIP password ผิด! ${C_RED}(เหลือ $((MAX_ATTEMPTS - ATTEMPTS - 1)) ครั้ง)${C_RESET}"
            ATTEMPTS=$((ATTEMPTS + 1))
            sleep 0.8
        fi
    done
    echo ""
    echo -e "  ${C_RED}🚫 VIP access denied. กลับไปเมนูหลัก...${C_RESET}"
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

    echo -e "  ${C_CYAN}📡 Fetching catalog from GitHub...${C_RESET}"
    local RESPONSE
    RESPONSE=$(curl -sL -H "Accept: application/vnd.github+json" "$API_URL" 2>/dev/null)

    if [ -z "$RESPONSE" ]; then
        echo -e "  ${C_RED}❌ Cannot reach GitHub API.${C_RESET}"
        return 1
    fi

    local ERR_MSG
    ERR_MSG=$(echo "$RESPONSE" | jq -r '.message // empty' 2>/dev/null)
    if [ -n "$ERR_MSG" ] && [ "$ERR_MSG" != "null" ]; then
        echo -e "  ${C_RED}❌ GitHub: $ERR_MSG${C_RESET}"
        return 1
    fi

    local COUNT
    COUNT=$(echo "$RESPONSE" | jq -r '.assets | length' 2>/dev/null)
    if [ -z "$COUNT" ] || [ "$COUNT" == "null" ] || [ "$COUNT" -eq 0 ] 2>/dev/null; then
        echo -e "  ${C_YELLOW}⚠️ Release '${RELEASE_TAG}' ยังไม่มีสินค้า${C_RESET}"
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

    echo -e "  ${C_GREEN}✔ พบ ${#ASSET_NAMES[@]} สินค้าใน release '${RELEASE_TAG}'${C_RESET}"
    sleep 0.5
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
                    "Delta.Root."*)   [ "$PREFIX" != "Delta.Root."   ] && continue ;;
                    "Delta_Root_"*)   [ "$PREFIX" != "Delta_Root_"   ] && continue ;;
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

    echo -e "  ${C_SUB}${C_RESET}"
    rm -f "$TEMP_ENC" "$TEMP_APK"

    local IS_ENC=0 DL_TARGET="$TEMP_APK"
    case "$NAME" in
        *.enc|*.ENC) IS_ENC=1; DL_TARGET="$TEMP_ENC";;
    esac

    local SHORT_URL=$(echo "$URL" | sed 's|https://||; s|/[^/]*$|/...|')
    echo -e "  ${C_YELLOW}● ${C_WHITE}ติดตั้ง: ${C_GREEN}$NAME ${C_GRAY}$SHORT_URL${C_RESET}"

    curl -sL -A "Mozilla/5.0" "$URL" -o "$DL_TARGET" &
    local PID=$!

    local i=0
    local spinner="|/-\\"
    while kill -0 $PID 2>/dev/null; do
        local s=${spinner:$((i % 4)):1}
        echo -ne "${CR}  ${C_YELLOW}● ${C_WHITE}ติดตั้ง $NAME ${C_BLUE_BRIGHT}$s${C_RESET}    "
        i=$((i + 1))
        sleep 0.1
    done
    wait $PID
    local DL_STATUS=$?

    draw_progress 100 "downloaded"
    echo ""

    if [ $DL_STATUS -ne 0 ] || [ ! -f "$DL_TARGET" ]; then
        echo -e "  ${C_RED}❌ โหลดล้มเหลว (curl: $DL_STATUS)${C_RESET}"
        rm -f "$TEMP_ENC" "$TEMP_APK"
        return 1
    fi

    local FILE_SIZE_KB
    FILE_SIZE_KB=$(du -k "$DL_TARGET" | awk '{print $1}')
    if [ "$FILE_SIZE_KB" -le 1024 ]; then
        echo -e "  ${C_RED}❌ ไฟล์เล็ก (${FILE_SIZE_KB}KB)${C_RESET}"
        rm -f "$TEMP_ENC" "$TEMP_APK"
        return 1
    fi

    if [ $IS_ENC -eq 1 ]; then
        if ! command -v openssl >/dev/null 2>&1; then
            echo -e "  ${C_YELLOW}📦 ติดตั้ง openssl...${C_RESET}"
            pkg install openssl-tool -y >/dev/null 2>&1
            command -v openssl >/dev/null 2>&1 || {
                echo -e "  ${C_RED}❌ openssl ติดตั้งไม่ได้${C_RESET}"
                rm -f "$TEMP_ENC" "$TEMP_APK"
                return 1
            }
        fi
        echo -ne "  ${C_PURPLE}🔓 กำลังถอดรหัส...${C_RESET}"
        if ! openssl enc -d -aes-256-cbc -pbkdf2 \
                -in "$TEMP_ENC" -out "$TEMP_APK" \
                -pass "pass:$DECRYPT_KEY" 2>/dev/null; then
            echo -e " ${C_RED}FAIL${C_RESET}"
            echo -e "  ${C_RED}❌ ถอดรหัสล้มเหลว (key ไม่ตรง/ไฟล์เสีย)${C_RESET}"
            rm -f "$TEMP_ENC" "$TEMP_APK"
            return 1
        fi
        echo -e " ${C_GREEN}OK${C_RESET}"
        rm -f "$TEMP_ENC"
    fi

    # ตรวจว่า APK สมบูรณ์ก่อนติดตั้ง
    if ! unzip -l "$TEMP_APK" 2>/dev/null | grep -q "AndroidManifest.xml"; then
        echo -e "  ${C_RED}❌ APK เสีย (ไม่มี AndroidManifest) — แจ้งผู้ขาย${C_RESET}"
        rm -f "$TEMP_APK"
        return 1
    fi

    chmod 644 "$TEMP_APK" 2>/dev/null

    if command -v su >/dev/null 2>&1 && su -c "true" >/dev/null 2>&1; then
        su -c "pm install -r \"$TEMP_APK\"" >/dev/null 2>&1
        local PM_STATUS=$?
        stty sane 2>/dev/null
        if [ $PM_STATUS -eq 0 ]; then
            draw_progress 100 "installed (root)"
            echo ""
            echo -e "  ${C_GREEN}✔ ติดตั้งเรียบร้อย (rooted)${C_RESET}"
        else
            echo -e "  ${C_RED}❌ pm install ไม่ผ่าน — เปิด installer แทน...${C_RESET}"
            termux-open --content-type "application/vnd.android.package-archive" "$TEMP_APK"
            stty sane 2>/dev/null
        fi
    else
        draw_progress 100 "opening installer"
        echo ""
        termux-open --content-type "application/vnd.android.package-archive" "$TEMP_APK"
        stty sane 2>/dev/null
        echo -e "  ${C_GREEN}✔ เปิด installer แล้ว กด 'Install' บนจอ${C_RESET}"
    fi
}

process_category() {
    local CATEGORY_LABEL="$1"
    local CATEGORY_PREFIX="$2"

    filter_by_category "$CATEGORY_PREFIX"
    local TOTAL=${#FILTERED_INDICES[@]}

    if [ "$TOTAL" -eq 0 ]; then
        echo ""
        echo -e "  ${C_YELLOW}⚠️ หมวด '$CATEGORY_LABEL' ยังไม่มีสินค้า${C_RESET}"
        echo -e "  ${C_GRAY}ต้องชื่อไฟล์ขึ้นต้นด้วย: '$CATEGORY_PREFIX'${C_RESET}"
        echo -ne "  ${C_YELLOW}กด Enter เพื่อดำเนินการต่อ...${C_RESET}"
        read
        return 0
    fi

    while true; do
        clear
        stty sane 2>/dev/null
        print_banner
        echo -e "  ${C_YELLOW}■ ${C_WHITE}${C_BOLD}หมวด: ${C_GREEN}${CATEGORY_LABEL}${C_RESET}  ${C_GRAY}(${TOTAL} สินค้า)${C_RESET}"
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo ""

        local i
        for i in "${!FILTERED_INDICES[@]}"; do
            local IDX="${FILTERED_INDICES[$i]}"
            local N="${ASSET_NAMES[$IDX]}"
            local S="${ASSET_SIZES[$IDX]}"
            echo -e "  ${C_GREEN}[$((i+1))]${C_RESET} ${C_GOLD}►${C_RESET} ${C_WHITE}${N}${C_GRAY} (${S})${C_RESET}"
        done

        echo ""
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo -e "  ${C_GRAY}เลือก : ตัวเลข (1-${TOTAL}) · ช่วง (1-3) · all · 0=ถอย${C_RESET}"
        echo ""

        echo -ne "${CR}  ${C_YELLOW}● ${C_WHITE}เลือก: ${C_RESET}"
        read INPUT_CHOICE
        echo ""

        [ "$INPUT_CHOICE" == "0" ] && return 0

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
            print_banner
            local N_SEL=${#SELECTED[@]}
            echo -e "  ${C_GREEN}${C_BOLD}🚀 กำลังติดตั้ง ${N_SEL} รายการ${C_RESET}"
            echo -e "  ${C_SAPPHIRE}${C_DIV}${C_RESET}"
            echo ""

            for IDX_REL in "${SELECTED[@]}"; do
                local IDX_ABS="${FILTERED_INDICES[$IDX_REL]}"
                install_apk "${ASSET_NAMES[$IDX_ABS]}" \
                            "${ASSET_URLS[$IDX_ABS]}" \
                            "${ASSET_SIZES[$IDX_ABS]}"
            done

            echo ""
            echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
            echo -ne "  ${C_YELLOW}✨ กด Enter เพื่อกลับ...${C_RESET}"
            read
        else
            echo -e "  ${C_RED}[!] ไม่ถูกต้อง (เลือก 1-${TOTAL}, ช่วง, หรือ all)${C_RESET}"
            sleep 1.2
        fi
    done
}

main() {
    preflight
    check_main_password

    if ! fetch_release_assets; then
        echo ""
        echo -ne "  ${C_YELLOW}กด Enter เพื่อดำเนินการต่อ...${C_RESET}"
        read
    fi

    while true; do
        clear
        stty sane 2>/dev/null
        print_banner

        echo -e "  ${C_PINK}👑 Dev ${C_RESET}: ${C_WHITE}${OWNER_TAG}${C_RESET}"
        echo -e "  ${C_PINK}💬 Disc ${C_RESET}: ${C_WHITE}${DISCORD_LINK}${C_RESET}"
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo ""

        filter_by_category "Delta."
        local N_DELTA=${#FILTERED_INDICES[@]}
        filter_by_category "Delta.NoKey."
        local N_NOKEY=${#FILTERED_INDICES[@]}
        if [ "$N_NOKEY" -eq 0 ]; then
            filter_by_category "Delta_NoKey_"
            N_NOKEY=${#FILTERED_INDICES[@]}
        fi
        filter_by_category "Delta.Root."
        local N_ROOT=${#FILTERED_INDICES[@]}
        if [ "$N_ROOT" -eq 0 ]; then
            filter_by_category "Delta_Root_"
            N_ROOT=${#FILTERED_INDICES[@]}
        fi

        echo -e "  ${C_YELLOW}■ ${C_WHITE}${C_BOLD}หมวดหมู่สินค้า${C_RESET}"
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo -e "  ${C_GREEN}[1]${C_RESET} ${C_GOLD}►${C_RESET} ${C_WHITE}Delta${C_RESET}            ${C_GRAY}(${N_DELTA} ตัว)${C_RESET}"
        echo -e "  ${C_GREEN}[2]${C_RESET} ${C_GOLD}►${C_RESET} ${C_PINK}Delta No Key 💎${C_RESET}  ${C_GRAY}(${N_NOKEY} ตัว) ${C_YELLOW}[VIP]${C_RESET}"
        echo -e "  ${C_GREEN}[3]${C_RESET} ${C_GOLD}►${C_RESET} ${C_EMERALD}Delta ROOT 🔒${C_RESET}   ${C_GRAY}(${N_ROOT} ตัว) ${C_YELLOW}[root เท่านั้น]${C_RESET}"
        echo -e "  ${C_RED}   [0]${C_RESET} ${C_RED}►${C_RESET} ${C_RED}Exit${C_RESET}"
        echo ""
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo -e "  ${C_GRAY}เลือก : 0-3${C_RESET}"
        echo ""

        echo -ne "${CR}  ${C_YELLOW}● ${C_WHITE}เลือก: ${C_RESET}"
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
            3)
                if ! command -v su >/dev/null 2>&1 || ! su -c "true" >/dev/null 2>&1; then
                    echo -e "  ${C_RED}❌ หมวดนี้สำหรับเครื่อง ROOT เท่านั้น${C_RESET}"
                    echo -e "  ${C_GRAY}   (แอปที่ได้จะมีบัญชีฝังอยู่แล้ว ต้อง root ถึงติดตั้งได้)${C_RESET}"
                    sleep 2
                    continue
                fi
                local ROOT_PREFIX="Delta.Root."
                filter_by_category "$ROOT_PREFIX"
                if [ ${#FILTERED_INDICES[@]} -eq 0 ]; then
                    ROOT_PREFIX="Delta_Root_"
                fi
                process_category "Delta ROOT" "$ROOT_PREFIX"
                ;;
            0) break ;;
            *)
                echo -e "  ${C_RED}[!] ไม่ถูกต้อง (เลือก 0-3)${C_RESET}"
                sleep 1.2
                ;;
        esac
    done

    stty sane 2>/dev/null
    clear
    echo -e "${C_SAPPHIRE}${C_DIV}${C_RESET}"
    echo -e "  ${C_GREEN}${C_BOLD}✔ ขอบคุณที่ใช้ STAR SHOP! ✔${C_RESET}"
    echo -e "${C_SAPPHIRE}${C_DIV}${C_RESET}"
    echo ""
}

main "$@"
