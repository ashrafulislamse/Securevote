import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0E13).withOpacity(0.8),
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
            onPressed: () {},
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
                color: Colors.white.withOpacity(0.03),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB9C3FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB9C3FF).withOpacity(0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFFB9C3FF),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
                  _buildToggle(
                    _allNotifications,
                    (val) => setState(() => _allNotifications = val),
                  ),
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
                (val) => setState(() => _electionReminders = val),
              ),
              _buildNotificationItem(
                'Voting Deadline',
                'Critical alerts before polls close',
                Icons.timer,
                const Color(0xFF2ADEC0),
                _votingDeadline,
                (val) => setState(() => _votingDeadline = val),
              ),
              _buildNotificationItem(
                'Results Published',
                'Immediate notice of final tallies',
                Icons.leaderboard,
                const Color(0xFFB9C3FF),
                _resultsPublished,
                (val) => setState(() => _resultsPublished = val),
              ),
              _buildNotificationItem(
                'New Elections',
                'Notification for newly created polls',
                Icons.fiber_new,
                const Color(0xFFD2BBFF),
                _newElections,
                (val) => setState(() => _newElections = val),
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
                (val) => setState(() => _kycUpdates = val),
              ),
              _buildNotificationItem(
                'Security Alerts',
                'Logins from new devices or locations',
                Icons.gpp_maybe,
                const Color(0xFFFFB4AB),
                _securityAlerts,
                (val) => setState(() => _securityAlerts = val),
              ),
              _buildNotificationItem(
                'Announcements',
                'General platform updates and news',
                Icons.campaign,
                const Color(0xFFE3E1E9),
                _announcements,
                (val) => setState(() => _announcements = val),
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
                      (val) => setState(() => _pushEnabled = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDeliveryCard(
                      'Email',
                      Icons.mail,
                      const Color(0xFFD2BBFF),
                      _emailEnabled,
                      (val) => setState(() => _emailEnabled = val),
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
                color: Colors.white.withOpacity(0.03),
                border: Border.all(
                  color: const Color(0xFF2ADEC0).withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
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
                        (val) => setState(() => _quietHours = val),
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
                            color: Colors.black.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
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
                            color: Colors.black.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
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
            decoration: BoxDecoration(
              color: const Color(0xFF34343A),
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
          const Text(
            'Active',
            style: TextStyle(color: Color(0xFFC4C5D7), fontSize: 10),
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
              ? const Color(0xFFB9C3FF).withOpacity(0.2)
              : const Color(0xFF34343A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
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
