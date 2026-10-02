python - <<'PYEOF'
import os, re
p = os.path.expanduser("~/star_shop.sh")
s = open(p, encoding="utf-8").read()

# ═══ 1) แทน print_banner — บล็อกไม่มี backslash (กันเพี้ยน) ═══
new_banner = '''print_banner() {
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
}'''
s, n = re.subn(r"print_banner\(\) \{.*?\n\}", new_banner, s, count=1, flags=re.S)
assert n == 1, "banner not found"

# ═══ 2) เพิ่มหมวด ROOT ในเมนูหลัก ═══
old_menu = '''        filter_by_category "Delta."
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

        echo -e "  ${C_YELLOW}■ ${C_WHITE}${C_BOLD}ทางเลือก${C_RESET}  ${C_GRAY}(เลือกหมวดหมู่)${C_RESET}"
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo -e "  ${C_GREEN}[1]${C_RESET} ${C_GOLD}►${C_RESET} ${C_WHITE}Delta${C_RESET}            ${C_GRAY}(${N_DELTA} ตัว)${C_RESET}"
        echo -e "  ${C_GREEN}[2]${C_RESET} ${C_GOLD}►${C_RESET} ${C_PINK}Delta No Key 💎${C_RESET}  ${C_GRAY}(${N_NOKEY} ตัว) ${C_YELLOW}[VIP]${C_RESET}"
        echo -e "  ${C_GREEN}[3]${C_RESET} ${C_GOLD}►${C_RESET} ${C_EMERALD}Delta ROOT 🔒${C_RESET}   ${C_GRAY}(${N_ROOT} ตัว) ${C_YELLOW}[root เท่านั้น]${C_RESET}"
        echo -e "  ${C_RED}   [0]${C_RESET} ${C_RED}►${C_RESET} ${C_RED}Exit${C_RESET}"
        echo ""
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo -e "  ${C_GRAY}พิมพ์รายละเอียด : 0-3${C_RESET}"
        echo ""

        echo -ne "${CR}  ${C_YELLOW}● ${C_WHITE}เลือกทางเลือก: ${C_RESET}"
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
                # สาย root — ต้อง root + ต้องมี su ทำงานได้
                if ! command -v su >/dev/null 2>&1 || ! su -c "true" >/dev/null 2>&1; then
                    echo -e "  ${C_RED}❌ หมวดนี้สำหรับเครื่อง ROOT เท่านั้น${C_RESET}"
                    echo -e "  ${C_GRAY}   ติดตั้ง Magisk แล้วกดอนุญาตให้ Termux ก่อน${C_RESET}"
                    sleep 1.5
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
        esac'''

new_menu = '''        filter_by_category "Delta."
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

        echo -e "  ${C_YELLOW}■ ${C_WHITE}${C_BOLD}ทางเลือก${C_RESET}  ${C_GRAY}(เลือกหมวดหมู่)${C_RESET}"
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo -e "  ${C_GREEN}[1]${C_RESET} ${C_GOLD}►${C_RESET} ${C_WHITE}Delta${C_RESET}            ${C_GRAY}(${N_DELTA} ตัว)${C_RESET}"
        echo -e "  ${C_GREEN}[2]${C_RESET} ${C_GOLD}►${C_RESET} ${C_PINK}Delta No Key 💎${C_RESET}  ${C_GRAY}(${N_NOKEY} ตัว) ${C_YELLOW}[VIP]${C_RESET}"
        echo -e "  ${C_GREEN}[3]${C_RESET} ${C_GOLD}►${C_RESET} ${C_EMERALD}Delta ROOT 🔒${C_RESET}   ${C_GRAY}(${N_ROOT} ตัว) ${C_YELLOW}[root เท่านั้น]${C_RESET}"
        echo -e "  ${C_RED}   [0]${C_RESET} ${C_RED}►${C_RESET} ${C_RED}Exit${C_RESET}"
        echo ""
        echo -e "  ${C_SAPPHIRE}${C_SUB}${C_RESET}"
        echo -e "  ${C_GRAY}พิมพ์รายละเอียด : 0-3${C_RESET}"
        echo ""

        echo -ne "${CR}  ${C_YELLOW}● ${C_WHITE}เลือกทางเลือก: ${C_RESET}"
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
                # สาย root — ต้อง root + ต้องมี su ทำงานได้
                if ! command -v su >/dev/null 2>&1 || ! su -c "true" >/dev/null 2>&1; then
                    echo -e "  ${C_RED}❌ หมวดนี้สำหรับเครื่อง ROOT เท่านั้น${C_RESET}"
                    echo -e "  ${C_GRAY}   ติดตั้ง Magisk แล้วกดอนุญาตให้ Termux ก่อน${C_RESET}"
                    sleep 1.5
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
        esac'''
assert old_menu in s, "main menu block not found"
s = s.replace(old_menu, new_menu)

open(p, "w", encoding="utf-8").write(s)
print("OK: banner + ROOT menu patch สำเร็จ")
PYEOF
