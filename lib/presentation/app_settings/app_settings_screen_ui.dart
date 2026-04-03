import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goh_calculator/core/widgets/liquid_glass.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchGivenUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$url 링크를 열 수 없습니다.')),
      );
    }
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isEmail = false,
    String? urlToLaunch,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: effectiveOnTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEmail || urlToLaunch != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10),
                  child: Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 600.0;

    final listViewContent = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                '표시 설정',
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SwitchListTile(
                  title: const Text('다크 모드'),
                  value: isDarkModeEnabled,
                  onChanged: onDarkModeChanged,
                  secondary: Icon(
                    isDarkModeEnabled
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 18),
              Text('글자 크기 조절', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Slider(
                value: currentFontSizeMultiplier,
                min: 0.5,
                max: 1.5,
                divisions: 10,
                label:
                    '${(currentFontSizeMultiplier * 100).toStringAsFixed(0)}%',
                onChanged: onFontSizeMultiplierChanged,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '현재 배율 ${(currentFontSizeMultiplier * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                '미리보기',
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('작은 안내 문구 예시입니다.', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 10),
                    Text(
                      '중간 본문 텍스트 예시입니다. 계산 결과나 설명 문구에 사용됩니다.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text('섹션 제목 예시', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Text('강조 제목 예시', style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                '앱 정보',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                icon: Icons.people_outline,
                title: '도움 주신 분들',
                subtitle:
                    '세계는스몰 님, PDL힉센 님, 貪민서 님, Hebi 님, 뮤즈 님, Fractal 님, 뽀짝 님, 공명 님 ,貪벨리알 님, 모리님, 용제님, 기타 많은 분들...',
              ),
              Divider(color: theme.dividerTheme.color),
              _buildInfoTile(
                context,
                icon: Icons.person_outline,
                title: '개발자',
                subtitle: '뮤',
              ),
              Divider(color: theme.dividerTheme.color),
              _buildInfoTile(
                context,
                icon: Icons.email_outlined,
                title: '개발자 이메일',
                subtitle: 'Hikari.haneul@gmail.com',
                isEmail: true,
              ),
              Divider(color: theme.dividerTheme.color),
              _buildInfoTile(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                title: '카카오톡 문의',
                subtitle: '오픈채팅방 바로가기',
                urlToLaunch: 'https://open.kakao.com/o/si5AGbyh',
              ),
              Divider(color: theme.dividerTheme.color),
              _buildInfoTile(
                context,
                icon: Icons.info_outline,
                title: '앱 버전',
                subtitle: appVersion,
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 설정'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: screenWidth > maxContentWidth
              ? Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: maxContentWidth),
                    child: listViewContent,
                  ),
                )
              : listViewContent,
        ),
      ),
    );
  }
}
