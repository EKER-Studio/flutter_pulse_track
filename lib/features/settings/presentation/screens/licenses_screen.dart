import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Aggregated package license entry holding the package name and its license texts.
class PackageLicense {
  /// Name of the open-source package.
  final String packageName;

  /// List of license paragraphs.
  final List<String> paragraphs;

  const PackageLicense({required this.packageName, required this.paragraphs});
}

/// Offline-accessible screen displaying open-source software licenses.
class LicensesScreen extends StatefulWidget {
  /// Optional pre-loaded [PackageInfo] instance.
  final PackageInfo? packageInfo;

  const LicensesScreen({super.key, this.packageInfo});

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  late final Future<PackageInfo> _packageInfoFuture;
  late final Future<List<PackageLicense>> _licensesFuture;

  @override
  void initState() {
    super.initState();
    final packageInfo = widget.packageInfo;
    _packageInfoFuture = packageInfo != null
        ? Future.value(packageInfo)
        : PackageInfo.fromPlatform();
    _licensesFuture = _loadLicenses();
  }

  static Future<List<PackageLicense>> _loadLicenses() async {
    final packageMap = <String, List<String>>{};

    await for (final entry in LicenseRegistry.licenses) {
      final text = entry.paragraphs.map((p) => p.text).join('\n\n');
      for (final package in entry.packages) {
        packageMap.putIfAbsent(package, () => []).add(text);
      }
    }

    final sortedKeys = packageMap.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return sortedKeys
        .map(
          (pkg) =>
              PackageLicense(packageName: pkg, paragraphs: packageMap[pkg]!),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(l10n.settingsLicenses)),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_packageInfoFuture, _licensesFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final packageInfo = snapshot.data?[0] is PackageInfo
              ? snapshot.data![0] as PackageInfo
              : null;
          final licenses = snapshot.data?[1] is List<PackageLicense>
              ? snapshot.data![1] as List<PackageLicense>
              : <PackageLicense>[];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: licenses.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: AppColors.surfaceBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.accentBlue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.homeTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (packageInfo != null &&
                                        packageInfo.version.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'v${packageInfo.version} (${packageInfo.buildNumber})',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '© 2026 PulseTrack',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              Text(
                                '${licenses.length} packages',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.accentBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final item = licenses[index - 1];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: AppColors.surfaceBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                child: ExpansionTile(
                  title: Text(
                    item.packageName,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        item.paragraphs.join('\n\n'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
