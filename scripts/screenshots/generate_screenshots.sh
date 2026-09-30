#!/usr/bin/env bash

# ==============================================================================
# Script Name: generate_screenshots.sh
# Description: Orchestrator – generates full store screenshot suite for PulseTrack
#              by delegating to modular per-feature generators.
#              Ensures consistent ScreenshotDeviceFrame emulation (status bar 09:41
#              + notification icon + signal/wifi/battery + bottom gesture pill).
# Supports:
#   android/phone     (1080 x 2400)  -> Medium_Phone
#   android/tablet_7  (800 x 1280)   -> Small_Tablet  (7")
#   android/tablet_10 (2560 x 1600)  -> Medium_Tablet (10")
# Usage:
#   ./scripts/screenshots/generate_screenshots.sh [target|device] [device|locale] [locale]
#   Examples:
#     ./scripts/screenshots/generate_screenshots.sh phone
#     ./scripts/screenshots/generate_screenshots.sh phone pl
#     ./scripts/screenshots/generate_screenshots.sh all en
#     ./scripts/screenshots/generate_screenshots.sh onboarding phone pl
#     ./scripts/screenshots/generate_screenshots.sh core phone
# Per-feature scripts:
#   - generate_core.sh        (Home, Scanner, Live Monitor, History, Details)
#   - generate_onboarding.sh  (Welcome, Permissions, Biometric, Completion)
#   - generate_settings.sh    (Settings Screen, Licenses Screen)
#   - generate_biometric.sh   (Biometric Shield Screen)
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

FEATURE_SCRIPTS=(
    "generate_onboarding.sh"
    "generate_core.sh"
    "generate_settings.sh"
    "generate_biometric.sh"
)

ARG1="${1:-phone}"
ARG2="${2:-}"
ARG3="${3:-}"

if [[ "$ARG1" == "-h" || "$ARG1" == "--help" ]]; then
    echo "Usage: $0 [target|device] [device|locale] [locale]"
    echo ""
    echo "Generates Google Play Store screenshot suite for PulseTrack."
    echo "Suites:"
    echo "  - onboarding (Welcome, Permissions, Biometric, Completion)"
    echo "  - core       (Home, Scanner, Live Monitor, History, Details)"
    echo "  - settings   (Settings Screen, Licenses Screen)"
    echo "  - biometric  (Biometric Shield Screen)"
    echo ""
    echo "Arguments:"
    echo "  target  all|core|onboarding|settings|biometric (optional, default: all features)"
    echo "  device  phone|tablet_7|tablet_10|all          (default: phone)"
    echo "  locale  en|pl|de|es|fr|it|ja|ko|nl|pt         (default: all supported)"
    echo ""
    echo "Examples:"
    echo "  $0 phone"
    echo "  $0 phone pl"
    echo "  $0 all en"
    echo "  $0 core phone pl"
    echo "  $0 onboarding phone"
    exit 0
fi

# Detect whether $ARG1 is a feature target or device
SPECIFIC_TARGET=""
case "$ARG1" in
    core|onboarding|settings|biometric)
        SPECIFIC_TARGET="$ARG1"
        DEVICE_INPUT="${ARG2:-phone}"
        LOCALE_FILTER="${ARG3:-}"
        ;;
    *)
        DEVICE_INPUT="$ARG1"
        LOCALE_FILTER="$ARG2"
        ;;
esac

case "$DEVICE_INPUT" in
    phone|tablet_7|tablet_10|all) ;;
    *)
        log_error "Unknown device: $DEVICE_INPUT (expected: phone|tablet_7|tablet_10|all)"
        echo "Usage: $0 [target|device] [device|locale] [locale]"
        exit 1
        ;;
esac

if [[ -n "$LOCALE_FILTER" ]]; then
    case "$LOCALE_FILTER" in
        en|pl|de|es|fr|it|ja|ko|nl|pt) ;;
        *)
            log_error "Unknown locale: $LOCALE_FILTER (expected: en|pl|de|es|fr|it|ja|ko|nl|pt)"
            exit 1
            ;;
    esac
fi

START_TIME=$(date +%s)

log_info "Starting PulseTrack Screenshot Suite..."
log_info "Devices: $DEVICE_INPUT | Locale: ${LOCALE_FILTER:-all}"

if [[ -n "$SPECIFIC_TARGET" ]]; then
    TARGET_SCRIPT="generate_${SPECIFIC_TARGET}.sh"
    log_step "Feature target: $TARGET_SCRIPT ($DEVICE_INPUT / ${LOCALE_FILTER:-all})"
    if [[ ! -x "$DIR/$TARGET_SCRIPT" ]]; then
        log_error "Missing or non-executable: $DIR/$TARGET_SCRIPT"
        exit 1
    fi
    "$DIR/$TARGET_SCRIPT" "$DEVICE_INPUT" "${LOCALE_FILTER:-}"
else
    for SCRIPT in "${FEATURE_SCRIPTS[@]}"; do
        log_step "Feature: $SCRIPT ($DEVICE_INPUT / ${LOCALE_FILTER:-all})"
        if [[ ! -x "$DIR/$SCRIPT" ]]; then
            log_error "Missing or non-executable: $DIR/$SCRIPT"
            exit 1
        fi
        "$DIR/$SCRIPT" "$DEVICE_INPUT" "${LOCALE_FILTER:-}"
    done
fi

# Global verification
log_step "Global Verification (all devices)..."
TOTAL_ALL=$(find screenshots/android -type f -name "*.png" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
log_success "Total Android screenshots across all devices: $TOTAL_ALL"

if [[ -d "screenshots/android" ]]; then
    echo ""
    log_info "Captured screenshots preview:"
    find screenshots/android -type f -name "*.png" | sort | head -n 25
    if [[ "$TOTAL_ALL" -gt 25 ]]; then
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
