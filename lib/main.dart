import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/settings_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/global_go_back_scope.dart';
import 'firebase_options.dart';
import 'presentation/loading/loading_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization error (ignored): $e');
  }

  runApp(const MyApp());

  Future(() async {
    try {
      await initializeDateFormatting();
    } catch (e) {
      debugPrint('Date formatting init error: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              home: const LoadingScreen(),
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
