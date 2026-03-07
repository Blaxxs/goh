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
    if (!enabled) {
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
