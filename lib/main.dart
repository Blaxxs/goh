import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/settings_service.dart';
import 'core/services/web_location.dart' as web_location;
import 'core/theme/app_theme.dart';
import 'core/widgets/global_go_back_scope.dart';
import 'firebase_options.dart';
import 'presentation/loading/loading_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

bool _shouldOpenAccessoryFromInitialUrl() {
  if (!kIsWeb) {
    return false;
  }

  final initialRoute = WidgetsBinding
      .instance.platformDispatcher.defaultRouteName
      .trim()
      .toLowerCase();
  final fragment = Uri.base.fragment.trim().toLowerCase();
  final path = Uri.base.path.trim().toLowerCase();
  final fullUrl = Uri.base.toString().toLowerCase();
  final openQuery =
      Uri.base.queryParameters['open']?.trim().toLowerCase() ?? '';
  final rawHref = web_location.currentHref().trim().toLowerCase();
  final rawHash = web_location.currentHash().trim().toLowerCase();

  return initialRoute == '/accessory' ||
      openQuery == 'accessory' ||
      fragment == '/accessory' ||
      fragment == 'accessory' ||
      path.endsWith('/accessory') ||
      fullUrl.contains('#/accessory') ||
      fullUrl.contains('/accessory') ||
      rawHash == '#/accessory' ||
      rawHash == '#accessory' ||
      rawHref.contains('#/accessory');
}

bool _shouldOpenSpiritFromInitialUrl() {
  if (!kIsWeb) {
    return false;
  }

  final initialRoute = WidgetsBinding
      .instance.platformDispatcher.defaultRouteName
      .trim()
      .toLowerCase();
  final fragment = Uri.base.fragment.trim().toLowerCase();
  final path = Uri.base.path.trim().toLowerCase();
  final fullUrl = Uri.base.toString().toLowerCase();
  final openQuery =
      Uri.base.queryParameters['open']?.trim().toLowerCase() ?? '';
  final rawHref = web_location.currentHref().trim().toLowerCase();
  final rawHash = web_location.currentHash().trim().toLowerCase();

  return initialRoute == '/spirit' ||
      openQuery == 'spirit' ||
      fragment == '/spirit' ||
      fragment == 'spirit' ||
      path.endsWith('/spirit') ||
      fullUrl.contains('#/spirit') ||
      fullUrl.contains('/spirit') ||
      rawHash == '#/spirit' ||
      rawHash == '#spirit' ||
      rawHref.contains('#/spirit');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final openAccessoryFromInitialUrl = _shouldOpenAccessoryFromInitialUrl();
  final openSpiritFromInitialUrl = _shouldOpenSpiritFromInitialUrl();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization error (ignored): $e');
  }

  runApp(MyApp(
    openAccessoryFromInitialUrl: openAccessoryFromInitialUrl,
    openSpiritFromInitialUrl: openSpiritFromInitialUrl,
  ));

  Future(() async {
    try {
      await initializeDateFormatting();
    } catch (e) {
      debugPrint('Date formatting init error: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.openAccessoryFromInitialUrl,
    this.openSpiritFromInitialUrl = false,
  });

  final bool openAccessoryFromInitialUrl;
  final bool openSpiritFromInitialUrl;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingsService.instance.themeModeNotifier,
      builder: (_, ThemeMode currentThemeMode, __) {
        return ValueListenableBuilder<double>(
          valueListenable: SettingsService.instance.fontSizeNotifier,
          builder: (_, double currentFontSizeMultiplier, __) {
            return MaterialApp(
              navigatorKey: appNavigatorKey,
              title: 'GOH Calculator',
              theme: AppTheme.buildTheme(
                brightness: Brightness.light,
                fontSizeMultiplier: currentFontSizeMultiplier,
              ),
              darkTheme: AppTheme.buildTheme(
                brightness: Brightness.dark,
                fontSizeMultiplier: currentFontSizeMultiplier,
              ),
              themeMode: currentThemeMode,
              home: LoadingScreen(
                openAccessoryFromInitialUrl: openAccessoryFromInitialUrl,
                openSpiritFromInitialUrl: openSpiritFromInitialUrl,
              ),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ko', 'KR'),
                Locale('en', 'US'),
              ],
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                if (child == null) {
                  return const SizedBox.shrink();
                }

                final mediaQuery = MediaQuery.of(context);
                return GlobalGoBackScope(
                  navigatorKey: appNavigatorKey,
                  child: MediaQuery(
                    data: mediaQuery.copyWith(
                      textScaler: TextScaler.linear(currentFontSizeMultiplier),
                    ),
                    child: child,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
