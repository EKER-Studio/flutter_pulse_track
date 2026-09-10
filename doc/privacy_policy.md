# Privacy Policy for PulseTrack: Heart Rate Monitor

**Effective date:** September 10, 2026  
**Last updated:** September 12, 2026

EKER Studio ("we", "our", or "us") built the **PulseTrack: Heart Rate Monitor** app as a free utility application. This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our application.

### 1. Information Collection and Storage
- **Personal & Biometric Health Data:** All telemetry measurements (heart rate BPM, R-R intervals, heart rate zones, timestamps, and workout session summaries) collected by the app are stored exclusively **locally on your device** via an embedded local database (Isar). We do not operate external cloud databases or remote servers that collect, store, or transmit your workout sessions.
- **Sensor Connection Profiles:** Previously paired Bluetooth Low Energy (BLE) sensor profiles (device MAC address, custom names) are cached locally on your device to enable instant direct connection.

### 2. Device Hardware & Sensor Permissions
- **Bluetooth:** PulseTrack requires Bluetooth permissions (`BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` on Android; `NSBluetoothAlwaysUsageDescription`, `NSBluetoothPeripheralUsageDescription` on iOS) to discover, pair, and stream real-time biometric telemetry from standard Bluetooth Low Energy (GATT) heart rate monitors and chest straps.
- **Location:** On certain Android versions, Location permissions (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`) are mandated by the operating system to perform Bluetooth Low Energy hardware scans. PulseTrack uses these permissions solely for Bluetooth device discovery and never accesses, tracks, records, or shares your geographic location.
- **Foreground Service & Notifications:** PulseTrack operates an Android Foreground Service (`FOREGROUND_SERVICE_HEALTH`, `FOREGROUND_SERVICE_CONNECTED_DEVICE`) with a persistent system notification while an active workout is in progress. This ensures uninterrupted sensor connection and telemetry recording when your device screen is locked or the app is minimized.

### 3. Crash Reporting and Diagnostics
- The application may collect anonymous technical crash logs and performance diagnostics via Firebase Crashlytics and Firebase Analytics to identify defects, crashes, and improve overall app reliability. These diagnostics are stripped of personally identifiable information (PII) and do not contain personal health measurements or raw sensor telemetry.
- Telemetry collection is active in production release builds and completely disabled in debug builds.

### 4. Third-Party Access and Data Sharing
- We do not sell, rent, monetize, or disclose your personal fitness data to third parties, data brokers, or advertising networks.
- All session exports (such as CSV export) are generated entirely on-device and shared only through user-initiated actions via the native operating system share sheet.

### 5. Medical Disclaimer
- PulseTrack: Heart Rate Monitor is intended exclusively for personal fitness, athletic training, and general wellness informational purposes. It is **not a medical device** and is not certified to diagnose, monitor, treat, cure, or prevent any cardiovascular disease, medical condition, or health impairment. Always consult a qualified physician or healthcare professional regarding any medical concerns.

### 6. Children's Privacy
- Our app is not directed to individuals under the age of 13. We do not knowingly collect personal data from children.

### 7. Changes to This Privacy Policy
- We may update our Privacy Policy periodically. You are advised to review this document periodically for any updates. Changes are effective immediately upon publication.

### 8. Contact Us
If you have any questions or suggestions regarding this Privacy Policy, please contact us at:  
**Email:** contact@ekerstudio.com
