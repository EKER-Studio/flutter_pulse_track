# Security Policy

## Supported Versions

Only the latest released version of PulseTrack receives security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security and privacy of user health data very seriously.

If you believe you have discovered a security vulnerability in PulseTrack, please do NOT create a public issue on GitHub. Instead, report it privately:

1. Send an email to **security@ekerstudio.com** (or open a private security advisory on GitHub).
2. Include a detailed description of the vulnerability, steps to reproduce, and potential impact.
3. Allow up to 48 hours for an initial response from the development team.
4. We will coordinate a fix and release before any public disclosure.

## Security Architecture Highlights

- **Local-First & Offline:** Health data (heart rate samples, workout sessions, device profiles) never leaves the device unless explicitly exported by the user.
- **AES-256 Encryption:** Sensitive fields are encrypted with AES-256-CBC + HMAC-SHA256 via `FieldCipher`, with keys isolated in platform-native hardware keychains (Android Keystore / iOS Keychain) via `flutter_secure_storage`.
- **Biometric Shield:** Optional biometric lock (`local_auth` with fallback to PIN/pattern/password) protects the app when backgrounded; `BiometricShieldScreen` enforces re-authentication on resume.
- **Privacy-First Analytics:** Telemetry events never log sensitive biometric or health indicators (heart rate values, device MAC addresses, workout metrics).
