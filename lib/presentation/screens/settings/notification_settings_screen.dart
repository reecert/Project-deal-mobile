import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/di/providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _dealAlerts = true;
  bool _keywordAlerts = true;
  bool _categoryAlerts = true;
  bool _priceDropAlerts = true;
  bool _marketing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _dealAlerts = response['deal_alerts'] ?? true;
          _keywordAlerts = response['keyword_alerts'] ?? true;
          _categoryAlerts = response['category_alerts'] ?? true;
          _priceDropAlerts = response['price_drop_alerts'] ?? true;
          _marketing = response['marketing'] ?? false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePreferences() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await supabase.from('notification_preferences').upsert({
        'user_id': user.id,
        'deal_alerts': _dealAlerts,
        'keyword_alerts': _keywordAlerts,
        'category_alerts': _categoryAlerts,
        'price_drop_alerts': _priceDropAlerts,
        'marketing': _marketing,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Preferences saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving preferences: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(onPressed: _savePreferences, child: const Text('Save')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSection(
                  title: 'Deal Alerts',
                  children: [
                    _buildSwitch(
                      title: 'New Deals',
                      subtitle: 'Get notified about new deals',
                      value: _dealAlerts,
                      onChanged: (v) => setState(() => _dealAlerts = v),
                    ),
                    _buildSwitch(
                      title: 'Price Drops',
                      subtitle: 'Alerts when saved deals drop in price',
                      value: _priceDropAlerts,
                      onChanged: (v) => setState(() => _priceDropAlerts = v),
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Personalized Alerts',
                  children: [
                    _buildSwitch(
                      title: 'Keyword Alerts',
                      subtitle: 'Deals matching your saved keywords',
                      value: _keywordAlerts,
                      onChanged: (v) => setState(() => _keywordAlerts = v),
                    ),
                    _buildSwitch(
                      title: 'Category Alerts',
                      subtitle: 'Deals in your favorite categories',
                      value: _categoryAlerts,
                      onChanged: (v) => setState(() => _categoryAlerts = v),
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Marketing',
                  children: [
                    _buildSwitch(
                      title: 'Promotional Emails',
                      subtitle: 'Special offers and newsletters',
                      value: _marketing,
                      onChanged: (v) => setState(() => _marketing = v),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
