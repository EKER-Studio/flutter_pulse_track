# Security Policy

## Supported Versions

Only the latest released version of PulseTrack receives security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security and privacy of user biometric and workout data very seriously.

If you believe you have discovered a security vulnerability in PulseTrack, please do NOT create a public issue on GitHub. Instead, report it privately:

1. Send an email to **security@ekerstudio.com** (or open a private security advisory on GitHub).
2. Include a detailed description of the vulnerability, steps to reproduce, and potential impact.
3. Allow up to 48 hours for an initial response from the development team.
4. We will coordinate a fix and release before any public disclosure.

## Security Architecture Highlights

- **Local-First & Offline:** Heart rate measurements, workout sessions, and sensor locations never leave the device unless explicitly exported by the user.
- **Secure BLE Communication:** Standard Bluetooth SIG Heart Rate Service (0x180D) communication is handled locally with no intermediate cloud relay or external telemetry.
- **Privacy-First Analytics:** Telemetry events never log sensitive biometric or health indicators (BPM values, heart rate zone distributions, workout notes).
