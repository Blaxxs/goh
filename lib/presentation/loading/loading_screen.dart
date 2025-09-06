// lib/loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../main/main_screen.dart'; // MainScreen으로 이동하기 위함
import '../../core/services/settings_service.dart'; // 설정 로딩을 위함

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeAppFuture();
  }

  Future<void> _initializeAppFuture() async {
    try {
      // 설정 로딩과 최소 시간 보장을 동시에 기다림
      await Future.wait([
        SettingsService.instance.loadAllSettings(),
        Future.delayed(const Duration(milliseconds: 3000)) // 로고 최소 표시 시간 (예시)
      ]);
    } catch (e) {
      // 에러 처리 (예: 로그 출력)
      debugPrint('설정 로딩 중 오류 발생: $e');
      // 에러를 다시 던져서 FutureBuilder가 error 상태를 처리하도록 함
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // Future 상태 확인
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            // 로딩 중일 때: 로딩 UI 표시
            return _buildLoadingUI();

          case ConnectionState.done:
            // 작업 완료 시
            if (snapshot.hasError) {
              // 에러 발생 시: 에러 UI 표시
              return _buildErrorUI(snapshot.error);
            } else {
              // 성공 시: MainScreen 반환
              return const MainScreen();
            }
        }
      },
    );
  }

  // 로딩 UI 생성 헬퍼 위젯
  Widget _buildLoadingUI() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/loading_logo.png', // 이미지 경로 확인 필요
              width: 300, // 예시 크기
              height: 300, // 예시 크기
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text("데이터를 로딩 중입니다..."),
          ],
        ),
      ),
    );
  }

  // 에러 UI 생성 헬퍼 위젯
  Widget _buildErrorUI(Object? error) {
     return Scaffold(
       body: Center(
         child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.error_outline, color: Colors.red, size: 60),
               const SizedBox(height: 20),
               const Text(
                 '앱 초기화 중 오류가 발생했습니다.',
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 10),
               Text(
                 error.toString(), // 실제 에러 메시지 표시
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 20),
               ElevatedButton(
                 onPressed: () {
                   // 오류 발생 시에도 기본값으로 메인 화면 이동 시도
                   Navigator.pushReplacement(
                     context,
                     MaterialPageRoute(builder: (_) => const MainScreen()),
                   );
                 },
                 child: const Text('기본값으로 계속하기'),
               )
             ],
           ),
         ),
       ),
     );
   }
}