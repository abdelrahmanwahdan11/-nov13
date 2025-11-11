import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/auth_controller.dart';
import 'controllers/compare_controller.dart';
import 'controllers/edit_controller.dart';
import 'controllers/feed_controller.dart';
import 'controllers/player_controller.dart';
import 'controllers/publish_controller.dart';
import 'controllers/record_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/downloads_controller.dart';
import 'controllers/notifications_controller.dart';
import 'core/i18n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/controller_scope.dart';

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

  Locale? _locale;

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
    _loadAsync();
  }

  Future<void> _loadAsync() async {
    final theme = await ThemeController.load();
    final auth = await AuthController.load();
    final settings = await SettingsController.load();
    final downloads = await DownloadsController.load();
    theme.addListener(_onThemeChanged);
    settings.addListener(_onSettingsChanged);
    setState(() {
      _theme = theme;
      _auth = auth;
      _settings = settings;
      _downloads = downloads;
      _locale = Locale(settings.state.languageCode);
    });
    await _feed.refresh();
    await _notifications.ensureLoaded();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _onSettingsChanged() {
    final locale = Locale(_settings!.state.languageCode);
    if (locale != _locale && mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  void dispose() {
    _theme?.removeListener(_onThemeChanged);
    _settings?.removeListener(_onSettingsChanged);
    _feed.dispose();
    _downloads?.dispose();
    _notifications.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_theme == null ||
        _auth == null ||
        _settings == null ||
        _locale == null ||
        _downloads == null) {
      return const MaterialApp(home: SizedBox.shrink());
    }

    final themeController = _theme!;
    final themeData = ThemeTokens.createTheme(
      dark: themeController.isDark,
      seed: themeController.primaryColor,
    );

    return ControllerScope(
      theme: themeController,
      auth: _auth!,
      feed: _feed,
      player: _player,
      record: _record,
      edit: _edit,
      publish: _publish,
      search: _search,
      downloads: _downloads!,
      compare: _compare,
      settings: _settings!,
      notifications: _notifications,
      child: AnimatedBuilder(
        animation: Listenable.merge([themeController, _settings!]),
        builder: (context, _) {
          final locale = Locale(_settings!.state.languageCode);
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
            onGenerateRoute: (settings) =>
                AppRouter.onGenerateRoute(settings, ControllerScope.of(context).auth),
            initialRoute: '/splash',
          );
        },
      ),
    );
  }
}
