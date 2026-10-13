#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  STAR SHOP AUTO-INSTALLER v2.0  —  UI refresh
#  Repo: nuxy1466-blip/STARPLUS
#  Run:  bash <(curl -sL https://raw.githubusercontent.com/nuxy1466-blip/STARPLUS/main/star_shop.sh)
# ============================================================

OWNER_TAG="STAR SHOP"
REPO_OWNER="nuxy1466-blip"
REPO_NAME="STARPLUS"
SCRIPT_VERSION="v2.0"
DISCORD_LINK="https://discord.gg/your-invite"
MAX_ATTEMPTS=3
MAIN_PASSWORD="STAR99"
VIP_PASSWORD="STARVVIP993"
RELEASE_TAG="${RELEASE_TAG:-V1.0}"
DECRYPT_KEY="STAR99"
DL_DIR="${DL_DIR:-/sdcard/Download}"

hash -r 2>/dev/null
stty sane 2>/dev/null

# ============================================================
#  THEME  (electric blue / silver)
# ============================================================
RST=$'\033[0m'
BOLD=$'\033[1m'
C_CYAN=$'\033[38;5;51m'
C_BLUE=$'\033[38;5;39m'
C_NAVY=$'\033[38;5;27m'
C_SILVER=$'\033[38;5;252m'
C_WHITE=$'\033[38;5;255m'
C_GRAY=$'\033[38;5;245m'
C_DARK=$'\033[38;5;238m'
C_GREEN=$'\033[38;5;84m'
C_RED=$'\033[38;5;203m'
C_YELLOW=$'\033[38;5;221m'
C_GOLD=$'\033[38;5;220m'
C_PINK=$'\033[38;5;212m'
C_PURPLE=$'\033[38;5;177m'

GRAD=(51 45 39 33 27 21)   # banner gradient: cyan -> deep blue

BANNER=(
"███████╗████████╗ █████╗ ██████╗ "
"██╔════╝╚══██╔══╝██╔══██╗██╔══██╗"
"███████╗   ██║   ███████║██████╔╝"
"╚════██║   ██║   ██╔══██║██╔══██╗"
"███████║   ██║   ██║  ██║██║  ██║"
"╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝"
)

# ============================================================
#  LAYOUT  (adapts to screen width)
# ============================================================
W=$(tput cols 2>/dev/null)
[[ "$W" =~ ^[0-9]+$ ]] || W=50
(( W > 60 )) && W=60
(( W < 38 )) && W=38
RW=$((W - 3))

mkrule() {
    local s="" i
    for ((i=0; i<$1; i++)); do s+="$2"; done
    printf '%s' "$s"
}
RULE_H=$(mkrule "$RW" "━")

cls()        { clear 2>/dev/null || printf '\033[2J\033[H'; }
cursor_off() { printf '\033[?25l'; }
cursor_on()  { printf '\033[?25h'; }

card_top()   { echo "  ${C_NAVY}┏${RULE_H}${RST}"; }
card_mid()   { echo "  ${C_NAVY}┣${RULE_H}${RST}"; }
card_bot()   { echo "  ${C_NAVY}┗${RULE_H}${RST}"; }
card_row()   { echo "  ${C_NAVY}┃${RST} $*"; }
card_blank() { echo "  ${C_NAVY}┃${RST}"; }
card_title() { card_top; card_row "${BOLD}${C_CYAN}$1${RST}"; card_mid; }

ok()   { card_row "${C_GREEN}✔${RST} $*"; }
fail() { card_row "${C_RED}✖${RST} $*"; }
warn() { card_row "${C_YELLOW}▲${RST} $*"; }
info() { card_row "${C_BLUE}◆${RST} $*"; }
dim()  { card_row "${C_GRAY}$*${RST}"; }

print_banner() {   # print_banner [mini]
    cls
    echo
    if [ "$1" == "mini" ]; then
        echo "  ${C_CYAN}⚡${RST} ${BOLD}${C_WHITE}STAR SHOP${RST} ${C_NAVY}┃${RST} ${C_GRAY}APK Installer${RST} ${C_BLUE}${SCRIPT_VERSION}${RST}"
        echo "  ${C_NAVY}━${RULE_H}${RST}"
        echo
        return
    fi
    local i=0 line
    for line in "${BANNER[@]}"; do
        printf '  \033[1;38;5;%sm%s\033[0m\n' "${GRAD[$i]}" "$line"
        i=$((i + 1))
    done
    echo "  ${C_SILVER}★${RST} ${C_BLUE}S H O P${RST} ${C_NAVY}·${RST} ${C_GRAY}APK INSTALLER${RST} ${C_NAVY}·${RST} ${C_BLUE}${SCRIPT_VERSION}${RST} ${C_SILVER}★${RST}"
    echo "  ${C_NAVY}━${RULE_H}${RST}"
    echo
}

# ============================================================
#  ANIMATION HELPERS
# ============================================================
SPIN_FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

spin_wait() {      # spin_wait <pid> <label>
    local pid=$1 label=$2 i=0
    cursor_off
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r\033[K  %s┃%s %s%s%s %s' "$C_NAVY" "$RST" "$C_CYAN" "${SPIN_FRAMES[i % 10]}" "$RST" "$label"
        i=$((i + 1))
        sleep 0.08
    done
    printf '\r\033[K'
    cursor_on
    wait "$pid"
}

run_spin() {       # run_spin <label> <command...>
    local label=$1
    shift
    "$@" >/dev/null 2>&1 &
    spin_wait $! "$label"
}

bar() {            # bar <percent> <suffix>
    local pct=$1 suffix=$2
    local bw=$((W - 25))
    (( bw < 10 )) && bw=10
    local filled=$(( pct * bw / 100 )) i f="" e=""
    for ((i=0; i<filled; i++)); do f+="█"; done
    for ((i=filled; i<bw; i++)); do e+="░"; done
    printf '\r\033[K  %s┃%s %s%s%s%s%s %s%3d%%%s %s%s%s' \
        "$C_NAVY" "$RST" "$C_BLUE" "$f" "$C_DARK" "$e" "$RST" \
        "$C_WHITE" "$pct" "$RST" "$C_GRAY" "$suffix" "$RST"
}

mb() { awk -v b="$1" 'BEGIN{printf "%.1f", b/1048576}'; }

# Masked password input: shows ● per key, supports backspace
read_secret() {    # read_secret <prompt>  ->  $SECRET
    local pw="" ch
    printf '%s' "$1"
    while IFS= read -rsn1 ch; do
        case "$ch" in
            "") break ;;
            $'\177'|$'\b')
                if [ -n "$pw" ]; then
                    pw="${pw%?}"
                    printf '\b \b'
                fi
                ;;
            *) pw+="$ch"; printf '%s●%s' "$C_BLUE" "$RST" ;;
        esac
    done
    echo
    SECRET=$(printf '%s' "$pw" | tr -d '[:space:]\r')
}

TMP_JSON="$(mktemp 2>/dev/null || echo "${TMPDIR:-/tmp}/.star_release.json")"
cleanup()  { rm -f "$TMP_JSON" 2>/dev/null; cursor_on; stty sane 2>/dev/null; }
on_int()   { kill $(jobs -p) 2>/dev/null; cleanup; echo; echo "  ${C_YELLOW}▲ ยกเลิกโดยผู้ใช้${RST}"; echo; exit 130; }
trap cleanup EXIT
trap on_int INT

# ============================================================
#  STARTUP
# ============================================================
preflight() {
    print_banner
    card_title "⚡ SYSTEM CHECK"

    local pkg_name
    for pkg_name in curl jq; do
        if command -v "$pkg_name" >/dev/null 2>&1; then
            ok "${C_WHITE}${pkg_name}${RST} ${C_GRAY}พร้อมใช้งาน${RST}"
        else
            run_spin "กำลังติดตั้ง ${pkg_name}..." pkg install "$pkg_name" -y
            if command -v "$pkg_name" >/dev/null 2>&1; then
                ok "${C_WHITE}${pkg_name}${RST} ${C_GRAY}ติดตั้งแล้ว${RST}"
            else
                fail "${C_WHITE}${pkg_name}${RST} ${C_RED}ติดตั้งไม่สำเร็จ${RST}"
                card_bot
                exit 1
            fi
        fi
    done

    if [ -d "$DL_DIR" ] && touch "$DL_DIR/.test_perm" 2>/dev/null; then
        ok "${C_WHITE}storage${RST} ${C_GRAY}พร้อมใช้งาน${RST}"
    else
        warn "${C_WHITE}storage${RST} ${C_YELLOW}ขอสิทธิ์ — กด 'Allow' บนหน้าจอ${RST}"
        termux-setup-storage
        sleep 3
        ok "${C_WHITE}storage${RST} ${C_GRAY}ตรวจสอบแล้ว${RST}"
    fi
    rm -f "$DL_DIR/.test_perm" 2>/dev/null

    card_bot
    echo
    echo "  ${C_GREEN}${BOLD}✔ ระบบพร้อมใช้งาน${RST}"
    sleep 0.8
}

get_device_info() {
    OS_VER=$(getprop ro.build.version.release 2>/dev/null || echo "?")
    ARCH=$(uname -m 2>/dev/null || echo "?")
}

password_gate() {  # password_gate <title> <expected> <accent-color>
    local title=$1 expected=$2 accent=$3
    local tries=0 left pips i p
    card_title "$title"
    dim "กรอกรหัสผ่านเพื่อเข้าใช้งาน"
    card_blank

    while (( tries < MAX_ATTEMPTS )); do
        left=$((MAX_ATTEMPTS - tries))
        pips=""
        for ((i=0; i<MAX_ATTEMPTS; i++)); do
            (( i < left )) && pips+="▰" || pips+="▱"
        done
        read_secret "  ${C_NAVY}┃${RST} 🔑 ${accent}${pips}${RST} ${C_BLUE}❯${RST} "

        if [ "$SECRET" == "$expected" ]; then
            p=0
            cursor_off
            while (( p <= 100 )); do
                bar "$p" "UNLOCKING"
                p=$((p + 10))
                sleep 0.03
            done
            cursor_on
            printf '\r\033[K'
            ok "${C_GREEN}${BOLD}ACCESS GRANTED${RST}"
            return 0
        fi

        tries=$((tries + 1))
        fail "${C_RED}รหัสผ่านผิด${RST} ${C_GRAY}· เหลือ $((MAX_ATTEMPTS - tries)) ครั้ง${RST}"
        sleep 0.6
    done
    return 1
}

check_main_password() {
    print_banner
    if password_gate "🔒 MEMBER GATE" "$MAIN_PASSWORD" "$C_YELLOW"; then
        ok "${C_WHITE}ยินดีต้อนรับสู่ STAR SHOP${RST}"
        card_bot
        sleep 1
        get_device_info
        return 0
    fi
    card_bot
    echo
    echo "  ${C_RED}${BOLD}🚫 กรอกผิดเกินกำหนด · ล็อคชั่วคราว${RST}"
    echo
    exit 1
}

check_vip_password() {
    print_banner mini
    if password_gate "💎 VIP ACCESS · ยืนยันตัวตนเพิ่มเติม" "$VIP_PASSWORD" "$C_GOLD"; then
        ok "${C_GOLD}${BOLD}VIP ACCESS GRANTED${RST}"
        card_bot
        sleep 0.8
        return 0
    fi
    card_bot
    echo
    echo "  ${C_RED}🚫 VIP access denied · กลับไปเมนูหลัก...${RST}"
    sleep 1.5
    return 1
}

# ============================================================
#  CATALOG
# ============================================================
fetch_release_assets() {
    ASSET_NAMES=()
    ASSET_URLS=()
    ASSET_SIZES=()
    ASSET_BYTES=()

    local API_URL
    if [ "$RELEASE_TAG" == "latest" ]; then
        API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    else
        API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${RELEASE_TAG}"
    fi

    print_banner mini
    card_title "📡 CATALOG"

    curl -sL -H "Accept: application/vnd.github+json" "$API_URL" -o "$TMP_JSON" 2>/dev/null &
    spin_wait $! "กำลังโหลดรายการจาก GitHub..."

    local RESPONSE
    RESPONSE=$(cat "$TMP_JSON" 2>/dev/null)

    if [ -z "$RESPONSE" ]; then
        fail "${C_RED}เชื่อมต่อ GitHub API ไม่ได้${RST}"
        card_bot
        return 1
    fi

    local ERR_MSG
    ERR_MSG=$(echo "$RESPONSE" | jq -r '.message // empty' 2>/dev/null)
    if [ -n "$ERR_MSG" ] && [ "$ERR_MSG" != "null" ]; then
        fail "${C_RED}GitHub: ${ERR_MSG}${RST}"
        if [ "$ERR_MSG" == "Not Found" ]; then
            card_blank
            warn "${C_YELLOW}วิธีแก้${RST}"
            dim "1. ไปที่ github.com/${REPO_OWNER}/${REPO_NAME}/releases/new"
            dim "2. ตั้ง tag: ${RELEASE_TAG} (ตัวใหญ่!)"
            dim "3. อัปไฟล์ APK (Delta.1.apk, Delta.NoKey.1.apk, ...)"
            dim "4. กด Publish release (ไม่ใช่ draft)"
            dim "5. รันสคริปต์ใหม่"
            dim "แนะนำ: ถ้าใช้ tag 'v1.0' ให้แก้ RELEASE_TAG ในสคริปต์"
        fi
        card_bot
        return 1
    fi

    local COUNT
    COUNT=$(echo "$RESPONSE" | jq -r '.assets | length' 2>/dev/null)
    if [ -z "$COUNT" ] || [ "$COUNT" == "null" ] || [ "$COUNT" -eq 0 ] 2>/dev/null; then
        warn "${C_YELLOW}Release '${RELEASE_TAG}' ยังไม่มี APK${RST}"
        dim "อัปได้: github.com/${REPO_OWNER}/${REPO_NAME}/releases"
        card_bot
        return 1
    fi

    local NAME URL SZ
    while IFS=$'\t' read -r NAME URL SZ; do
        [[ "$SZ" =~ ^[0-9]+$ ]] || SZ=0
        ASSET_NAMES+=("$NAME")
        ASSET_URLS+=("$URL")
        ASSET_BYTES+=("$SZ")
        if (( SZ > 0 )); then
            ASSET_SIZES+=("$(mb "$SZ") MB")
        else
            ASSET_SIZES+=("?")
        fi
    done < <(echo "$RESPONSE" | jq -r '.assets[] | [.name, .browser_download_url, (.size | tostring)] | @tsv' 2>/dev/null)

    ok "${C_WHITE}พบ ${#ASSET_NAMES[@]} APK${RST} ${C_GRAY}ใน release '${RELEASE_TAG}'${RST}"
    card_bot
    sleep 0.6
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

# ============================================================
#  INSTALL
# ============================================================
open_installer() {
    termux-open --content-type "application/vnd.android.package-archive" "$1"
    stty sane 2>/dev/null
}

install_apk() {    # install_apk <name> <url> <size-label> <bytes> <pos> <total>
    local NAME="$1" URL="$2" SIZE="$3" BYTES="$4" POS="$5" TOTAL="$6"
    local TEMP_ENC="$DL_DIR/starshop_temp.enc"
    local TEMP_APK="$DL_DIR/starshop_temp.apk"
    [[ "$BYTES" =~ ^[0-9]+$ ]] || BYTES=0

    rm -f "$TEMP_ENC" "$TEMP_APK"

    local IS_ENC=0 DL_TARGET="$TEMP_APK"
    case "$NAME" in
        *.enc|*.ENC) IS_ENC=1; DL_TARGET="$TEMP_ENC" ;;
    esac

    card_row "${BOLD}${C_BLUE}[${POS}/${TOTAL}]${RST} ${C_WHITE}${NAME}${RST} ${C_GRAY}(${SIZE})${RST}"

    # --- download with live progress ---
    cursor_off
    curl -sL --fail -A "Mozilla/5.0" "$URL" -o "$DL_TARGET" &
    local PID=$! cur pct i=0 total_mb=""
    (( BYTES > 0 )) && total_mb=$(mb "$BYTES")
    while kill -0 "$PID" 2>/dev/null; do
        cur=$(stat -c %s "$DL_TARGET" 2>/dev/null || echo 0)
        if (( BYTES > 0 )); then
            pct=$(( cur * 100 / BYTES ))
            (( pct > 99 )) && pct=99
            bar "$pct" "$(mb "$cur")/${total_mb} MB"
        else
            printf '\r\033[K  %s┃%s %s%s%s %s MB' "$C_NAVY" "$RST" "$C_CYAN" "${SPIN_FRAMES[i % 10]}" "$RST" "$(mb "$cur")"
            i=$((i + 1))
        fi
        sleep 0.2
    done
    wait "$PID"
    local DL_STATUS=$?
    cursor_on
    printf '\r\033[K'

    if [ $DL_STATUS -ne 0 ] || [ ! -f "$DL_TARGET" ]; then
        fail "${C_RED}ดาวน์โหลดล้มเหลว (curl: ${DL_STATUS})${RST}"
        rm -f "$TEMP_ENC" "$TEMP_APK"
        return 1
    fi

    local FILE_SIZE_KB
    FILE_SIZE_KB=$(du -k "$DL_TARGET" | awk '{print $1}')
    if [ "$FILE_SIZE_KB" -le 1024 ]; then
        fail "${C_RED}ไฟล์เล็กผิดปกติ (${FILE_SIZE_KB}KB)${RST}"
        rm -f "$TEMP_ENC" "$TEMP_APK"
        return 1
    fi
    ok "${C_WHITE}ดาวน์โหลดเสร็จ${RST} ${C_GRAY}$(mb $((FILE_SIZE_KB * 1024))) MB${RST}"

    # --- decrypt (.enc only) ---
    if [ $IS_ENC -eq 1 ]; then
        if ! command -v openssl >/dev/null 2>&1; then
            run_spin "กำลังติดตั้ง openssl (~30-60s)..." pkg install openssl-tool -y
            if ! command -v openssl >/dev/null 2>&1; then
                fail "${C_RED}ติดตั้ง openssl ไม่สำเร็จ${RST}"
                rm -f "$TEMP_ENC" "$TEMP_APK"
                return 1
            fi
        fi
        if ! run_spin "🔓 กำลังถอดรหัส..." openssl enc -d -aes-256-cbc -pbkdf2 \
                -in "$TEMP_ENC" -out "$TEMP_APK" -pass "pass:$DECRYPT_KEY"; then
            fail "${C_RED}ถอดรหัสล้มเหลว${RST}"
            rm -f "$TEMP_ENC" "$TEMP_APK"
            return 1
        fi
        ok "${C_WHITE}ถอดรหัสแล้ว${RST}"
        rm -f "$TEMP_ENC"
    fi

    chmod 644 "$TEMP_APK" 2>/dev/null

    # --- install ---
    if command -v su >/dev/null 2>&1 && su -c "true" >/dev/null 2>&1; then
        info "${C_GRAY}กำลังติดตั้งผ่าน root...${RST}"
        su -c "pm install -r \"$TEMP_APK\"" >/dev/null 2>&1
        local PM_STATUS=$?
        stty sane 2>/dev/null
        if [ $PM_STATUS -eq 0 ]; then
            ok "${C_GREEN}${BOLD}ติดตั้งเรียบร้อย${RST} ${C_GRAY}(root)${RST}"
        else
            warn "${C_YELLOW}root ติดตั้งไม่สำเร็จ · เปิดตัวติดตั้งปกติ${RST}"
            open_installer "$TEMP_APK"
        fi
    else
        open_installer "$TEMP_APK"
        ok "${C_GREEN}เปิดตัวติดตั้งแล้ว${RST} ${C_GRAY}· กด 'Install' บนหน้าจอ${RST}"
        # wait for the user before the next APK overwrites the temp file
        if (( POS < TOTAL )); then
            printf '  %s┃%s %s⏎ ติดตั้งเสร็จแล้วกด Enter เพื่อไปตัวถัดไป%s' "$C_NAVY" "$RST" "$C_YELLOW" "$RST"
            read -r
            printf '\r\033[K'
        fi
    fi
    return 0
}

menu_row() {       # menu_row <key> <label> <count> [badge]
    card_row "$(printf '%s[%s]%s %s%-16s%s %s%2s APK%s %s' \
        "$C_GREEN" "$1" "$RST" "$C_WHITE" "$2" "$RST" "$C_GRAY" "$3" "$RST" "$4")"
}

process_category() {
    local CATEGORY_LABEL="$1"
    local CATEGORY_PREFIX="$2"

    filter_by_category "$CATEGORY_PREFIX"
    local TOTAL=${#FILTERED_INDICES[@]}

    if [ "$TOTAL" -eq 0 ]; then
        print_banner mini
        card_title "📂 ${CATEGORY_LABEL}"
        warn "${C_YELLOW}หมวดนี้ยังไม่มี APK${RST}"
        dim "ชื่อไฟล์ต้องขึ้นต้นด้วย: ${CATEGORY_PREFIX}"
        dim "อัปได้: github.com/${REPO_OWNER}/${REPO_NAME}/releases"
        card_bot
        echo
        printf '  %s⏎ กด Enter เพื่อกลับ%s ' "$C_YELLOW" "$RST"
        read -r
        return 0
    fi

    local nw=$((W - 22))
    (( nw < 12 )) && nw=12

    while true; do
        stty sane 2>/dev/null
        print_banner mini
        card_title "📂 ${CATEGORY_LABEL}  ${C_GRAY}(${TOTAL} APK)${RST}"

        local i
        for i in "${!FILTERED_INDICES[@]}"; do
            local IDX="${FILTERED_INDICES[$i]}"
            local N="${ASSET_NAMES[$IDX]}"
            local S="${ASSET_SIZES[$IDX]}"
            local disp="$N"
            (( ${#disp} > nw )) && disp="${disp:0:nw-1}…"
            card_row "$(printf '%s[%2d]%s %s%-*s%s %s%8s%s' \
                "$C_GREEN" "$((i + 1))" "$RST" "$C_WHITE" "$nw" "$disp" "$RST" "$C_GRAY" "$S" "$RST")"
        done

        card_mid
        dim "เลือก: เลข (2) · หลายตัว (1 3) · ช่วง (1-3)"
        dim "all = ทั้งหมด · 0 = ย้อนกลับ"
        card_bot
        echo
        printf '  %s❯%s ' "$C_BLUE" "$RST"
        read -r INPUT_CHOICE
        INPUT_CHOICE=${INPUT_CHOICE//,/ }

        [ "$INPUT_CHOICE" == "0" ] && return 0

        local SELECTED=()
        local VALID_INPUT=0

        if [ "$INPUT_CHOICE" == "all" ] || [ "$INPUT_CHOICE" == "ALL" ]; then
            for i in "${!FILTERED_INDICES[@]}"; do
                SELECTED+=($i)
            done
            VALID_INPUT=1
        else
            local ITEM
            for ITEM in $INPUT_CHOICE; do
                if [[ "$ITEM" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                    local START=${BASH_REMATCH[1]}
                    local END=${BASH_REMATCH[2]}
                    if [ "$START" -gt "$END" ]; then
                        local T=$START; START=$END; END=$T
                    fi
                    local j
                    for ((j=START; j<=END; j++)); do
                        if [ $((j - 1)) -ge 0 ] && [ $((j - 1)) -lt "$TOTAL" ]; then
                            SELECTED+=($((j - 1)))
                            VALID_INPUT=1
                        fi
                    done
                elif [[ "$ITEM" =~ ^[0-9]+$ ]]; then
                    if [ $((ITEM - 1)) -ge 0 ] && [ $((ITEM - 1)) -lt "$TOTAL" ]; then
                        SELECTED+=($((ITEM - 1)))
                        VALID_INPUT=1
                    fi
                fi
            done
        fi

        if [ $VALID_INPUT -eq 1 ]; then
            stty sane 2>/dev/null
            print_banner mini
            local N_SEL=${#SELECTED[@]}
            card_title "🚀 INSTALL QUEUE  ${C_GRAY}(${N_SEL} APK)${RST}"

            local OK_COUNT=0 FAIL_COUNT=0 POS=0 IDX_REL IDX_ABS
            for IDX_REL in "${SELECTED[@]}"; do
                POS=$((POS + 1))
                IDX_ABS="${FILTERED_INDICES[$IDX_REL]}"
                if install_apk "${ASSET_NAMES[$IDX_ABS]}" "${ASSET_URLS[$IDX_ABS]}" \
                               "${ASSET_SIZES[$IDX_ABS]}" "${ASSET_BYTES[$IDX_ABS]}" \
                               "$POS" "$N_SEL"; then
                    OK_COUNT=$((OK_COUNT + 1))
                else
                    FAIL_COUNT=$((FAIL_COUNT + 1))
                fi
                (( POS < N_SEL )) && card_blank
            done

            card_mid
            card_row "${C_GREEN}✔ สำเร็จ ${OK_COUNT}${RST}   ${C_RED}✖ ล้มเหลว ${FAIL_COUNT}${RST}"
            card_bot
            echo
            printf '  %s⏎ กด Enter เพื่อกลับ%s ' "$C_YELLOW" "$RST"
            read -r
        else
            echo
            echo "  ${C_RED}✖ ไม่ถูกต้อง${RST} ${C_GRAY}(เลือก 1-${TOTAL}, ช่วง, หรือ all)${RST}"
            sleep 1.2
        fi
    done
}

# ============================================================
#  MAIN
# ============================================================
show_home() {
    print_banner mini
    card_top
    card_row "${C_PINK}👑 Dev${RST}      ${C_WHITE}${OWNER_TAG}${RST}"
    card_row "${C_PURPLE}💬 Discord${RST}  ${C_WHITE}${DISCORD_LINK}${RST}"
    card_row "${C_BLUE}📦 Release${RST}  ${C_WHITE}${RELEASE_TAG}${RST} ${C_GRAY}· ${#ASSET_NAMES[@]} APK${RST}"
    card_row "${C_GREEN}📱 Device${RST}   ${C_WHITE}Android ${OS_VER}${RST} ${C_GRAY}· ${ARCH}${RST}"
    card_bot
    echo

    filter_by_category "Delta."
    N_DELTA=${#FILTERED_INDICES[@]}
    filter_by_category "Delta.NoKey."
    N_NOKEY=${#FILTERED_INDICES[@]}
    if [ "$N_NOKEY" -eq 0 ]; then
        filter_by_category "Delta_NoKey_"
        N_NOKEY=${#FILTERED_INDICES[@]}
    fi

    card_title "⚡ เลือกหมวดหมู่"
    menu_row 1 "Delta" "$N_DELTA" ""
    menu_row 2 "Delta No Key" "$N_NOKEY" "${C_GOLD}VIP 💎${RST}"
    card_blank
    card_row "${C_RED}[0]${RST} ${C_RED}Exit${RST}"
    card_bot
    echo
    printf '  %s❯%s ' "$C_BLUE" "$RST"
}

goodbye() {
    stty sane 2>/dev/null
    cls
    echo
    local i=0 line
    for line in "${BANNER[@]}"; do
        printf '  \033[1;38;5;%sm%s\033[0m\n' "${GRAD[$i]}" "$line"
        i=$((i + 1))
    done
    echo
    echo "  ${C_GREEN}${BOLD}✔ ขอบคุณที่ใช้ STAR SHOP${RST}"
    echo "  ${C_GRAY}Discord: ${DISCORD_LINK}${RST}"
    echo
}

main() {
    preflight
    check_main_password

    if ! fetch_release_assets; then
        echo
        printf '  %s⏎ กด Enter เพื่อดำเนินการต่อ%s ' "$C_YELLOW" "$RST"
        read -r
    fi

    while true; do
        stty sane 2>/dev/null
        show_home
        read -r MAIN_CHOICE

        case "$MAIN_CHOICE" in
            1) process_category "Delta" "Delta." ;;
            2)
                if check_vip_password; then
                    local NOKEY_PREFIX="Delta.NoKey."
                    filter_by_category "$NOKEY_PREFIX"
                    if [ ${#FILTERED_INDICES[@]} -eq 0 ]; then
                        NOKEY_PREFIX="Delta_NoKey_"
                    fi
                    process_category "Delta No Key 💎" "$NOKEY_PREFIX"
                fi
                ;;
            0) break ;;
            *)
                echo
                echo "  ${C_RED}✖ ไม่ถูกต้อง${RST} ${C_GRAY}(เลือก 0-2)${RST}"
                sleep 1.2
                ;;
        esac
    done

    goodbye
}

main "$@"
