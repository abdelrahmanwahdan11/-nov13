import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../ui/pages/auth/auth_pages.dart';
import '../../ui/pages/catalog/catalog_page.dart';
import '../../ui/pages/compare/compare_page.dart';
import '../../ui/pages/editor/editor_page.dart';
import '../../ui/pages/home/home_page.dart';
import '../../ui/pages/library/drafts_library_page.dart';
import '../../ui/pages/downloads/downloads_page.dart';
import '../../ui/pages/notifications/notifications_page.dart';
import '../../ui/pages/onboarding/onboarding_page.dart';
import '../../ui/pages/player/player_page.dart';
import '../../ui/pages/profile/profile_page.dart';
import '../../ui/pages/publish/publish_page.dart';
import '../../ui/pages/record/record_page.dart';
import '../../ui/pages/search/search_page.dart';
import '../../ui/pages/settings/settings_page.dart';
import '../../ui/pages/splash_page.dart';
import '../../ui/pages/static/static_pages.dart';
import '../../ui/pages/insights/insights_page.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings, AuthController authController) {
    switch (settings.name) {
      case '/splash':
        return _build(settings, const SplashPage());
      case '/onboarding':
        return _build(settings, const OnboardingStoryPage());
      case '/auth/signin':
        return _build(settings, SignInPage(controller: authController));
      case '/auth/signup':
        return _build(settings, SignUpPage(controller: authController));
      case '/auth/forgot':
        return _build(settings, const ForgotPasswordPage());
      case '/home':
        return _build(settings, const HomePage());
      case '/player':
        return _build(settings, const PlayerDetailPage());
      case '/record':
        return _build(settings, const RecordStudioPage());
      case '/editor':
        return _build(settings, const EditorPage());
      case '/publish':
        return _build(settings, const PublishPage());
      case '/drafts':
        return _build(settings, const DraftsLibraryPage());
      case '/downloads':
        return _build(settings, const DownloadsPage());
      case '/catalog':
        return _build(settings, const DiscoverCatalogPage());
      case '/search':
        return _build(settings, const SearchPage());
      case '/compare':
        return _build(settings, const ComparePage());
      case '/profile':
        return _build(settings, const ProfilePage());
      case '/insights':
        return _build(settings, const InsightsPage());
      case '/settings':
        return _build(settings, const SettingsPage());
      case '/notifications':
        return _build(settings, const NotificationsPage());
      case '/help':
        return _build(settings, const HelpPage());
      case '/terms':
        return _build(settings, const TermsPage());
      case '/report':
        return _build(settings, const ReportPage());
      default:
        return _build(settings, const SplashPage());
    }
  }

  static MaterialPageRoute<dynamic> _build(RouteSettings settings, Widget child) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => child,
    );
  }
}
