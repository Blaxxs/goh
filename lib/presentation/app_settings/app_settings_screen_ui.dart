// lib/presentation/app_settings/app_settings_screen_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard 사용을 위해 임포트
import 'package:url_launcher/url_launcher.dart'; // URL 실행을 위해 임포트

// 이 클래스는 UI 표현만을 담당합니다.
class AppSettingsScreenUI extends StatelessWidget {
  final bool isDarkModeEnabled;
  final ValueChanged<bool> onDarkModeChanged;
  final double currentFontSizeMultiplier;
  final ValueChanged<double> onFontSizeMultiplierChanged;
  final String appVersion;

  const AppSettingsScreenUI({
    super.key,
    required this.isDarkModeEnabled,
    required this.onDarkModeChanged,
    required this.currentFontSizeMultiplier,
    required this.onFontSizeMultiplierChanged,
    required this.appVersion,
  });

  // URL 실행을 위한 헬퍼 함수
  Future<void> _launchGivenUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication); // 외부 앱으로 실행
    } else {
      // 에러 처리: 스낵바 등으로 사용자에게 알림
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$url 링크를 열 수 없습니다.')),
        );
      }
    }
  }

  // 정보 항목을 만드는 ListTile 스타일의 헬퍼 위젯
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isEmail = false, // 이메일 복사 기능을 위한 플래그
    String? urlToLaunch,   // URL 링크 기능을 위한 파라미터
  }) {
    final theme = Theme.of(context);
    VoidCallback? effectiveOnTap;
    
    if (isEmail) {
      effectiveOnTap = () async {
        await Clipboard.setData(ClipboardData(text: subtitle));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이메일 주소가 복사되었습니다.')),
          );
        }
      };
    } else if (urlToLaunch != null) {
      effectiveOnTap = () => _launchGivenUrl(context, urlToLaunch);
    }

    return ListTile(
      // ignore: deprecated_member_use
      leading: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.85)), // 아이콘 색상을 onSurface 색상으로 변경하여 가독성 개선
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyLarge?.color,
        )
      ),
      subtitle: Text( // 이메일의 경우에도 subtitle은 Text로 표시하고, 탭 액션으로 복사
          subtitle,
          // ignore: deprecated_member_use
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.9)),
          softWrap: true,
        ),
      onTap: effectiveOnTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      dense: true,
      // 아이콘 색상을 다크 모드에서 더 눈에 띄는 색상으로 변경
      trailing: (isEmail || urlToLaunch != null)
          // ignore: deprecated_member_use
          ? Icon(
              Icons.open_in_new_rounded,
              size: 18,
              // ignore: deprecated_member_use
              color: theme.brightness == Brightness.dark ? theme.colorScheme.error : theme.colorScheme.primary.withOpacity(0.7), // 다크 모드에서 테마의 오류 색상(어두운 빨간색) 사용
            )
          : null, // 이메일 또는 링크인 경우에만 아이콘 표시
    );
  }

  @override  
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 600;

    Widget listViewContent = ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SwitchListTile(
            title: const Text('다크 모드'),
            value: isDarkModeEnabled,
            onChanged: onDarkModeChanged,
            secondary: Icon(
              isDarkModeEnabled ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
        const Divider(indent: 24, endIndent: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
          child: Text(
            '글자 크기 조절',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Slider(
            value: currentFontSizeMultiplier,
            min: 0.5, // 최소값 50%
            max: 1.5, // 최대값 150%
            divisions: 10, // 0.5에서 1.5까지 0.1 단위로 조절 (10개 구간)
            label: "${(currentFontSizeMultiplier * 100).toStringAsFixed(0)}%",
            onChanged: onFontSizeMultiplierChanged,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '현재 배율: ${(currentFontSizeMultiplier * 100).toStringAsFixed(0)}%',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const Divider(height: 32.0, indent: 24, endIndent: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 8.0),
          child: Text(
            '글자 크기 예시',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('작은 글씨 예시입니다. (Body Small)', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text('중간 크기 글씨 예시입니다. 가나다라 ABC 123 (Body Medium)', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('큰 글씨 예시입니다. 설정 및 제목 등 (Title Medium)', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('더 큰 제목 예시입니다. (Title Large)', style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 32.0, indent: 24, endIndent: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                    child: Text(
                      '앱 정보',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary, // "앱 정보" 제목 색상을 Secondary 색상으로 변경
                      ),
                    ),
                  ),
                  _buildInfoTile(
                    context,
                    icon: Icons.people_outline,
                    title: '도움 주신 분들',
                    subtitle: '세계는스몰 님, PDL힉센 님, 貪민서 님, Hebi 님, 뮤즈 님, Fractal 님, 뽀짝 님, 공명 님 ,貪벨리알 님, 기타 많은 분들...',
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  _buildInfoTile(
                    context,
                    icon: Icons.person_outline,
                    title: '개발자',
                    subtitle: '뮤',
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  _buildInfoTile(
                    context,
                    icon: Icons.email_outlined,
                    title: '개발자 이메일', // 제목 수정
                    subtitle: 'Hikari.haneul@gmail.com',
                    isEmail: true, // 이메일 복사 기능 활성화
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  _buildInfoTile( // 카카오톡 링크 추가
                    context,
                    icon: Icons.chat_bubble_outline_rounded, // 카카오톡 유사 아이콘 또는 다른 적절한 아이콘
                    title: '카카오톡 문의',
                    subtitle: '오픈채팅방 바로가기', // 링크 대신 표시될 텍스트
                    urlToLaunch: 'https://open.kakao.com/o/si5AGbyh', // 실제 링크
                  ),
                   const Divider(height: 1, indent: 24, endIndent: 24),
                  _buildInfoTile(
                    context,
                    icon: Icons.info_outline,
                    title: '앱 버전',
                    subtitle: appVersion,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 설정'),
      ),
      body: SafeArea(
        child: (screenWidth > maxContentWidth)
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: listViewContent,
                ),
              )
            : listViewContent,
      ),
    );
  }
}