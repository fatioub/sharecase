import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_service.dart';
import '../services/currency_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeService themeService;

  const SettingsScreen({super.key, required this.themeService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoadingRates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSection(
            context,
            'Appearance',
            [
              _buildSettingsTile(
                context,
                'Theme',
                widget.themeService.getThemeName(),
                Icons.palette_outlined,
                onTap: () => _showThemeDialog(context),
              ),
            ],
          ),
          _buildSection(
            context,
            'Currency',
            [
              _buildSettingsTile(
                context,
                'Exchange Rate Source',
                CurrencyService.isLiveData ? 'ExchangeRate-API (Live)' : 'Offline Data',
                CurrencyService.isLiveData ? Icons.public : Icons.offline_bolt,
                onTap: () => _showCurrencySourceInfo(context),
              ),
              _buildSettingsTile(
                context,
                'Available Currencies',
                '${CurrencyService.availableRatesCount} rates',
                Icons.currency_exchange,
              ),
              _buildSettingsTile(
                context,
                'Last Updated',
                CurrencyService.getLastUpdateTime(),
                Icons.access_time,
                trailing: _isLoadingRates 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshCurrencyRates,
                      ),
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              _buildSettingsTile(
                context,
                'Version',
                '1.0.0',
                Icons.info_outline,
              ),
              _buildSettingsTile(
                context,
                'Rate App',
                'Support us on App Store',
                Icons.star_outline,
                onTap: () => _showRateAppDialog(context),
              ),
              _buildSettingsTile(
                context,
                'Privacy Policy',
                'How we protect your data',
                Icons.security,
                onTap: () => _showPrivacyPolicy(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap != null ? () {
          HapticFeedback.lightImpact();
          onTap();
        } : null,
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return ListTile(
              title: Text(_getThemeDisplayName(mode)),
              leading: Icon(_getThemeIcon(mode)),
              trailing: widget.themeService.themeMode == mode 
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                widget.themeService.setThemeMode(mode);
                Navigator.pop(context);
                setState(() {});
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getThemeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings;
    }
  }

  Future<void> _refreshCurrencyRates() async {
    setState(() => _isLoadingRates = true);
    
    try {
      await CurrencyService.getExchangeRates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Exchange rates updated'),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update rates'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRates = false);
      }
    }
  }

  void _showCurrencySourceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Currency Data Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CurrencyService.isLiveData 
                  ? 'Live Data (${CurrencyService.availableRatesCount} currencies)'
                  : 'Offline Data (${CurrencyService.availableRatesCount} currencies)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              CurrencyService.isLiveData
                  ? 'Exchange rates are provided by ExchangeRate-API, a free service that provides real-time currency conversion rates for ${CurrencyService.availableRatesCount} currencies worldwide.\n\nRates are updated hourly and cached locally for better performance.'
                  : 'Currently using offline exchange rates as a fallback. ${CurrencyService.availableRatesCount} major currencies are supported.\n\nTap refresh to try connecting to live data again.',
            ),
            const SizedBox(height: 12),
            Text(
              'Last updated: ${CurrencyService.getLastUpdateTime()}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Univert'),
        content: const Text(
          'If you enjoy using Univert, please consider rating us on the App Store. Your feedback helps us improve!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              const appleId = 'YOUR_APPLE_ID'; // Set this after approval
              if (appleId == 'YOUR_APPLE_ID') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App Store link will be available after approval.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              final appStoreUrl = 'https://apps.apple.com/app/id$appleId';
              if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
                await launchUrl(Uri.parse(appStoreUrl), mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open App Store.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Univert respects your privacy. This app:\n\n'
            '• Does not collect personal information\n'
            '• Only stores your theme preference locally\n'
            '• Makes network requests only to fetch currency rates\n'
            '• Does not share data with third parties\n\n'
            'Your conversion history is not stored or transmitted.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
