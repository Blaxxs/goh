// lib/loading_screen.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../main/main_screen.dart'; // MainScreen으로 이동하기 위함
import '../accessory/accessory_screen.dart';
import '../spirit/spirit_screen.dart';
import '../../core/services/settings_service.dart'; // 설정 로딩을 위함
import '../../core/services/web_location.dart' as web_location;
import '../../core/constants/accessory_constants.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    this.openAccessoryFromInitialUrl = false,
    this.openSpiritFromInitialUrl = false,
  });

  final bool openAccessoryFromInitialUrl;
  final bool openSpiritFromInitialUrl;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  static const int _accessoryImageWarmupCount = 72;
  static const int _spiritImageWarmupCount = 72;
  late final Future<void> _initializationFuture;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeAppFuture();
    _startBackgroundTasks();
  }

  Future<void> _initializeAppFuture() async {
    try {
      await SettingsService.instance.loadAllSettings();
    } catch (e) {
      debugPrint('설정 로딩 중 오류 발생: $e');
      rethrow;
    }
  }

  void _startBackgroundTasks() {
    Future(() async {
      try {
        await AccessoryDataManager().loadAccessories();
        await _warmupAccessoryImageCache();
        await SpiritScreen.warmupImageCache(limit: _spiritImageWarmupCount);
      } catch (e) {
        debugPrint('[LoadingScreen] Image cache warm-up error: $e');
      }
    });
  }

  Future<void> _warmupAccessoryImageCache() async {
    final urls = await AccessoryDataManager().getPrioritizedAccessoryImageUrls(
      limit: _accessoryImageWarmupCount,
    );
    if (urls.isEmpty) return;

    const batchSize = 8;
    for (int i = 0; i < urls.length; i += batchSize) {
      final batch = urls.skip(i).take(batchSize);
      await Future.wait(batch.map(_downloadWithIgnoreError));
    }
  }

  Future<void> _downloadWithIgnoreError(String url) async {
    try {
      await DefaultCacheManager().downloadFile(url);
    } catch (_) {
      // Warm-up 단계 실패는 무시하고 실제 화면 진입 시 재시도한다.
    }
  }

  bool _shouldOpenAccessoryFromDeepLink() {
    if (widget.openAccessoryFromInitialUrl) {
      return true;
    }

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

  bool _shouldOpenSpiritFromDeepLink() {
    if (widget.openSpiritFromInitialUrl) {
      return true;
    }

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

  void _navigateToMain() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      Widget destination = const MainScreen();
      if (_shouldOpenAccessoryFromDeepLink()) {
        destination = const AccessoryScreen();
      } else if (_shouldOpenSpiritFromDeepLink()) {
        destination = const SpiritScreen();
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
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
              // 성공 시: MainScreen으로 이동
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigateToMain();
              });
              return _buildLoadingUI(); // 전환 중 로딩 UI 유지
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
