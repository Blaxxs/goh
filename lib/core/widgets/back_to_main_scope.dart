import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../presentation/main/main_screen.dart';

class BackToMainScope extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const BackToMainScope({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 웹 환경에서는 브라우저 히스토리 관리를 위해 비활성화
    if (!enabled || kIsWeb) {
      return child;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }

        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      },
      child: child,
    );
  }
}
