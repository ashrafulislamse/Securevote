import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/navigation/app_router.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allNotifications = true;
  bool _electionReminders = true;
  bool _votingDeadline = true;
  bool _resultsPublished = true;
  bool _newElections = false;
  bool _kycUpdates = true;
  bool _securityAlerts = true;
  bool _announcements = false;
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _quietHours = true;

  static const String _kMaster = 'notif_master';
  static const String _kElectionReminders = 'notif_election_reminders';
  static const String _kVotingDeadline = 'notif_voting_deadline';
  static const String _kResultsPublished = 'notif_results_published';
  static const String _kNewElections = 'notif_new_elections';
  static const String _kKycUpdates = 'notif_kyc_updates';
  static const String _kSecurityAlerts = 'notif_security_alerts';
  static const String _kAnnouncements = 'notif_announcements';
  static const String _kPushEnabled = 'notif_push_enabled';
  static const String _kEmailEnabled = 'notif_email_enabled';
  static const String _kQuietHours = 'notif_quiet_hours';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _allNotifications = prefs.getBool(_kMaster) ?? true;
      _electionReminders = prefs.getBool(_kElectionReminders) ?? true;
      _votingDeadline = prefs.getBool(_kVotingDeadline) ?? true;
      _resultsPublished = prefs.getBool(_kResultsPublished) ?? true;
      _newElections = prefs.getBool(_kNewElections) ?? false;
      _kycUpdates = prefs.getBool(_kKycUpdates) ?? true;
      _securityAlerts = prefs.getBool(_kSecurityAlerts) ?? true;
      _announcements = prefs.getBool(_kAnnouncements) ?? false;
      _pushEnabled = prefs.getBool(_kPushEnabled) ?? true;
      _emailEnabled = prefs.getBool(_kEmailEnabled) ?? true;
      _quietHours = prefs.getBool(_kQuietHours) ?? true;
    });
  }

  Future<void> _persist(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _toggleMaster(bool val) {
    setState(() => _allNotifications = val);
    _persist(_kMaster, val);
  }

  void _toggle(
    bool Function() read,
    void Function(bool) write,
    String key,
    bool val,
  ) {
    setState(() => write(val));
    _persist(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0E13).withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB9C3FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFFE3E1E9),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFB9C3FF)),
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.alertsInbox),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage how SecureVote communicates with you.',
              style: TextStyle(color: Color(0xFF8B93B0), fontSize: 13),
            ),

            const SizedBox(height: 32),

            // Master Toggle
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB9C3FF).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFFB9C3FF),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Notifications',
                          style: TextStyle(
                            color: Color(0xFFE3E1E9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Global switch for all alerts',
                          style: TextStyle(
                            color: Color(0xFFC4C5D7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildToggle(_allNotifications, _toggleMaster),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Election Alerts
            _buildSection('ELECTION ALERTS', [
              _buildNotificationItem(
                'Election Reminders',
                'Upcoming votes you\'re eligible for',
                Icons.calendar_today,
                const Color(0xFFD2BBFF),
                _electionReminders,
                (val) => _toggle(
                  () => _electionReminders,
                  (v) => _electionReminders = v,
                  _kElectionReminders,
                  val,
                ),
              ),
              _buildNotificationItem(
                'Voting Deadline',
                'Critical alerts before polls close',
                Icons.timer,
                const Color(0xFF2ADEC0),
                _votingDeadline,
                (val) => _toggle(
                  () => _votingDeadline,
                  (v) => _votingDeadline = v,
                  _kVotingDeadline,
                  val,
                ),
              ),
              _buildNotificationItem(
                'Results Published',
                'Immediate notice of final tallies',
                Icons.leaderboard,
                const Color(0xFFB9C3FF),
                _resultsPublished,
                (val) => _toggle(
                  () => _resultsPublished,
                  (v) => _resultsPublished = v,
                  _kResultsPublished,
                  val,
                ),
              ),
              _buildNotificationItem(
                'New Elections',
                'Notification for newly created polls',
                Icons.fiber_new,
                const Color(0xFFD2BBFF),
                _newElections,
                (val) => _toggle(
                  () => _newElections,
                  (v) => _newElections = v,
                  _kNewElections,
                  val,
                ),
              ),
            ]),

            const SizedBox(height: 32),

            // Account Alerts
            _buildSection('ACCOUNT ALERTS', [
              _buildNotificationItem(
                'KYC Updates',
                'Identity verification status changes',
                Icons.verified_user,
                const Color(0xFF2ADEC0),
                _kycUpdates,
                (val) => _toggle(
                  () => _kycUpdates,
                  (v) => _kycUpdates = v,
                  _kKycUpdates,
                  val,
                ),
              ),
              _buildNotificationItem(
                'Security Alerts',
                'Logins from new devices or locations',
                Icons.gpp_maybe,
                const Color(0xFFFFB4AB),
                _securityAlerts,
                (val) => _toggle(
                  () => _securityAlerts,
                  (v) => _securityAlerts = v,
                  _kSecurityAlerts,
                  val,
                ),
              ),
              _buildNotificationItem(
                'Announcements',
                'General platform updates and news',
                Icons.campaign,
                const Color(0xFFE3E1E9),
                _announcements,
                (val) => _toggle(
                  () => _announcements,
                  (v) => _announcements = v,
                  _kAnnouncements,
                  val,
                ),
              ),
            ]),

            const SizedBox(height: 32),

            // Delivery
            _buildSection('DELIVERY', [
              Row(
                children: [
                  Expanded(
                    child: _buildDeliveryCard(
                      'Push',
                      Icons.send_to_mobile,
                      const Color(0xFFB9C3FF),
                      _pushEnabled,
                      (val) => _toggle(
                        () => _pushEnabled,
                        (v) => _pushEnabled = v,
                        _kPushEnabled,
                        val,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDeliveryCard(
                      'Email',
                      Icons.mail,
                      const Color(0xFFD2BBFF),
                      _emailEnabled,
                      (val) => _toggle(
                        () => _emailEnabled,
                        (v) => _emailEnabled = v,
                        _kEmailEnabled,
                        val,
                      ),
                    ),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 32),

            // Quiet Hours
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(
                  color: const Color(0xFF2ADEC0).withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quiet Hours',
                            style: TextStyle(
                              color: Color(0xFFE3E1E9),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Mute all non-essential alerts',
                            style: TextStyle(
                              color: Color(0xFFC4C5D7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      _buildToggle(
                        _quietHours,
                        (val) => _toggle(
                          () => _quietHours,
                          (v) => _quietHours = v,
                          _kQuietHours,
                          val,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'START',
                                style: TextStyle(
                                  color: Color(0xFFC4C5D7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '22:00',
                                style: TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'END',
                                style: TextStyle(
                                  color: Color(0xFFC4C5D7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '07:00',
                                style: TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Quiet hours are not customizable in this version.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFC4C5D7),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF34343A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFE3E1E9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFC4C5D7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _buildToggle(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(
    String title,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE3E1E9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ? 'Active' : 'Off',
            style: const TextStyle(color: Color(0xFFC4C5D7), fontSize: 10),
          ),
          const SizedBox(height: 16),
          _buildToggle(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildToggle(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFFB9C3FF).withValues(alpha: 0.2)
              : const Color(0xFF34343A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: value ? const Color(0xFFB9C3FF) : const Color(0xFF8E90A0),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
