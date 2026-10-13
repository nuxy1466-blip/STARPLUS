#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# STAR SHOP AUTO-INSTALLER v2.0 - STAR PREMIUM UI
# Repo: nuxy1466-blip/STARPLUS
# ============================================================

set -o pipefail

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

# ---------- COLORS ----------
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[38;5;203m'
C_GREEN='\033[38;5;114m'
C_YELLOW='\033[38;5;221m'
C_BLUE='\033[38;5;75m'
C_PURPLE='\033[38;5;177m'
C_CYAN='\033[38;5;81m'
C_WHITE='\033[38;5;255m'
C_GRAY='\033[38;5;245m'
C_PINK='\033[38;5;212m'
C_GOLD='\033[38;5;220m'
C_SAPPHIRE='\033[1;38;5;33m'
CR=$'\r\033[K'

ASSET_NAMES=()
ASSET_URLS=()
ASSET_SIZES=()
FILTERED_INDICES=()

hash -r 2>/dev/null
stty sane 2>/dev/null || true

pause_enter() {
    echo
    read -r -p "  กด Enter เพื่อดำเนินการต่อ..." _
}

draw_progress() {
    local pct="${1:-0}" label="${2:-working}"
    local width=28 filled empty bar="" i
    (( pct < 0 )) && pct=0
    (( pct > 100 )) && pct=100
    filled=$((pct * width / 100))
    empty=$((width - filled))
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    printf "\r  ${C_CYAN}%s${C_RESET} ${C_WHITE}%3d%%${C_RESET} ${C_GRAY}%s${C_RESET}\033[K" "$bar" "$pct" "$label"
}

print_banner() {
    clear 2>/dev/null || true
    echo -e "${C_SAPPHIRE}╔════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}                                                    ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}  ${C_CYAN}${C_BOLD}███████╗${C_WHITE} ████████╗ ${C_CYAN}██████╗ ${C_WHITE} ██████╗${C_RESET}      ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}  ${C_CYAN}${C_BOLD}██╔════╝${C_WHITE} ╚══██╔══╝ ${C_CYAN}██╔══██╗${C_WHITE}██╔═══██╗${C_RESET}     ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}  ${C_CYAN}${C_BOLD}███████╗${C_WHITE}    ██║    ${C_CYAN}██████╔╝${C_WHITE}██║   ██║${C_RESET}     ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}  ${C_CYAN}${C_BOLD}╚════██║${C_WHITE}    ██║    ${C_CYAN}██╔══██╗${C_WHITE}██║   ██║${C_RESET}     ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}  ${C_CYAN}${C_BOLD}███████║${C_WHITE}    ██║    ${C_CYAN}██║  ██║${C_WHITE}╚██████╔╝${C_RESET}     ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}  ${C_CYAN}${C_BOLD}╚══════╝${C_WHITE}    ╚═╝    ${C_CYAN}╚═╝  ╚═╝${C_WHITE} ╚═════╝${C_RESET}      ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}                                                    ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}          ${C_WHITE}${C_BOLD}S T A R   P R E M I U M${C_RESET}             ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}          ${C_CYAN}APK AUTO INSTALLER${C_RESET}                    ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}          ${C_GRAY}VERSION ${SCRIPT_VERSION}${C_RESET}                         ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}║${C_RESET}                                                    ${C_SAPPHIRE}║${C_RESET}"
    echo -e "${C_SAPPHIRE}╚════════════════════════════════════════════════════╝${C_RESET}"
    echo
}

preflight() {
    print_banner
    echo -e "  ${C_WHITE}${C_BOLD}SYSTEM CHECK / เตรียมระบบ${C_RESET}"
    echo
    if ! command -v pkg >/dev/null 2>&1; then
        echo -e "  ${C_RED}ต้องรันสคริปต์นี้ใน Termux เท่านั้น${C_RESET}"
        exit 1
    fi
    for dep in curl jq; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo -e "  ${C_YELLOW}กำลังติดตั้ง $dep...${C_RESET}"
            pkg install "$dep" -y || {
                echo -e "  ${C_RED}ติดตั้ง $dep ไม่สำเร็จ${C_RESET}"
                exit 1
            }
        fi
    done
    if [ ! -d "$HOME/storage/shared" ]; then
        echo -e "  ${C_YELLOW}กำลังขอสิทธิ์เข้าถึงพื้นที่เก็บข้อมูล${C_RESET}"
        termux-setup-storage
        sleep 2
    fi
    mkdir -p "$HOME/storage/shared/Download" 2>/dev/null || true
    draw_progress 100 "ระบบพร้อมใช้งาน"
    echo
    sleep 0.4
}

get_device_info() {
    OS_VER="$(getprop ro.build.version.release 2>/dev/null || echo '?')"
    ARCH="$(uname -m 2>/dev/null || echo '?')"
}

check_main_password() {
    local attempts=0 user_pass
    while (( attempts < MAX_ATTEMPTS )); do
        print_banner
        echo -e "  ${C_CYAN}╭──────────── MEMBER ACCESS ────────────╮${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}  ${C_WHITE}กรุณากรอกรหัสผ่านเพื่อเข้าใช้งาน${C_RESET}   ${C_CYAN}│${C_RESET}"
        echo -e "  ${C_CYAN}╰─────────────────────────────────────╯${C_RESET}"
        echo
        printf "%b" "  ${C_YELLOW}PASSWORD > ${C_RESET}"
        read -r -s user_pass
        echo
        user_pass="$(printf '%s' "$user_pass" | tr -d '[:space:]' | tr -d '\r')"
        if [ "$user_pass" = "$MAIN_PASSWORD" ]; then
            draw_progress 100 "ACCESS GRANTED"
            echo
            echo -e "  ${C_GREEN}ยืนยันตัวตนสำเร็จ ยินดีต้อนรับสู่ STAR${C_RESET}"
            sleep 0.6
            get_device_info
            return 0
        fi
        attempts=$((attempts + 1))
        echo -e "  ${C_RED}รหัสผ่านไม่ถูกต้อง เหลือ $((MAX_ATTEMPTS-attempts)) ครั้ง${C_RESET}"
        sleep 0.8
    done
    echo -e "  ${C_RED}กรอกรหัสผิดเกินกำหนด ออกจากโปรแกรม${C_RESET}"
    exit 1
}

check_vip_password() {
    local attempts=0 vip_pass
    while (( attempts < MAX_ATTEMPTS )); do
        echo
        echo -e "  ${C_PURPLE}${C_BOLD}VIP ACCESS VERIFICATION${C_RESET}"
        printf "%b" "  ${C_PURPLE}VIP PASSWORD > ${C_RESET}"
        read -r -s vip_pass
        echo
        vip_pass="$(printf '%s' "$vip_pass" | tr -d '[:space:]' | tr -d '\r')"
        if [ "$vip_pass" = "$VIP_PASSWORD" ]; then
            draw_progress 100 "VIP ACCESS GRANTED"
            echo
            return 0
        fi
        attempts=$((attempts + 1))
        echo -e "  ${C_RED}รหัส VIP ไม่ถูกต้อง เหลือ $((MAX_ATTEMPTS-attempts)) ครั้ง${C_RESET}"
    done
    echo -e "  ${C_RED}VIP access denied${C_RESET}"
    sleep 1
    return 1
}

fetch_release_assets() {
    ASSET_NAMES=()
    ASSET_URLS=()
    ASSET_SIZES=()
    local api_url response err_msg count i name url size_bytes size_hr
    if [ "$RELEASE_TAG" = "latest" ]; then
        api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    else
        api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${RELEASE_TAG}"
    fi

    echo -e "  ${C_CYAN}กำลังโหลดรายการไฟล์จาก GitHub...${C_RESET}"
    response="$(curl -fsSL --connect-timeout 15 -H "Accept: application/vnd.github+json" "$api_url" 2>/dev/null)" || {
        echo -e "  ${C_RED}เชื่อมต่อ GitHub ไม่สำเร็จ${C_RESET}"
        return 1
    }
    err_msg="$(printf '%s' "$response" | jq -r '.message // empty' 2>/dev/null)"
    if [ -n "$err_msg" ]; then
        echo -e "  ${C_RED}GitHub: $err_msg${C_RESET}"
        echo -e "  ${C_GRAY}ตรวจสอบ RELEASE_TAG และหน้า Releases ของ repository${C_RESET}"
        return 1
    fi
    count="$(printf '%s' "$response" | jq -r '.assets | length' 2>/dev/null)"
    if ! [[ "$count" =~ ^[0-9]+$ ]] || (( count == 0 )); then
        echo -e "  ${C_YELLOW}Release '$RELEASE_TAG' ยังไม่มีไฟล์แนบ${C_RESET}"
        return 1
    fi

    for ((i=0; i<count; i++)); do
        name="$(printf '%s' "$response" | jq -r ".assets[$i].name")"
        url="$(printf '%s' "$response" | jq -r ".assets[$i].browser_download_url")"
        size_bytes="$(printf '%s' "$response" | jq -r ".assets[$i].size")"
        size_hr="$(awk -v n="$size_bytes" 'BEGIN {printf "%.1f MB", n/1048576}')"
        ASSET_NAMES+=("$name")
        ASSET_URLS+=("$url")
        ASSET_SIZES+=("$size_hr")
    done
    echo -e "  ${C_GREEN}พบไฟล์ ${#ASSET_NAMES[@]} รายการใน release '$RELEASE_TAG'${C_RESET}"
    return 0
}

filter_by_category() {
    local prefix="$1" i name
    FILTERED_INDICES=()
    for i in "${!ASSET_NAMES[@]}"; do
        name="${ASSET_NAMES[$i]}"
        case "$name" in
            "$prefix"*)
                if [[ "$name" == Delta.NoKey.* && "$prefix" != "Delta.NoKey." ]]; then
                    continue
                fi
                if [[ "$name" == Delta_NoKey_* && "$prefix" != "Delta_NoKey_"* ]]; then
                    continue
                fi
                FILTERED_INDICES+=("$i")
                ;;
        esac
    done
}

install_apk() {
    local name="$1" url="$2" size="$3"
    local download_dir="$HOME/storage/shared/Download"
    local temp_enc="$download_dir/starshop_temp.enc"
    local temp_apk="$download_dir/starshop_temp.apk"
    local target="$temp_apk" is_enc=0 status file_kb short_url
    mkdir -p "$download_dir"
    rm -f "$temp_enc" "$temp_apk"

    case "$name" in
        *.enc|*.ENC) is_enc=1; target="$temp_enc" ;;
    esac
    short_url="$(printf '%s' "$url" | sed 's|https://||; s|/[^/]*$|/...|')"
    echo -e "  ${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "  ${C_WHITE}FILE${C_RESET}  ${C_GREEN}$name${C_RESET}"
    echo -e "  ${C_GRAY}SIZE: $size  |  SOURCE: $short_url${C_RESET}"
    echo -e "  ${C_YELLOW}กำลังดาวน์โหลด...${C_RESET}"

    if ! curl -fL --retry 2 --connect-timeout 20 -A "Mozilla/5.0" "$url" -o "$target"; then
        echo -e "  ${C_RED}ดาวน์โหลดไม่สำเร็จ${C_RESET}"
        rm -f "$temp_enc" "$temp_apk"
        return 1
    fi
    file_kb="$(du -k "$target" 2>/dev/null | awk '{print $1}')"
    if ! [[ "$file_kb" =~ ^[0-9]+$ ]] || (( file_kb <= 1 )); then
        echo -e "  ${C_RED}ไฟล์ว่างหรือมีขนาดไม่ถูกต้อง${C_RESET}"
        rm -f "$temp_enc" "$temp_apk"
        return 1
    fi

    if (( is_enc )); then
        if ! command -v openssl >/dev/null 2>&1; then
            pkg install openssl-tool -y || {
                echo -e "  ${C_RED}ติดตั้ง openssl ไม่สำเร็จ${C_RESET}"
                rm -f "$temp_enc"
                return 1
            }
        fi
        echo -e "  ${C_PURPLE}กำลังถอดรหัสไฟล์...${C_RESET}"
        if ! openssl enc -d -aes-256-cbc -pbkdf2 -in "$temp_enc" -out "$temp_apk" -pass "pass:$DECRYPT_KEY" 2>/dev/null; then
            echo -e "  ${C_RED}ถอดรหัสไม่สำเร็จ ตรวจสอบ key/ไฟล์ enc${C_RESET}"
            rm -f "$temp_enc" "$temp_apk"
            return 1
        fi
        rm -f "$temp_enc"
    fi

    if ! command -v termux-open >/dev/null 2>&1; then
        echo -e "  ${C_RED}ไม่พบ termux-open กรุณาติดตั้ง Termux:API${C_RESET}"
        echo -e "  ${C_YELLOW}ไฟล์อยู่ที่: $temp_apk${C_RESET}"
        return 1
    fi

    chmod 644 "$temp_apk" 2>/dev/null || true
    echo -e "  ${C_GREEN}ดาวน์โหลดเสร็จ กำลังเปิดหน้าติดตั้ง Android...${C_RESET}"
    termux-open --content-type "application/vnd.android.package-archive" "$temp_apk"
    status=$?
    if (( status == 0 )); then
        echo -e "  ${C_GREEN}เปิดตัวติดตั้งแล้ว ให้กดยืนยัน Install บนหน้าจอ${C_RESET}"
    else
        echo -e "  ${C_YELLOW}เปิดอัตโนมัติไม่สำเร็จ ไฟล์อยู่ที่ $temp_apk${C_RESET}"
    fi
}

process_category() {
    local label="$1" prefix="$2" total i idx name size input item valid start end tmp j
    filter_by_category "$prefix"
    total="${#FILTERED_INDICES[@]}"
    if (( total == 0 )); then
        echo
        echo -e "  ${C_YELLOW}หมวด '$label' ยังไม่มีไฟล์${C_RESET}"
        echo -e "  ${C_GRAY}ตรวจสอบชื่อไฟล์ใน GitHub Releases${C_RESET}"
        pause_enter
        return
    fi

    while true; do
        print_banner
        echo -e "  ${C_CYAN}╭──────────── ${label^^} ────────────╮${C_RESET}"
        echo -e "  ${C_GRAY}พบ $total รายการ | เลือกเลข, ช่วง 1-3, all หรือ 0 กลับ${C_RESET}"
        echo -e "  ${C_CYAN}╰──────────────────────────────────────────────╯${C_RESET}"
        echo
        for i in "${!FILTERED_INDICES[@]}"; do
            idx="${FILTERED_INDICES[$i]}"
            name="${ASSET_NAMES[$idx]}"
            size="${ASSET_SIZES[$idx]}"
            printf "  ${C_GREEN}[%02d]${C_RESET} ${C_WHITE}%s${C_RESET} ${C_GRAY}(%s)${C_RESET}\n" "$((i+1))" "$name" "$size"
        done
        echo
        read -r -p "  ${C_CYAN}STAR » เลือกไฟล์: ${C_RESET}" input
        [[ "$input" == "0" ]] && return
        local selected=()
        valid=0
        if [[ "$input" == "all" || "$input" == "ALL" ]]; then
            for i in "${!FILTERED_INDICES[@]}"; do selected+=("$i"); done
            valid=1
        else
            for item in $input; do
                if [[ "$item" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                    start="${BASH_REMATCH[1]}"; end="${BASH_REMATCH[2]}"
                    if (( start > end )); then tmp="$start"; start="$end"; end="$tmp"; fi
                    for ((j=start; j<=end; j++)); do
                        if (( j >= 1 && j <= total )); then selected+=("$((j-1))"); valid=1; fi
                    done
                elif [[ "$item" =~ ^[0-9]+$ ]] && (( item >= 1 && item <= total )); then
                    selected+=("$((item-1))"); valid=1
                fi
            done
        fi
        if (( ! valid )); then
            echo -e "  ${C_RED}ตัวเลือกไม่ถูกต้อง${C_RESET}"
            sleep 1
            continue
        fi
        print_banner
        echo -e "  ${C_GREEN}${C_BOLD}กำลังประมวลผล ${#selected[@]} รายการ${C_RESET}"
        for i in "${selected[@]}"; do
            idx="${FILTERED_INDICES[$i]}"
            install_apk "${ASSET_NAMES[$idx]}" "${ASSET_URLS[$idx]}" "${ASSET_SIZES[$idx]}"
        done
        pause_enter
    done
}

main() {
    preflight
    check_main_password
    if ! fetch_release_assets; then
        pause_enter
    fi

    while true; do
        print_banner
        filter_by_category "Delta."
        local n_delta="${#FILTERED_INDICES[@]}"
        filter_by_category "Delta.NoKey."
        local n_nokey="${#FILTERED_INDICES[@]}"
        if (( n_nokey == 0 )); then
            filter_by_category "Delta_NoKey_"
            n_nokey="${#FILTERED_INDICES[@]}"
        fi

        echo -e "  ${C_CYAN}╭──────────── STAR CONTROL PANEL ────────────╮${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}  ${C_WHITE}OWNER   : ${C_GOLD}${OWNER_TAG}${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}  ${C_WHITE}VERSION : ${C_GREEN}${SCRIPT_VERSION}${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}  ${C_WHITE}ANDROID : ${C_GRAY}${OS_VER:-?} / ${ARCH:-?}${C_RESET}"
        echo -e "  ${C_CYAN}╰────────────────────────────────────────────╯${C_RESET}"
        echo
        echo -e "  ${C_WHITE}${C_BOLD}SELECT CATEGORY / เลือกหมวดหมู่${C_RESET}"
        echo
        echo -e "  ${C_CYAN}┌────────────────────────────────────────────┐${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}  ${C_GREEN}[1]${C_RESET} ${C_WHITE}${C_BOLD}STAR DELTA${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}      ${C_GRAY}APK AVAILABLE: ${n_delta}${C_RESET}"
        echo -e "  ${C_CYAN}├────────────────────────────────────────────┤${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}  ${C_PURPLE}[2]${C_RESET} ${C_WHITE}${C_BOLD}DELTA NO KEY${C_RESET} ${C_GOLD}[VIP]${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}      ${C_GRAY}APK AVAILABLE: ${n_nokey}${C_RESET}"
        echo -e "  ${C_CYAN}├────────────────────────────────────────────┤${C_RESET}"
        echo -e "  ${C_CYAN}│${C_RESET}  ${C_RED}[0]${C_RESET} ${C_RED}EXIT${C_RESET}"
        echo -e "  ${C_CYAN}└────────────────────────────────────────────┘${C_RESET}"
        echo
        echo -e "  ${C_GRAY}Discord: ${DISCORD_LINK}${C_RESET}"
        echo
        read -r -p "  ${C_CYAN}STAR » เลือกเมนู [0-2]: ${C_RESET}" main_choice
        case "$main_choice" in
            1) process_category "STAR DELTA" "Delta." ;;
            2)
                if check_vip_password; then
                    local nokey_prefix="Delta.NoKey."
                    filter_by_category "$nokey_prefix"
                    if (( ${#FILTERED_INDICES[@]} == 0 )); then nokey_prefix="Delta_NoKey_"; fi
                    process_category "DELTA NO KEY VIP" "$nokey_prefix"
                fi
                ;;
            0) break ;;
            *) echo -e "  ${C_RED}เลือกได้เฉพาะ 0, 1 หรือ 2${C_RESET}"; sleep 1 ;;
        esac
    done
    stty sane 2>/dev/null || true
    print_banner
    echo -e "  ${C_GREEN}${C_BOLD}ขอบคุณที่ใช้ STAR SHOP${C_RESET}"
    echo
}

main "$@"
