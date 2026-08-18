import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/notification.dart' as notif;
import '../../../../core/providers/notifications_provider.dart';

/// Detailed view of a single in-app notification.
///
/// Receives the [notif.AppNotification] via `ModalRoute.settings.arguments`.
/// If no argument is provided (e.g. a deep link), a friendly placeholder is
/// shown.
class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({super.key, this.notification});

  /// Convenience constructor for pre-loaded data.
  // ignore: prefer_initializing_formals
  const NotificationDetailScreen.withNotification(
    notif.AppNotification this.notification, {
    super.key,
  });

  final notif.AppNotification? notification;

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    // Mark as read on first view.
    final n = widget.notification;
    if (n != null && !n.read) {
      _marked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // markRead is optimistic; no need to block on the server.
        context.read<NotificationsProvider>().markRead(n.id);
      });
    }
  }

  String _badgeFor(String type) {
    switch (type) {
      case 'kyc_approved':
      case 'kyc_rejected':
        return 'KYC UPDATE';
      case 'vote_recorded':
        return 'VOTE CONFIRMATION';
      case 'election_opened':
        return 'ELECTION UPDATE';
      case 'election_closed':
        return 'ELECTION CLOSED';
      case 'election_published':
        return 'RESULTS LIVE';
      default:
        return 'NOTIFICATION';
    }
  }

  String _footerFor(String type) {
    switch (type) {
      case 'kyc_approved':
        return 'Your identity verification is complete. You can now participate in all eligible elections.';
      case 'kyc_rejected':
        return 'Your identity verification was not approved. Please review your documents and resubmit from the KYC section.';
      case 'vote_recorded':
        return 'Your vote was recorded and is protected by cryptographic proofs. Use your receipt ID to verify it on the blockchain.';
      case 'election_opened':
        return 'Polls are now open for this election. Visit the Home screen to cast your vote before it closes.';
      case 'election_closed':
        return 'Voting has closed for this election. Results will be published once the tally is finalized.';
      case 'election_published':
        return 'The official results are now available. Open the election to view the final tallies.';
      default:
        return 'Your account activity is protected by cryptographic proofs. Open the SecureVote app for the full context.';
    }
  }

  String _fullTimestamp(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);
    String rel;
    if (diff.inMinutes < 1) {
      rel = 'Just now';
    } else if (diff.inMinutes < 60) {
      rel = '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      rel = '${diff.inHours} hours ago';
    } else {
      rel = '${diff.inDays} days ago';
    }
    final formatted = ts.toLocal().toString().split('.').first;
    return '$rel • $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
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
          'Notification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          if (notification != null && !notification.read && !_marked)
            IconButton(
              tooltip: 'Mark as read',
              icon: const Icon(Icons.mark_email_read_outlined),
              onPressed: () async {
                final notifProvider = context.read<NotificationsProvider>();
                final navigator = Navigator.of(context);
                await notifProvider.markRead(notification.id);
                if (!mounted) return;
                navigator.pop();
              },
            ),
        ],
      ),
      body: notification == null
          ? const _MissingNotification()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFB9C3FF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _badgeFor(notification.type),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB9C3FF),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Timestamp
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _fullTimestamp(notification.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1A1B21),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          notification.body.isEmpty
                              ? 'You have a new SecureVote notification.'
                              : notification.body,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Key Information:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem('Type', _badgeFor(notification.type)),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          'Received',
                          _relative(notification.createdAt),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          'Status',
                          notification.read ? 'Read' : 'Unread',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _footerFor(notification.type),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: const Text(
                        'Back to Inbox',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB9C3FF),
                        foregroundColor: const Color(0xFF001257),
                        elevation: 8,
                        shadowColor: const Color(
                          0xFFB9C3FF,
                        ).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFB9C3FF),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _relative(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _MissingNotification extends StatelessWidget {
  const _MissingNotification();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              'Notification not available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
