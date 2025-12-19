#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/common.sh"

trap 'log_error "DNS setup failed (line $LINENO)."; exit 1' ERR

require_command "networksetup" "networksetup command is required for DNS configuration."

# Default DNS servers if none are provided as arguments.
# Order:
#   1. Quad9
#   2. Cloudflare
#   3. Google
#   4. Router's gateway (if detected)
readonly DEFAULT_DNS=(
  "9.9.9.9"          # Quad9 primary
  "149.112.112.112"  # Quad9 secondary
  "1.1.1.1"          # Cloudflare primary
  "1.0.0.1"          # Cloudflare secondary
  "8.8.8.8"          # Google primary
  "8.8.4.4"          # Google secondary
)

reset_dns_to_default() {
    log_info "Resetting DNS to default (DHCP/automatic) for all services..."
    
    # Get all network services, skipping header line
    local services
    services="$(networksetup -listallnetworkservices | tail -n +2)"
    
    local reset_count=0
    while IFS= read -r svc; do
        # Skip empty lines
        [[ -z "$svc" ]] && continue
        
        # Handle disabled services starting with "* "
        if [[ "${svc:0:1}" == "*" ]]; then
            local disabled_svc="${svc#* }"
            log_warn "Skipping disabled service: $disabled_svc"
            continue
        fi
        
        log_info "Resetting DNS for service: $svc"
        if sudo networksetup -setdnsservers "$svc" "Empty"; then
            ((reset_count++))
        else
            log_warn "Failed to reset DNS for service: $svc"
        fi
    done <<< "$services"
    
    if [[ $reset_count -gt 0 ]]; then
        log_info "DNS reset to default for $reset_count service(s)."
    else
        log_warn "No services were reset"
    fi
}

setup_dns_servers() {
    local dns_servers=("$@")
    
    # Try to append router/gateway IP as last-resort DNS.
    # Note: this assumes the default gateway also acts as a DNS forwarder,
    # which is true for most home/office setups.
    local default_gateway
    default_gateway=$(route -n get default 2>/dev/null | awk '/gateway:/ {print $2}' || true)
    
    if [[ -n "${default_gateway:-}" ]]; then
        case " ${dns_servers[*]} " in
            *" ${default_gateway} "*) : ;;   # already present, do nothing
            *) dns_servers+=("${default_gateway}") ;;
        esac
    fi
    
    log_info "Using DNS servers: ${dns_servers[*]}"
    
    # Get all network services, skipping header line
    local services
    services="$(networksetup -listallnetworkservices | tail -n +2)"
    
    local updated_count=0
    while IFS= read -r svc; do
        # Skip empty lines
        [[ -z "$svc" ]] && continue
        
        # Handle disabled services starting with "* "
        if [[ "${svc:0:1}" == "*" ]]; then
            local disabled_svc="${svc#* }"
            log_warn "Skipping disabled service: $disabled_svc"
            continue
        fi
        
        log_info "Setting DNS for service: $svc"
        if sudo networksetup -setdnsservers "$svc" "${dns_servers[@]}"; then
            ((updated_count++))
        else
            log_warn "Failed to set DNS for service: $svc"
        fi
    done <<< "$services"
    
    if [[ $updated_count -gt 0 ]]; then
        log_info "DNS updated for $updated_count service(s)."
    else
        log_warn "No services were updated"
    fi
}

# Check if user wants to reset to default
if [[ $# -ge 1 && ( "$1" == "reset" || "$1" == "--reset" || "$1" == "-r" ) ]]; then
    reset_dns_to_default
elif [[ $# -lt 1 ]]; then
    # Use defaults if no args were provided
    log_info "No DNS servers supplied on the command line."
    setup_dns_servers "${DEFAULT_DNS[@]}"
else
    setup_dns_servers "$@"
fi

trap - ERR
log_info "DNS setup complete!"
