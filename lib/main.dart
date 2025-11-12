import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/achievements_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/community_controller.dart';
import 'controllers/compare_controller.dart';
import 'controllers/downloads_controller.dart';
import 'controllers/edit_controller.dart';
import 'controllers/feed_controller.dart';
import 'controllers/insights_controller.dart';
import 'controllers/notifications_controller.dart';
import 'controllers/player_controller.dart';
import 'controllers/publish_controller.dart';
import 'controllers/record_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/i18n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/controller_scope.dart';
import 'ui/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoxaApp());
}

class VoxaApp extends StatefulWidget {
  const VoxaApp({super.key});

  @override
  State<VoxaApp> createState() => _VoxaAppState();
}

class _VoxaAppState extends State<VoxaApp> {
  ThemeController? _theme;
  AuthController? _auth;
  SettingsController? _settings;
  DownloadsController? _downloads;
  late final FeedController _feed;
  late final PlayerController _player;
  late final RecordController _record;
  late final EditController _edit;
  late final PublishController _publish;
  late final SearchController _search;
  late final CompareController _compare;
  late final NotificationsController _notifications;
  late final InsightsController _insights;
  late final CommunityController _community;
  late final AchievementsController _achievements;

  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _feed = FeedController();
    _player = PlayerController();
    _record = RecordController();
    _edit = EditController();
    _publish = PublishController();
    _search = SearchController();
    _compare = CompareController();
    _notifications = NotificationsController();
    _insights = InsightsController();
    _community = CommunityController();
    _achievements = AchievementsController();
    _loadAsync();
  }

  Future<void> _loadAsync() async {
    final theme = await ThemeController.load();
    final auth = await AuthController.load();
    final settings = await SettingsController.load();
    final downloads = await DownloadsController.load();
    setState(() {
      _theme = theme;
      _auth = auth;
      _settings = settings;
      _downloads = downloads;
      _ready = true;
    });
    await _feed.refresh();
    await _notifications.ensureLoaded();
    await _insights.ensureLoaded();
    await _community.ensureLoaded();
    await _achievements.ensureLoaded();
  }

  @override
  void dispose() {
    _feed.dispose();
    _downloads?.dispose();
    _notifications.dispose();
    _insights.dispose();
    _community.dispose();
    _achievements.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready ||
        _theme == null ||
        _auth == null ||
        _settings == null ||
        _downloads == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
      );
    }

    final themeController = _theme!;
    final authController = _auth!;
    final settingsController = _settings!;

    return ControllerScope(
      theme: themeController,
      auth: authController,
      feed: _feed,
      player: _player,
      record: _record,
      edit: _edit,
      publish: _publish,
      search: _search,
      downloads: _downloads!,
      compare: _compare,
      settings: settingsController,
      notifications: _notifications,
      insights: _insights,
      community: _community,
      achievements: _achievements,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[themeController, settingsController]),
        builder: (context, _) {
          final locale = Locale(settingsController.state.languageCode);
          final themeData = ThemeTokens.createTheme(
            dark: themeController.isDark,
            seed: themeController.primaryColor,
          );
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Voxa',
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: themeData,
            darkTheme: ThemeTokens.createTheme(
              dark: true,
              seed: themeController.primaryColor,
            ),
            themeMode: themeController.isDark ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: (settings) =>
                AppRouter.onGenerateRoute(settings, authController),
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
