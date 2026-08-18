import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/providers.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _dataSharing = false;
  bool _analytics = true;
  bool _profileVisibility = true;
  bool _voteHistory = false;

  static const String _kDataSharing = 'privacy_data_sharing';
  static const String _kAnalytics = 'privacy_analytics';
  static const String _kProfileVisibility = 'privacy_profile_visibility';
  static const String _kVoteHistory = 'privacy_vote_history';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dataSharing = prefs.getBool(_kDataSharing) ?? false;
      _analytics = prefs.getBool(_kAnalytics) ?? true;
      _profileVisibility = prefs.getBool(_kProfileVisibility) ?? true;
      _voteHistory = prefs.getBool(_kVoteHistory) ?? false;
    });
  }

  Future<void> _persist(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _toggle(void Function(bool) write, String key, bool val) {
    setState(() => write(val));
    _persist(key, val);
  }

  String _kycLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Verified';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Not Submitted';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    final d = date.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _showDownloadDataDialog() {
    final user = context.read<AuthProvider>().user;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D28),
          title: const Text('Your Data', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _dataRow('Full Name', user?.fullName ?? 'Not set'),
                _dataRow('Email', user?.email ?? 'Not set'),
                _dataRow('Phone', user?.phone ?? 'Not provided'),
                _dataRow('Role', user?.role ?? 'voter'),
                _dataRow('KYC Status', _kycLabel(user?.kycStatus.name ?? '')),
                _dataRow('Account Created', _formatDate(user?.createdAt)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFFB9C3FF)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D28),
          title: const Text(
            'Delete Account?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will permanently delete your account and all associated data. This action cannot be undone.',
            style: TextStyle(color: Color(0xFFC4C5D7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFB9C3FF)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please contact support@securevote.io to delete your account.',
                    ),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection('Data & Analytics', [
            _buildToggleItem(
              'Share Usage Data',
              'Help improve SecureVote by sharing anonymous usage data',
              _dataSharing,
              (value) => _toggle((v) => _dataSharing = v, _kDataSharing, value),
            ),
            _buildToggleItem(
              'Analytics',
              'Allow analytics to improve your experience',
              _analytics,
              (value) => _toggle((v) => _analytics = v, _kAnalytics, value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Profile Privacy', [
            _buildToggleItem(
              'Public Profile',
              'Make your profile visible to other users',
              _profileVisibility,
              (value) => _toggle(
                (v) => _profileVisibility = v,
                _kProfileVisibility,
                value,
              ),
            ),
            _buildToggleItem(
              'Show Vote History',
              'Display your voting participation publicly',
              _voteHistory,
              (value) => _toggle((v) => _voteHistory = v, _kVoteHistory, value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Data Management', [
            _buildActionItem(
              Icons.download,
              'Download My Data',
              'Get a copy of your personal data',
              _showDownloadDataDialog,
            ),
            _buildActionItem(
              Icons.delete_forever,
              'Delete Account',
              'Permanently delete your account and data',
              _showDeleteConfirmation,
              isDestructive: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1D28),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFB9C3FF),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFFB9C3FF),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(0xFFFF6B6B)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
