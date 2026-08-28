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

  final initialRoute =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final openAccessoryFromInitialUrl = _shouldOpenAccessoryFromInitialUrl();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization error (ignored): $e');
  }

  runApp(MyApp(openAccessoryFromInitialUrl: openAccessoryFromInitialUrl));

  Future(() async {
    try {
      await initializeDateFormatting();
    } catch (e) {
      debugPrint('Date formatting init error: $e');
    }
  });
}

class _AppThemeToggle extends StatelessWidget {
  const _AppThemeToggle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingsService.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        final enabled = themeMode == ThemeMode.dark;

        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withAlpha(110)
                      : Colors.white.withAlpha(170),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(24)
                        : Colors.black.withAlpha(20),
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          enabled ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          size: 16,
                          color: enabled ? const Color(0xFFFFD76A) : const Color(0xFF7A5C00),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          enabled ? '다크' : '화이트',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Switch.adaptive(
                          value: enabled,
                          onChanged: (value) {
                            final nextSettings = SettingsService.instance.appSettings.copyWith(
                              isDarkModeEnabled: value,
                            );
                            SettingsService.instance.saveAppSettings(nextSettings);
                          },
                          activeColor: const Color(0xFF7EA7FF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.openAccessoryFromInitialUrl,
  });

  final bool openAccessoryFromInitialUrl;

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
                    child: Stack(
                      children: [
                        child,
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: _AppThemeToggle(),
                        ),
                      ],
                    ),
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
