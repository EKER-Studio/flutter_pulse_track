#!/usr/bin/env bash

# ==============================================================================
# Script Name: generate_screenshots.sh
# Description: Orchestrator – generates full store screenshot suite for PulseTrack
#              using integration_test/pulse_track_screenshots_test.dart.
#              Ensures consistent ScreenshotDeviceFrame emulation (status bar 09:41
#              + notification icon + signal/wifi/battery + bottom gesture pill).
# Supports:
#   android/phone     (1080 x 2400)  -> Medium_Phone
#   android/tablet_7  (800 x 1280)   -> Small_Tablet  (7")
#   android/tablet_10 (2560 x 1600)  -> Medium_Tablet (10")
# Usage:
#   ./scripts/screenshots/generate_screenshots.sh [phone|tablet_7|tablet_10|all] [locale]
#   Default: phone (all locales)
#   Examples:
#     ./scripts/screenshots/generate_screenshots.sh phone
#     ./scripts/screenshots/generate_screenshots.sh phone pl
#     ./scripts/screenshots/generate_screenshots.sh all en
#     ./scripts/screenshots/generate_screenshots.sh all
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  [INFO]${NC} $1"
}

log_step() {
    echo -e "\n${YELLOW}⚙️  [STEP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DEVICE_INPUT="${1:-phone}"
LOCALE_FILTER="${2:-}"

if [[ "$DEVICE_INPUT" == "-h" || "$DEVICE_INPUT" == "--help" ]]; then
    echo "Usage: $0 [phone|tablet_7|tablet_10|all] [locale]"
    echo ""
    echo "Generates Google Play Store screenshot suite for PulseTrack."
    echo "Screens captured:"
    echo "  - 01_home (Saved sensors, scan CTA, feature hub)"
    echo "  - 02_scanner (Discovered BLE sensors with dBm badges)"
    echo "  - 03_live_monitor (Active workout telemetry: 142 BPM, RR, battery)"
    echo "  - 04_workout_history (Completed workout session list)"
    echo "  - 05_workout_details (Summary grid & HR zone waveform chart)"
    echo ""
    echo "Arguments:"
    echo "  device  phone|tablet_7|tablet_10|all  (default: phone)"
    echo "  locale  en|pl                         (default: all)"
    echo ""
    echo "Examples:"
    echo "  $0 phone"
    echo "  $0 phone pl"
    echo "  $0 all en"
    exit 0
fi

case "$DEVICE_INPUT" in
    phone|tablet_7|tablet_10|all) ;;
    *)
        log_error "Unknown device: $DEVICE_INPUT (expected: phone|tablet_7|tablet_10|all)"
        echo "Usage: $0 [phone|tablet_7|tablet_10|all] [locale]"
        exit 1
        ;;
esac

if [[ -n "$LOCALE_FILTER" ]]; then
    case "$LOCALE_FILTER" in
        en|pl) ;;
        *)
            log_error "Unknown locale: $LOCALE_FILTER (expected: en|pl)"
            exit 1
            ;;
    esac
fi

START_TIME=$(date +%s)

log_info "Starting PulseTrack Screenshot Suite..."
log_info "Devices: $DEVICE_INPUT | Locale: ${LOCALE_FILTER:-all}"

# Execute runner with unified test suite
log_step "Executing integration test suite..."
"$DIR/run_screenshot_target.sh" "integration_test/pulse_track_screenshots_test.dart" "$DEVICE_INPUT" "${LOCALE_FILTER:-}"

# Global verification
log_step "Global Verification (all devices)..."
TOTAL_ALL=$(find screenshots/android -type f -name "*.png" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
log_success "Total Android screenshots across all devices: $TOTAL_ALL"

if [[ -d "screenshots/android" ]]; then
    echo ""
    log_info "Captured screenshots preview:"
    find screenshots/android -type f -name "*.png" | sort | head -n 20
    if [[ "$TOTAL_ALL" -gt 20 ]]; then
        echo "... ($TOTAL_ALL total, truncated)"
    fi
    echo ""
    log_info "Per-device breakdown:"
    for D in phone tablet_7 tablet_10; do
        if [[ -d "screenshots/android/$D" ]]; then
            COUNT=$(find "screenshots/android/$D" -type f -name "*.png" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
            echo "  android/$D: $COUNT"
        fi
    done
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n=============================================================================="
log_success "Full screenshots suite completed in ${DURATION}s (devices: $DEVICE_INPUT, locale: ${LOCALE_FILTER:-all})"
echo -e "=============================================================================="
