#!/data/data/com.termux/files/usr/bin/bash

VOUCHERS_FILE="vouchers.txt"
USED_VOUCHERS_FILE="used_vouchers.txt"
PROCESSED_FILE="processed.txt"
SLEEP_DURATION=5

# Color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # No Color

log() {
    echo -e "${BLUE}[$(date +'%T')]${NC} $1"
}

success() {
    echo -e "${GREEN}[$(date +'%T')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%T')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%T')] $1${NC}"
}

log "Starting M-PESA SMS monitor..."

while true; do
    log "Scanning for new payment SMS..."

    SMS=$(termux-sms-list -l 5 | jq -c '.[]' | while read -r sms; do
        SENDER=$(echo "$sms" | jq -r '.number')
        BODY=$(echo "$sms" | jq -r '.body')

        if [[ "$SENDER" == "MPESA" || "$SENDER" == "MPesa" ]] && [[ "$BODY" == *"received Ksh"* ]]; then
            echo "$BODY"
            break
        fi
    done)

    if [[ -z "$SMS" ]]; then
        warn "No M-PESA payment SMS found. Sleeping..."
        sleep "$SLEEP_DURATION"
        continue
    fi

    CODE=$(echo "$SMS" | grep -oE '^[A-Z0-9]{10}')
    AMOUNT=$(echo "$SMS" | grep -oE 'received Ksh[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+')
    PHONE=$(echo "$SMS" | grep -oE '[0-9]{10}' | head -n1)

    if grep -q "$CODE" "$PROCESSED_FILE" 2>/dev/null; then
        warn "Already processed: $CODE. Skipping..."
        sleep "$SLEEP_DURATION"
        continue
    fi

    success "M-PESA SMS detected."
    log "Extracted Data -> Code: ${YELLOW}$CODE${NC} | Amount: ${YELLOW}Ksh$AMOUNT${NC} | Phone: ${YELLOW}$PHONE${NC}"

    PACKAGE=$(awk -F: -v a="$AMOUNT" '$1 == a {print $2}' "$VOUCHERS_FILE" | grep -vxFf "$USED_VOUCHERS_FILE" | head -n1)

    if [[ -n "$PACKAGE" ]]; then
        MESSAGE="Here is your WiFi access voucher code: $PACKAGE. Tap 'Sign in to Network' to use this voucher. THANK YOU AND ENJOY."

        log "Sending voucher to $PHONE..."
        termux-sms-send -n "$PHONE" "$MESSAGE"

        success "Voucher sent!"
        echo "$PACKAGE" >> "$USED_VOUCHERS_FILE"
        echo "$CODE" >> "$PROCESSED_FILE"
        sed -i "/$PACKAGE/d" "$VOUCHERS_FILE"

        log "Voucher removed from inventory. Done."
    else
        error "No available voucher for amount Ksh$AMOUNT or all vouchers used. Skipping..."
        echo "$CODE" >> "$PROCESSED_FILE"
    fi

    sleep "$SLEEP_DURATION"
done
