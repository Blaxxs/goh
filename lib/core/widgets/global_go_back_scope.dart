import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalGoBackScope extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalGoBackScope({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<GlobalGoBackScope> createState() => _GlobalGoBackScopeState();
}

class _GlobalGoBackScopeState extends State<GlobalGoBackScope> {
  DateTime? _lastBackPressed;

  void _showExitHint() {
    final context = widget.navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('뒤로가기 버튼을 한 번 더 누르면 종료됩니다.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _exitApp() async {
    if (kIsWeb) {
      final context = widget.navigatorKey.currentContext;
      if (context == null) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('웹/PWA 환경은 브라우저 또는 시스템 제스처로 종료됩니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final navigator = widget.navigatorKey.currentState;
        if (navigator == null) {
          return;
        }

        // 다이얼로그/드로어/직전 화면이 있으면 항상 한 단계 뒤로 이동.
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }

        // 루트(메인)에서는 2회 뒤로가기 후 종료.
        final now = DateTime.now();
        const threshold = Duration(seconds: 2);
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > threshold) {
          _lastBackPressed = now;
          _showExitHint();
          return;
        }

        await _exitApp();
      },
      child: widget.child,
    );
  }
}
