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

    // Gemini 권장 패턴: canPop=false로 기본 동작 차단 후 Navigator 스택 체크
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        final navigator = Navigator.of(context);
        // 내부 스택에 페이지가 있으면 뒤로가기
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          // 스택이 비어있으면 메인 화면으로
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      },
      child: child,
    );
  }
}
