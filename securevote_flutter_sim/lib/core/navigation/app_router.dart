import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/elections/presentation/screens/candidate_details_screen.dart';
import '../../features/elections/presentation/screens/election_details_screen.dart';
import '../../features/elections/presentation/screens/election_rules_screen.dart';
import '../../features/elections/presentation/screens/election_search_screen.dart';
import '../../features/elections/presentation/screens/home_placeholder_screen.dart';
import '../../features/elections/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/alerts_inbox_screen.dart';
import '../../features/profile/presentation/screens/profile_hub_screen.dart';
import '../../features/receipts/presentation/screens/my_votes_screen.dart';
import '../../features/kyc/presentation/screens/kyc_step1_screen.dart';
import '../../features/kyc/presentation/screens/kyc_status_pending_screen.dart';
import '../../features/kyc/presentation/screens/kyc_liveness_check_screen.dart';
import '../../features/voting/presentation/screens/ballot_casting_screen.dart';
import '../../features/voting/presentation/screens/review_vote_screen.dart';
import '../../features/voting/presentation/screens/vote_success_screen.dart';
import '../../features/receipts/presentation/screens/vote_receipt_screen.dart';
import '../../features/elections/presentation/screens/compare_candidates_screen.dart';
import '../../features/elections/presentation/screens/candidate_manifesto_screen.dart';
import '../../features/elections/presentation/screens/election_results_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_view_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/notification_detail_screen.dart';
import '../../features/profile/presentation/screens/help_article_screen.dart';
import '../../features/profile/presentation/screens/security_settings_screen.dart';
import '../../features/profile/presentation/screens/privacy_settings_screen.dart';
import '../../features/profile/presentation/screens/appearance_settings_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/kyc/presentation/screens/kyc_success_screen.dart';
import '../../features/voting/presentation/screens/vote_verification_screen.dart';
import '../../features/voting/presentation/screens/already_voted_screen.dart';
import '../../shared/screens/error_screen.dart';
import '../../features/auth/presentation/screens/account_suspended_screen.dart';
import '../../shared/screens/maintenance_screen.dart';
import '../../features/elections/presentation/screens/ineligible_screen.dart';
import '../../features/elections/presentation/screens/election_closed_screen.dart';
import '../../features/elections/presentation/screens/election_participation_screen.dart';
import '../models/notification.dart' as notif;

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String register = '/register';
  static const String kycStep1 = '/kyc-step-1';
  static const String kycLiveness = '/kyc-liveness';
  static const String kycStatusPending = '/kyc-status-pending';
  static const String homeScreen = '/home-screen';
  static const String electionSearch = '/election-search';
  static const String electionDetails = '/election-details';
  static const String electionRules = '/election-rules';
  static const String myVotes = '/my-votes';
  static const String alertsInbox = '/alerts';
  static const String profileHub = '/profile-hub';
  static const String homePlaceholder = '/home';
  static const String candidateDetails = '/candidate-details';
  static const String ballotCasting = '/ballot-casting';
  static const String reviewVote = '/review-vote';
  static const String voteSuccess = '/vote-success';
  static const String voteReceipt = '/vote-receipt';
  static const String compareCandidates = '/compare-candidates';
  static const String candidateManifesto = '/candidate-manifesto';
  static const String electionResults = '/election-results';
  static const String changePassword = '/change-password';
  static const String editProfile = '/edit-profile';
  static const String profileView = '/profile-view';
  static const String notificationSettings = '/notification-settings';
  static const String helpSupport = '/help-support';
  static const String notificationDetail = '/notification-detail';
  static const String helpArticle = '/help-article';
  static const String securitySettings = '/security-settings';
  static const String privacySettings = '/privacy-settings';
  static const String appearanceSettings = '/appearance-settings';
  static const String about = '/about';
  static const String kycSuccess = '/kyc-success';
  static const String voteVerification = '/vote-verification';
  static const String alreadyVoted = '/already-voted';
  static const String error = '/error';
  static const String accountSuspended = '/account-suspended';
  static const String maintenance = '/maintenance';
  static const String ineligible = '/ineligible';
  static const String electionClosed = '/election-closed';
  static const String electionParticipation = '/election-participation';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen(), settings);
      case welcome:
        return _page(const WelcomeScreen(), settings);
      case onboarding:
        return _page(const OnboardingScreen(), settings);
      case login:
        return _page(const LoginScreen(), settings);
      case forgotPassword:
        return _page(const ForgotPasswordScreen(), settings);
      case resetPassword:
        return _page(const ResetPasswordScreen(), settings);
      case register:
        return _page(const RegisterScreen(), settings);
      case kycStep1:
        return _page(const KycStep1Screen(), settings);
      case kycLiveness:
        return _page(const KycLivenessCheckScreen(), settings);
      case kycStatusPending:
        return _page(const KycStatusPendingScreen(), settings);
      case homeScreen:
        return _page(const HomeScreen(), settings);
      case electionSearch:
        return _page(const ElectionSearchScreen(), settings);
      case electionDetails:
        return _page(const ElectionDetailsScreen(), settings);
      case electionRules:
        return _page(const ElectionRulesScreen(), settings);
      case myVotes:
        return _page(const MyVotesScreen(), settings);
      case alertsInbox:
        return _page(const AlertsInboxScreen(), settings);
      case profileHub:
        return _page(const ProfileHubScreen(), settings);
      case homePlaceholder:
        return _page(const HomePlaceholderScreen(), settings);
      case candidateDetails:
        return _page(const CandidateDetailsScreen(), settings);
      case ballotCasting:
        return _page(const BallotCastingScreen(), settings);
      case reviewVote:
        return _page(const ReviewVoteScreen(), settings);
      case voteSuccess:
        return _page(const VoteSuccessScreen(), settings);
      case voteReceipt:
        return _page(const VoteReceiptScreen(), settings);
      case compareCandidates:
        return _page(const CompareCandidatesScreen(), settings);
      case candidateManifesto:
        return _page(const CandidateManifestoScreen(), settings);
      case electionResults:
        return _page(const ElectionResultsScreen(), settings);
      case changePassword:
        return _page(const ChangePasswordScreen(), settings);
      case editProfile:
        return _page(const EditProfileScreen(), settings);
      case profileView:
        return _page(const ProfileViewScreen(), settings);
      case notificationSettings:
        return _page(const NotificationSettingsScreen(), settings);
      case helpSupport:
        return _page(const HelpSupportScreen(), settings);
      case notificationDetail:
        final notif.AppNotification? notification =
            settings.arguments is notif.AppNotification
            ? settings.arguments as notif.AppNotification
            : null;
        return _page(
          notification == null
              ? const NotificationDetailScreen()
              : NotificationDetailScreen.withNotification(notification),
          settings,
        );
      case helpArticle:
        return _page(const HelpArticleScreen(), settings);
      case securitySettings:
        return _page(const SecuritySettingsScreen(), settings);
      case privacySettings:
        return _page(const PrivacySettingsScreen(), settings);
      case appearanceSettings:
        return _page(const AppearanceSettingsScreen(), settings);
      case about:
        return _page(const AboutScreen(), settings);
      case kycSuccess:
        return _page(const KycSuccessScreen(), settings);
      case voteVerification:
        return _page(const VoteVerificationScreen(), settings);
      case alreadyVoted:
        return _page(const AlreadyVotedScreen(), settings);
      case error:
        return _page(const ErrorScreen(), settings);
      case accountSuspended:
        return _page(const AccountSuspendedScreen(), settings);
      case maintenance:
        return _page(const MaintenanceScreen(), settings);
      case ineligible:
        return _page(const IneligibleScreen(), settings);
      case electionClosed:
        return _page(const ElectionClosedScreen(), settings);
      case electionParticipation:
        return _page(const ElectionParticipationScreen(), settings);
      default:
        return _page(const WelcomeScreen(), settings);
    }
  }

  static PageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }
}
