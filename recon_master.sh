#!/bin/bash
# =============================================================================
#  ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗
#  ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
#  ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
#  ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
#  ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
#  ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
# =============================================================================
#  Author  : ReconMaster Script | For authorized pentesting only
#  Version : 2.0
#  Usage   : sudo bash recon_master.sh <domain/IP>
# =============================================================================

# ─── ANSI COLOR CODES ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_BLUE='\033[44m'

# ─── GLOBAL VARIABLES ─────────────────────────────────────────────────────────
TARGET="${1}"
CURRENT_STEP=0
TOTAL_STEPS=9

# ─── GLOBAL BASE URL (set once after connectivity check) ──────────────────────
BASE_URL=""

resolve_base_url() {
    # Strip any accidental http:// or https:// and path the user may have passed
    CLEAN_TARGET=$(echo "$TARGET" | sed 's|^https\?://||' | sed 's|/.*||')

    # Always use HTTPS
    BASE_URL="https://${CLEAN_TARGET}"

    # Update TARGET to clean version (no scheme, no path)
    TARGET="${CLEAN_TARGET}"
    info "Resolved target: ${CYAN}${BASE_URL}${RESET}"
}

# ─── HELPER FUNCTIONS ─────────────────────────────────────────────────────────

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗ "
    echo "  ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗"
    echo "  ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝"
    echo "  ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗"
    echo "  ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║"
    echo "  ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝"
    echo -e "${RESET}"
    echo -e "${DIM}  ┌─────────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${DIM}  │${RESET}  ${YELLOW}⚠  WARNING: Use only on systems you own or have explicit permission to test${RESET}  ${DIM}│${RESET}"
    echo -e "${DIM}  └─────────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "  ${WHITE}Target:${RESET} ${GREEN}${TARGET}${RESET}   ${WHITE}Date:${RESET} ${GREEN}$(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo ""
}

# ─── SECTION HEADER ────────────────────────────────────────────────────────────
section_header() {
    local title="$1"
    local icon="$2"
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║${RESET}  ${CYAN}${BOLD}${icon}  ${title}${RESET}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ─── PROGRESS BAR ──────────────────────────────────────────────────────────────
progress_bar() {
    local step=$1
    local total=$2
    local label="$3"
    local percent=$(( step * 100 / total ))
    local filled=$(( step * 40 / total ))
    local empty=$(( 40 - filled ))

    local bar="${GREEN}"
    for ((i=0; i<filled; i++)); do bar+="█"; done
    bar+="${DIM}"
    for ((i=0; i<empty; i++)); do bar+="░"; done
    bar+="${RESET}"

    echo ""
    echo -e "  ${WHITE}Progress: [${bar}${WHITE}] ${YELLOW}${percent}%${RESET}  ${DIM}→  ${RESET}${CYAN}${label}${RESET}"
    echo ""
}

# ─── STATUS MESSAGES ───────────────────────────────────────────────────────────
ok()   { echo -e "  ${GREEN}[✔]${RESET} $1"; }
warn() { echo -e "  ${YELLOW}[⚠]${RESET} $1"; }
fail() { echo -e "  ${RED}[✘]${RESET} $1"; }
info() { echo -e "  ${CYAN}[ℹ]${RESET} $1"; }
sub()  { echo -e "  ${DIM}    └─${RESET} $1"; }

# ─── SEPARATOR ─────────────────────────────────────────────────────────────────
sep() {
    echo -e "  ${DIM}──────────────────────────────────────────────────────────────${RESET}"
}

# ─── BOX WRAPPER ───────────────────────────────────────────────────────────────
print_box() {
    local title="$1"
    local content="$2"
    echo -e "  ${MAGENTA}┌── ${WHITE}${BOLD}${title}${RESET} ${MAGENTA}──────────────────────────────────────${RESET}"
    echo "$content" | while IFS= read -r line; do
        echo -e "  ${MAGENTA}│${RESET}  ${line}"
    done
    echo -e "  ${MAGENTA}└──────────────────────────────────────────────────────────${RESET}"
    echo ""
}

# ─── TABLE PRINT ───────────────────────────────────────────────────────────────
print_table_row() {
    local key="$1"
    local value="$2"
    printf "  ${CYAN}│${RESET}  %-25s ${CYAN}│${RESET}  %-35s ${CYAN}│${RESET}\n" "${key}" "${value}"
}

print_table_header() {
    echo -e "  ${CYAN}┌─────────────────────────────┬─────────────────────────────────────┐${RESET}"
    printf "  ${CYAN}│${RESET}  ${BOLD}%-25s${RESET} ${CYAN}│${RESET}  ${BOLD}%-35s${RESET} ${CYAN}│${RESET}\n" "Property" "Value"
    echo -e "  ${CYAN}├─────────────────────────────┼─────────────────────────────────────┤${RESET}"
}

print_table_footer() {
    echo -e "  ${CYAN}└─────────────────────────────┴─────────────────────────────────────┘${RESET}"
}

# ─── USAGE CHECK ───────────────────────────────────────────────────────────────
check_usage() {
    if [[ -z "${TARGET}" ]]; then
        echo -e ""
        echo -e "${RED}  [!] Usage: sudo bash $0 <domain_or_IP>${RESET}"
        echo -e "${YELLOW}  [!] Example: sudo bash $0 example.com${RESET}"
        echo -e "${YELLOW}  [!] Example: sudo bash $0 192.168.1.1${RESET}"
        echo ""
        exit 1
    fi
}

# ─── DEPENDENCY CHECK ──────────────────────────────────────────────────────────
check_dependencies() {
    section_header "DEPENDENCY CHECK" "🔧"

    local required_tools=("nmap" "whois" "dig" "curl" "whatweb" "ffuf" "feroxbuster" "wfuzz" "openssl" "subfinder")
    local optional_tools=("sublist3r" "amass")
    local missing=()
    local missing_optional=()

    echo -e "  ${WHITE}Checking required tools...${RESET}"
    echo ""

    for tool in "${required_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            ok "${tool} ${DIM}($(command -v $tool))${RESET}"
        else
            fail "${RED}${tool}${RESET} — ${RED}NOT FOUND${RESET}"
            missing+=("$tool")
        fi
    done

    echo ""
    echo -e "  ${WHITE}Checking optional tools...${RESET}"
    echo ""

    for tool in "${optional_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            ok "${tool} ${DIM}(optional — found)${RESET}"
        else
            warn "${YELLOW}${tool}${RESET} — ${DIM}Not found (optional)${RESET}"
            missing_optional+=("$tool")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo ""
        echo -e "  ${RED}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "  ${RED}║  MISSING REQUIRED TOOLS — CANNOT CONTINUE                   ║${RESET}"
        echo -e "  ${RED}╚══════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "  ${YELLOW}Run the following to install missing tools on Kali Linux:${RESET}"
        echo ""
        for t in "${missing[@]}"; do
            case "$t" in
                subfinder) echo -e "  ${CYAN}  go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest${RESET}";;
                feroxbuster) echo -e "  ${CYAN}  sudo apt install feroxbuster -y${RESET}";;
                ffuf) echo -e "  ${CYAN}  sudo apt install ffuf -y${RESET}";;
                wfuzz) echo -e "  ${CYAN}  sudo apt install wfuzz -y${RESET}";;
                whatweb) echo -e "  ${CYAN}  sudo apt install whatweb -y${RESET}";;
                *) echo -e "  ${CYAN}  sudo apt install ${t} -y${RESET}";;
            esac
        done
        echo ""
        exit 1
    fi

    echo ""
    ok "${GREEN}All required tools are available. Starting reconnaissance...${RESET}"
    sleep 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 1 — GENERAL QUERY
# ═══════════════════════════════════════════════════════════════════════════════
phase_whois() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "WHOIS Lookup"
    section_header "PHASE 1A — WHOIS INFORMATION" "🌐"

    # Extract root domain (last two labels) for meaningful WHOIS results
    local root_domain
    root_domain=$(echo "$TARGET" | awk -F. '{
        n = NF
        if (n >= 3 && $(n-1) ~ /^(com|net|org|gov|edu|co|org)$/)
            print $(n-2)"."$(n-1)"."$n
        else if (n >= 2)
            print $(n-1)"."$n
        else
            print $0
    }')

    info "Querying WHOIS for root domain: ${CYAN}${root_domain}${RESET}"
    echo ""

    local result
    result=$(whois "$root_domain" 2>/dev/null)

    if [[ -z "$result" ]]; then
        fail "WHOIS lookup failed or returned empty results"
        return
    fi

    print_table_header

    local registrar org country created expires nameservers admin_email
    registrar=$(echo "$result"   | grep -iE "^registrar:"      | head -1 | cut -d: -f2- | xargs)
    org=$(echo "$result"         | grep -iE "^org(-name)?:"    | head -1 | cut -d: -f2- | xargs)
    country=$(echo "$result"     | grep -iE "^country:"        | head -1 | cut -d: -f2- | xargs)
    created=$(echo "$result"     | grep -iE "^creat"           | head -1 | cut -d: -f2- | xargs)
    expires=$(echo "$result"     | grep -iE "^expir"           | head -1 | cut -d: -f2- | xargs)
    nameservers=$(echo "$result" | grep -iE "^name.?server:"   | awk '{print $2}' | tr '\n' ' ')
    admin_email=$(echo "$result" | grep -iE "^admin.?email:"   | head -1 | cut -d: -f2- | xargs)

    print_table_row "Root Domain"   "$root_domain"
    [[ -n "$registrar"   ]] && print_table_row "Registrar"    "$registrar"
    [[ -n "$org"         ]] && print_table_row "Organization" "$org"
    [[ -n "$country"     ]] && print_table_row "Country"      "$country"
    [[ -n "$created"     ]] && print_table_row "Created"      "$created"
    [[ -n "$expires"     ]] && print_table_row "Expires"      "$expires"
    [[ -n "$admin_email" ]] && print_table_row "Admin Email"  "$admin_email"
    [[ -n "$nameservers" ]] && print_table_row "Nameservers"  "${nameservers:0:40}"

    print_table_footer
}

phase_dns() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "DNS Records Enumeration"
    section_header "PHASE 1B — DNS RECORDS" "📋"

    # Root domain for records that only exist at apex (MX, NS, TXT, SOA)
    local root_domain
    root_domain=$(echo "$TARGET" | awk -F. '{
        n = NF
        if (n >= 3 && $(n-1) ~ /^(com|net|org|gov|edu|co)$/)
            print $(n-2)"."$(n-1)"."$n
        else if (n >= 2)
            print $(n-1)"."$n
        else
            print $0
    }')

    info "Subdomain DNS  → ${CYAN}${TARGET}${RESET}"
    info "Root domain    → ${CYAN}${root_domain}${RESET}"
    echo ""

    print_table_header

    # Records on the subdomain itself
    for rtype in "A" "AAAA" "CNAME"; do
        local result
        result=$(dig +short "$rtype" "$TARGET" 2>/dev/null | head -5 | tr '\n' '  ')
        if [[ -n "$result" ]]; then
            print_table_row "$rtype (subdomain)" "$result"
        else
            print_table_row "$rtype (subdomain)" "${DIM}(not found)${RESET}"
        fi
    done

    # Records on the root domain
    for rtype in "NS" "MX" "TXT" "SOA"; do
        local result
        result=$(dig +short "$rtype" "$root_domain" 2>/dev/null | head -5 | tr '\n' '  ')
        if [[ -n "$result" ]]; then
            print_table_row "$rtype (root)" "${result:0:40}"
        else
            print_table_row "$rtype (root)" "${DIM}(not found)${RESET}"
        fi
    done

    print_table_footer

    # Zone Transfer — try against root domain nameservers
    echo ""
    info "Attempting DNS Zone Transfer (AXFR)..."
    local ns_list
    ns_list=$(dig +short NS "$root_domain" 2>/dev/null)
    if [[ -n "$ns_list" ]]; then
        while IFS= read -r ns; do
            local axfr
            axfr=$(dig @"$ns" "$root_domain" AXFR 2>/dev/null | grep -v "^;" | grep -v "^$")
            if [[ -n "$axfr" ]] && ! echo "$axfr" | grep -q "Transfer failed"; then
                fail "Zone Transfer SUCCESSFUL on $ns — CRITICAL MISCONFIGURATION!"
                echo "$axfr" | head -20 | while read -r line; do
                    echo -e "  ${RED}  $line${RESET}"
                done
            else
                ok "Zone Transfer blocked on $ns"
            fi
        done <<< "$ns_list"
    else
        warn "Could not retrieve nameservers for zone transfer test"
    fi
}

phase_subdomains() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "Subdomain Enumeration"
    section_header "PHASE 1C — SUBDOMAIN ENUMERATION" "🔎"

    local found_subs=()

    # Method 1: subfinder
    if command -v subfinder &>/dev/null; then
        info "Running subfinder..."
        while IFS= read -r sub; do
            [[ -n "$sub" ]] && found_subs+=("$sub")
        done < <(subfinder -d "$TARGET" -silent 2>/dev/null | head -30)
    fi

    # Method 2: DNS brute-force with common names
    info "Performing quick DNS brute-force on common subdomains..."
    local common=("www" "mail" "ftp" "admin" "api" "dev" "test" "staging" "vpn" "remote"
                  "portal" "cdn" "blog" "shop" "app" "m" "mobile" "secure" "login" "dashboard"
                  "docs" "wiki" "support" "help" "beta" "old" "new" "static" "assets" "media")

    for sub in "${common[@]}"; do
        local full="${sub}.${TARGET}"
        local ip
        ip=$(dig +short A "$full" 2>/dev/null | head -1)
        if [[ -n "$ip" ]]; then
            found_subs+=("$full → $ip")
        fi
    done

    # Method 3: crt.sh certificate transparency
    info "Querying crt.sh certificate transparency logs..."
    local crt_results
    crt_results=$(curl -s "https://crt.sh/?q=%25.${TARGET}&output=json" 2>/dev/null | \
        grep -oP '"name_value":"[^"]*"' | \
        grep -oP '(?<=")[^"]+(?=")' | \
        grep -v "^name_value$" | \
        sed 's/\\n/\n/g' | \
        grep -v "^\*" | \
        sort -u | head -20)

    if [[ -n "$crt_results" ]]; then
        while IFS= read -r sub; do
            [[ -n "$sub" ]] && found_subs+=("$sub ${DIM}(crt.sh)${RESET}")
        done <<< "$crt_results"
    fi

    if [[ ${#found_subs[@]} -gt 0 ]]; then
        echo -e "  ${GREEN}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "  ${GREEN}║  DISCOVERED SUBDOMAINS (${#found_subs[@]} found)${RESET}"
        echo -e "  ${GREEN}╚══════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        for sub in "${found_subs[@]}"; do
            echo -e "  ${GREEN}  ✦${RESET}  $sub"
        done
    else
        warn "No subdomains discovered"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 2 — PORT SCANNING
# ═══════════════════════════════════════════════════════════════════════════════
phase_nmap() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "Port Scanning & Service Detection"
    section_header "PHASE 2 — NMAP PORT SCAN" "🔍"

    warn "Running aggressive scan — this may take a few minutes..."
    echo ""

    # Intensive nmap scan
    local nmap_output
    nmap_output=$(nmap -sV -sC -O -p- --min-rate=1000 --open -T4 "$TARGET" 2>/dev/null)

    if [[ -z "$nmap_output" ]]; then
        fail "Nmap scan returned no results. Check connectivity or try as root."
        return
    fi

    # Extract and display open ports nicely
    local open_ports
    open_ports=$(echo "$nmap_output" | grep -E "^[0-9]+/(tcp|udp).*open")

    if [[ -n "$open_ports" ]]; then
        echo -e "  ${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
        printf "  ${GREEN}║${RESET}  ${BOLD}%-8s %-12s %-20s %-30s${RESET}\n" "PORT" "STATE" "SERVICE" "VERSION"
        echo -e "  ${GREEN}╠══════════════════════════════════════════════════════════════════════════════╣${RESET}"
        while IFS= read -r line; do
            local port state service version
            port=$(echo "$line" | awk '{print $1}')
            state=$(echo "$line" | awk '{print $2}')
            service=$(echo "$line" | awk '{print $3}')
            version=$(echo "$line" | cut -d' ' -f4- | cut -c1-30)

            # Color code by service
            case "$service" in
                http|https|http-*)  color="${GREEN}";;
                ssh|ftp|telnet)     color="${YELLOW}";;
                smb|netbios*|msrpc) color="${RED}";;
                mysql|mssql*|psql*|mongodb) color="${RED}";;
                *)                  color="${WHITE}";;
            esac

            printf "  ${GREEN}║${RESET}  ${color}%-8s %-12s %-20s %-30s${RESET}\n" \
                "$port" "$state" "$service" "$version"
        done <<< "$open_ports"
        echo -e "  ${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
    else
        warn "No open ports found — target may be firewalled"
    fi

    echo ""

    # OS Detection
    local os_guess
    os_guess=$(echo "$nmap_output" | grep -E "OS:|Running:|OS details:" | head -5)
    if [[ -n "$os_guess" ]]; then
        info "OS Detection Results:"
        echo "$os_guess" | while read -r line; do
            echo -e "  ${MAGENTA}  ◉${RESET}  $line"
        done
    fi

    # Script results
    local script_results
    script_results=$(echo "$nmap_output" | grep -A2 "| " | grep -v "^--$" | head -20)
    if [[ -n "$script_results" ]]; then
        echo ""
        info "NSE Script Results:"
        echo "$script_results" | while read -r line; do
            if echo "$line" | grep -qiE "vuln|VULNERABLE|ERROR|WARN"; then
                echo -e "  ${RED}  $line${RESET}"
            else
                echo -e "  ${DIM}  $line${RESET}"
            fi
        done
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 3 — WEB ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════════
phase_web_analysis() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "Web Headers & Technology Analysis"
    section_header "PHASE 3 — WEB ANALYSIS" "🌍"

    local url="${BASE_URL}"

    info "Fetching HTTP headers from ${CYAN}${url}${RESET}..."
    echo ""

    # Get headers
    local headers
    headers=$(curl -s -I --max-time 10 -L "$url" 2>/dev/null)

    if [[ -z "$headers" ]]; then
        fail "Could not reach ${url}"
        return
    fi

    # Security headers analysis
    declare -A security_headers=(
        ["Strict-Transport-Security"]="HSTS (Forces HTTPS)"
        ["Content-Security-Policy"]="CSP (XSS Protection)"
        ["X-Frame-Options"]="Clickjacking Protection"
        ["X-Content-Type-Options"]="MIME Sniffing Protection"
        ["Referrer-Policy"]="Referrer Leakage Control"
        ["Permissions-Policy"]="Feature/Permission Control"
        ["X-XSS-Protection"]="Legacy XSS Filter"
    )

    echo -e "  ${WHITE}${BOLD}Security Headers Analysis:${RESET}"
    echo ""
    echo -e "  ${CYAN}┌────────────────────────────────────────────────────────────────────┐${RESET}"
    printf "  ${CYAN}│${RESET}  ${BOLD}%-35s %-10s %-20s${RESET}\n" "Header" "Status" "Description"
    echo -e "  ${CYAN}├────────────────────────────────────────────────────────────────────┤${RESET}"

    for header in "${!security_headers[@]}"; do
        local desc="${security_headers[$header]}"
        if echo "$headers" | grep -qi "^${header}:"; then
            local val
            val=$(echo "$headers" | grep -i "^${header}:" | cut -d: -f2- | xargs | cut -c1-20)
            printf "  ${CYAN}│${RESET}  ${GREEN}%-35s${RESET} ${GREEN}%-10s${RESET} %-20s\n" \
                "$header" "[PRESENT]" "$desc"
        else
            printf "  ${CYAN}│${RESET}  ${RED}%-35s${RESET} ${RED}%-10s${RESET} %-20s\n" \
                "$header" "[MISSING]" "$desc"
        fi
    done
    echo -e "  ${CYAN}└────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    # Server header
    local server_header
    server_header=$(echo "$headers" | grep -i "^Server:" | head -1)
    if [[ -n "$server_header" ]]; then
        warn "Server header disclosed: ${YELLOW}${server_header}${RESET}"
    else
        ok "Server header is hidden (good)"
    fi

    # X-Powered-By
    local powered_by
    powered_by=$(echo "$headers" | grep -i "^X-Powered-By:" | head -1)
    if [[ -n "$powered_by" ]]; then
        fail "X-Powered-By disclosed: ${RED}${powered_by}${RESET} — Technology fingerprinting risk!"
    else
        ok "X-Powered-By header is hidden (good)"
    fi

    # Status code
    local status_code
    status_code=$(echo "$headers" | grep "HTTP/" | tail -1 | awk '{print $2}')
    info "HTTP Status: ${CYAN}${status_code}${RESET}"

    # WhatWeb technology fingerprinting
    echo ""
    sep
    info "Running WhatWeb technology fingerprinting..."
    echo ""

    local whatweb_result
    whatweb_result=$(whatweb --no-errors -a 3 "$url" 2>/dev/null)

    if [[ -n "$whatweb_result" ]]; then
        echo -e "  ${MAGENTA}┌── ${WHITE}${BOLD}Detected Technologies${RESET} ${MAGENTA}────────────────────────────────────${RESET}"
        echo "$whatweb_result" | grep -oP '\[.*?\]' | tr ' ' '\n' | grep -v "^\[200\]" | grep -v "^\[\]" | \
            sort -u | while read -r tech; do
                echo -e "  ${MAGENTA}│${RESET}  ${GREEN}✦${RESET}  $tech"
            done
        echo -e "  ${MAGENTA}└──────────────────────────────────────────────────────────${RESET}"
    else
        warn "WhatWeb returned no results"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 4 — SSL CERTIFICATE
# ═══════════════════════════════════════════════════════════════════════════════
phase_ssl() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "SSL/TLS Certificate Analysis"
    section_header "PHASE 4 — SSL/TLS ANALYSIS" "🔒"

    local ssl_host="${CLEAN_TARGET}"
    local ssl_info
    ssl_info=$(echo | openssl s_client -connect "${ssl_host}:443" -servername "$ssl_host" 2>/dev/null)

    if [[ -z "$ssl_info" ]]; then
        warn "Could not connect to port 443 — SSL may not be available"
        return
    fi

    local cert_subject cert_issuer cert_start cert_end cert_san
    cert_subject=$(echo "$ssl_info" | openssl x509 -noout -subject 2>/dev/null | sed 's/subject=//')
    cert_issuer=$(echo "$ssl_info"  | openssl x509 -noout -issuer  2>/dev/null | sed 's/issuer=//')
    cert_start=$(echo "$ssl_info"   | openssl x509 -noout -startdate 2>/dev/null | sed 's/notBefore=//')
    cert_end=$(echo "$ssl_info"     | openssl x509 -noout -enddate   2>/dev/null | sed 's/notAfter=//')
    cert_san=$(echo "$ssl_info"     | openssl x509 -noout -ext subjectAltName 2>/dev/null | grep -oP 'DNS:[^,]+' | tr '\n' ' ')

    print_table_header
    [[ -n "$cert_subject" ]] && print_table_row "Subject"     "${cert_subject:0:40}"
    [[ -n "$cert_issuer"  ]] && print_table_row "Issuer"      "${cert_issuer:0:40}"
    [[ -n "$cert_start"   ]] && print_table_row "Valid From"  "$cert_start"
    [[ -n "$cert_end"     ]] && print_table_row "Valid Until" "$cert_end"
    print_table_footer

    # Check certificate expiry
    local end_epoch now_epoch days_left
    end_epoch=$(date -d "$(echo "$ssl_info" | openssl x509 -noout -enddate 2>/dev/null | sed 's/notAfter=//')" +%s 2>/dev/null)
    now_epoch=$(date +%s)
    if [[ -n "$end_epoch" ]]; then
        days_left=$(( (end_epoch - now_epoch) / 86400 ))
        if [[ $days_left -lt 0 ]]; then
            fail "Certificate is EXPIRED! (${days_left} days ago)"
        elif [[ $days_left -lt 30 ]]; then
            warn "Certificate expires in ${YELLOW}${days_left} days${RESET} — Renew soon!"
        else
            ok "Certificate valid for ${GREEN}${days_left} days${RESET}"
        fi
    fi

    # SAN names
    if [[ -n "$cert_san" ]]; then
        echo ""
        info "Subject Alternative Names (SANs):"
        echo "$cert_san" | tr ' ' '\n' | while read -r san; do
            [[ -n "$san" ]] && echo -e "  ${CYAN}  ◉${RESET}  $san"
        done
    fi

    # Check TLS version
    local tls_version
    tls_version=$(echo "$ssl_info" | grep "Protocol" | awk '{print $3}')
    if [[ -n "$tls_version" ]]; then
        info "TLS Version in use: ${CYAN}${tls_version}${RESET}"
        if echo "$tls_version" | grep -qE "TLSv1$|TLSv1\.0|TLSv1\.1|SSLv"; then
            fail "Outdated TLS version detected — UPGRADE REQUIRED!"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 5 — ROBOTS.TXT & SITEMAP
# ═══════════════════════════════════════════════════════════════════════════════
phase_robots_sitemap() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "Robots.txt & Sitemap Analysis"
    section_header "PHASE 5 — ROBOTS.TXT & SITEMAP" "🤖"

    local base_url="${BASE_URL}"

    # robots.txt
    info "Fetching robots.txt..."
    local robots_content robots_code
    robots_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${base_url}/robots.txt")
    robots_content=$(curl -s --max-time 10 "${base_url}/robots.txt" 2>/dev/null)

    if [[ "$robots_code" == "200" && -n "$robots_content" ]]; then
        ok "robots.txt found (${GREEN}HTTP ${robots_code}${RESET})"
        echo ""
        echo -e "  ${MAGENTA}┌── ${WHITE}${BOLD}robots.txt content${RESET} ${MAGENTA}────────────────────────────────────${RESET}"
        echo "$robots_content" | head -30 | while IFS= read -r line; do
            if echo "$line" | grep -qiE "^disallow:"; then
                echo -e "  ${MAGENTA}│${RESET}  ${YELLOW}$line${RESET}"
            elif echo "$line" | grep -qiE "^allow:"; then
                echo -e "  ${MAGENTA}│${RESET}  ${GREEN}$line${RESET}"
            else
                echo -e "  ${MAGENTA}│${RESET}  ${DIM}$line${RESET}"
            fi
        done
        echo -e "  ${MAGENTA}└──────────────────────────────────────────────────────────${RESET}"

        # Count disallowed paths
        local disallowed_count
        disallowed_count=$(echo "$robots_content" | grep -ci "^Disallow:" || true)
        [[ $disallowed_count -gt 0 ]] && warn "${YELLOW}${disallowed_count}${RESET} Disallow entries found — potentially sensitive paths"
    else
        info "robots.txt not found (HTTP ${robots_code})"
    fi

    echo ""
    sep
    echo ""

    # sitemap.xml
    info "Fetching sitemap.xml..."
    local sitemap_code sitemap_urls
    sitemap_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${base_url}/sitemap.xml")

    if [[ "$sitemap_code" == "200" ]]; then
        ok "sitemap.xml found (${GREEN}HTTP ${sitemap_code}${RESET})"
        sitemap_urls=$(curl -s --max-time 10 "${base_url}/sitemap.xml" 2>/dev/null | \
            grep -oP '(?<=<loc>)[^<]+' | head -20)
        if [[ -n "$sitemap_urls" ]]; then
            local url_count
            url_count=$(echo "$sitemap_urls" | wc -l)
            info "Found ${CYAN}${url_count}${RESET} URLs in sitemap (showing first 10):"
            echo "$sitemap_urls" | head -10 | while read -r surl; do
                echo -e "  ${GREEN}  ✦${RESET}  $surl"
            done
        fi
    else
        info "sitemap.xml not found (HTTP ${sitemap_code})"
        # Try common sitemap locations
        for smap in "sitemap_index.xml" "sitemaps.xml" "sitemap-index.xml" "wp-sitemap.xml"; do
            local alt_code
            alt_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${base_url}/${smap}")
            if [[ "$alt_code" == "200" ]]; then
                ok "Found alternate sitemap: ${CYAN}/${smap}${RESET} (HTTP ${alt_code})"
            fi
        done
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 6 — DIRECTORY FUZZING
# ═══════════════════════════════════════════════════════════════════════════════
phase_fuzzing() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "Directory & File Fuzzing"
    section_header "PHASE 6 — DIRECTORY FUZZING (feroxbuster)" "💣"

    local base_url="${BASE_URL}"
    local wordlist
    for wl in \
        "/usr/share/wordlists/dirb/common.txt" \
        "/usr/share/seclists/Discovery/Web-Content/common.txt" \
        "/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt" \
        "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"; do
        if [[ -f "$wl" ]]; then
            wordlist="$wl"
            break
        fi
    done

    if [[ -z "$wordlist" ]]; then
        warn "No wordlist found. Creating a minimal wordlist..."
        wordlist="/tmp/recon_minimal_wordlist.txt"
        cat > "$wordlist" << 'WORDLIST'
admin
administrator
login
dashboard
api
backup
config
test
dev
staging
uploads
images
files
docs
database
db
phpinfo
.env
.git
.htaccess
wp-admin
wp-login.php
robots.txt
sitemap.xml
readme
README
LICENSE
CHANGELOG
index.php
index.html
console
panel
manager
management
WORDLIST
    fi

    info "Using wordlist: ${CYAN}${wordlist}${RESET}"
    info "Fuzzing ${CYAN}${base_url}${RESET} — this may take a few minutes..."
    echo ""

    # Run feroxbuster
    local fuzz_results
    fuzz_results=$(feroxbuster \
        --url "$base_url" \
        --wordlist "$wordlist" \
        --threads 50 \
        --depth 2 \
        --status-codes 200,201,301,302,403,500 \
        --no-state \
        --quiet \
        --timeout 10 \
        2>/dev/null | grep -E "^\s*(200|201|301|302|403|500)" | head -40)

    if [[ -n "$fuzz_results" ]]; then
        echo -e "  ${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
        printf "  ${GREEN}║${RESET}  ${BOLD}%-6s %-10s %-50s${RESET}\n" "CODE" "SIZE" "URL"
        echo -e "  ${GREEN}╠══════════════════════════════════════════════════════════════════════════════╣${RESET}"
        echo "$fuzz_results" | while IFS= read -r line; do
            local code
            code=$(echo "$line" | awk '{print $1}')
            case "$code" in
                200|201) color="${GREEN}";;
                301|302) color="${CYAN}";;
                403)     color="${YELLOW}";;
                500)     color="${RED}";;
                *)       color="${WHITE}";;
            esac
            echo -e "  ${GREEN}║${RESET}  ${color}${line}${RESET}"
        done
        echo -e "  ${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
    else
        info "No interesting paths discovered by feroxbuster"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# PHASE 7 — PARAMETER FUZZING
# ═══════════════════════════════════════════════════════════════════════════════
phase_param_fuzzing() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS "Parameter Fuzzing with WFuzz"
    section_header "PHASE 7 — PARAMETER FUZZING (wfuzz)" "🎯"

    local base_url="${BASE_URL}"

    # Wordlist for params
    local param_wordlist
    for wl in \
        "/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt" \
        "/usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt" \
        "/usr/share/wordlists/dirb/common.txt"; do
        if [[ -f "$wl" ]]; then
            param_wordlist="$wl"
            break
        fi
    done

    if [[ -z "$param_wordlist" ]]; then
        # Create minimal param wordlist
        param_wordlist="/tmp/recon_params.txt"
        printf "id\npage\nfile\npath\ndir\nurl\nsearch\nq\nquery\nuser\nname\npassword\ntoken\nkey\naction\ntype\ncategory\ncat\nview\nmode\n" > "$param_wordlist"
    fi

    info "Fuzzing GET parameters on ${CYAN}${base_url}${RESET}..."
    warn "Showing only interesting responses (non-404)..."
    echo ""

    local wfuzz_results
    wfuzz_results=$(wfuzz \
        -c \
        -z file,"$param_wordlist" \
        --hc 404 \
        --timeout 5 \
        -t 30 \
        "${base_url}/?FUZZ=test" \
        2>/dev/null | grep -v "^#" | grep -v "^$" | head -20)

    if [[ -n "$wfuzz_results" ]]; then
        echo -e "  ${YELLOW}┌── ${WHITE}${BOLD}Parameter Responses${RESET} ${YELLOW}──────────────────────────────────────${RESET}"
        echo "$wfuzz_results" | while IFS= read -r line; do
            if echo "$line" | grep -qE "^0"; then
                echo -e "  ${YELLOW}│${RESET}  ${line}"
            fi
        done
        echo -e "  ${YELLOW}└──────────────────────────────────────────────────────────${RESET}"
    else
        info "No interesting parameter responses found"
    fi

    # Quick LFI check
    echo ""
    info "Quick LFI probe..."
    local lfi_payloads=("../etc/passwd" "....//....//etc/passwd" "%2e%2e%2fetc%2fpasswd")
    for payload in "${lfi_payloads[@]}"; do
        local response
        response=$(curl -s --max-time 5 "${base_url}/?file=${payload}" 2>/dev/null)
        if echo "$response" | grep -q "root:"; then
            fail "Potential LFI FOUND with payload: ${RED}${payload}${RESET}"
        fi
    done
    ok "Basic LFI probe completed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# FINAL SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════
print_summary() {
    CURRENT_STEP=$TOTAL_STEPS
    progress_bar $CURRENT_STEP $TOTAL_STEPS "Reconnaissance Complete!"

    echo ""
    echo -e "${CYAN}"
    echo "  ╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                              ║"
    echo "  ║                    ✅  RECONNAISSANCE COMPLETE                               ║"
    echo "  ║                                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    echo -e "  ${WHITE}Target Scanned:${RESET}   ${GREEN}${TARGET}${RESET}"
    echo -e "  ${WHITE}Scan Finished:${RESET}    ${GREEN}$(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo ""
    echo -e "  ${DIM}┌── Phases Completed ───────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${DIM}│${RESET}  ${GREEN}✔${RESET}  WHOIS Lookup          ${DIM}│${RESET}  ${GREEN}✔${RESET}  DNS Records              ${DIM}│${RESET}  ${GREEN}✔${RESET}  Subdomain Enum"
    echo -e "  ${DIM}│${RESET}  ${GREEN}✔${RESET}  Port Scanning         ${DIM}│${RESET}  ${GREEN}✔${RESET}  Web Headers Analysis     ${DIM}│${RESET}  ${GREEN}✔${RESET}  SSL/TLS Check"
    echo -e "  ${DIM}│${RESET}  ${GREEN}✔${RESET}  Robots/Sitemap        ${DIM}│${RESET}  ${GREEN}✔${RESET}  Directory Fuzzing        ${DIM}│${RESET}  ${GREEN}✔${RESET}  Param Fuzzing"
    echo -e "  ${DIM}└───────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo -e "  ${YELLOW}⚠  Reminder: Use this data only for authorized security assessments.${RESET}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    check_usage
    print_banner
    check_dependencies
    resolve_base_url

    phase_whois
    phase_dns
    phase_subdomains
    phase_nmap
    phase_web_analysis
    phase_ssl
    phase_robots_sitemap
    phase_fuzzing
    phase_param_fuzzing

    print_summary
}

main "$@"
