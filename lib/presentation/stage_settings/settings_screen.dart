import 'package:flutter/material.dart';
// 필요한 상수 파일 직접 import
import '../../core/constants/stage_constants.dart'; // stageList 사용 (정확히는 stageNameList getter)

import 'settings_screen_ui.dart';
import '../../core/services/settings_service.dart';


class SettingsScreen extends StatefulWidget {
  final bool isSetupMode; // 최초 설정 모드 여부
  const SettingsScreen({super.key, this.isSetupMode = false}); // 기본값 false

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _teamLevelController;
  late TextEditingController _dalgijiLevelController;
  late Map<String, TextEditingController> _clearTimeControllers;

  String? _selectedVipLevel;
  late Map<String, String?> _selectedJjolCounts;

  @override
  void initState() {
    super.initState();

    _teamLevelController = TextEditingController();
    _dalgijiLevelController = TextEditingController();
    // stageNameList는 stage_constants.dart에서 가져옴
    _clearTimeControllers = {
      for (var stage in stageNameList) stage: TextEditingController()
    };
    _selectedJjolCounts = { for (var stage in stageNameList) stage: null };

    // SettingsService에서 초기 설정값 로드
    // SettingsService.instance.loadAllSettings()는 LoadingScreen에서 이미 호출됨.
    // 따라서 여기서는 로드된 값을 바로 사용.
    final initialSettings = SettingsService.instance.stageSettings;
    _teamLevelController.text = initialSettings.teamLevel ?? '';
    _dalgijiLevelController.text = initialSettings.dalgijiLevel ?? '';
    _selectedVipLevel = initialSettings.vipLevel;
    initialSettings.stageClearTimes.forEach((stage, time) {
      // stageNameList에 없는 stage 키가 initialSettings에 있을 수 있으므로 확인
      if (_clearTimeControllers.containsKey(stage)) {
        _clearTimeControllers[stage]?.text = time ?? '';
      }
    });
    // stageJjolCounts도 마찬가지로 확인
    initialSettings.stageJjolCounts.forEach((stage, count) {
      if (_selectedJjolCounts.containsKey(stage)) {
        _selectedJjolCounts[stage] = count;
      }
    });
  }

  // --- 자동 저장을 위한 dispose 메소드 추가 ---
  @override
  void dispose() {
    // 자동 저장 로직 제거: 명시적인 저장 버튼을 통해서만 저장되도록 합니다.

    // 기존 컨트롤러 dispose 로직
    _teamLevelController.dispose();
    _dalgijiLevelController.dispose();
    _clearTimeControllers.forEach((_, controller) => controller.dispose());
    super.dispose(); // 항상 super.dispose()를 마지막에 호출합니다.
  }
  // --- 자동 저장 로직 끝 ---

  Future<void> _saveSettings({bool showSnackbar = true}) async {
    // 현재 컨트롤러의 값을 가져와 StageSettings 객체를 만들고 저장합니다.
    Map<String, String?> currentJjolCounts = Map.from(_selectedJjolCounts);
    Map<String, String?> currentClearTimes = {};
    _clearTimeControllers.forEach((stage, controller) {
      currentClearTimes[stage] = controller.text;
    });

    final currentSettings = StageSettings(
      teamLevel: _teamLevelController.text, // 문자열로 저장
      dalgijiLevel: _dalgijiLevelController.text, // 문자열로 저장
      vipLevel: _selectedVipLevel,
      stageClearTimes: currentClearTimes,
      stageJjolCounts: currentJjolCounts,
    );

    // SettingsService의 saveStageSettings는 내부적으로 메모리 캐시도 업데이트합니다.
    await SettingsService.instance.saveStageSettings(currentSettings);

    if (showSnackbar && mounted) { // SnackBar 표시는 옵션으로 제어
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정이 저장되었습니다.')),
      );
    }
  }

  void _handleSavePressed() {
     if (_formKey.currentState?.validate() ?? false) { // 명시적 저장 시에는 유효성 검사
        _saveSettings(showSnackbar: true); // 저장 버튼 클릭 시에는 SnackBar 표시
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('입력 값을 확인해주세요.')),
          );
        }
      }
  }

  void _resetFormFields() {
    setState(() {
      _teamLevelController.clear();
      _dalgijiLevelController.clear();
      _clearTimeControllers.forEach((_, controller) => controller.clear());
      _selectedVipLevel = null;
      _selectedJjolCounts.updateAll((_, __) => null);
    });
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('입력 정보가 초기화되었습니다.')),
       );
     }
  }

  void _handleResetPressed() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('초기화 확인'),
          content: const Text('화면에 입력된 정보를 모두 지우시겠습니까?\n(저장 버튼을 누르기 전까지는 실제 설정이 변경되지 않습니다.)'),
          actions: <Widget>[
            TextButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('YES'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _resetFormFields();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // SettingsScreenUI는 Scaffold를 포함하고 있으므로,
    // SettingsScreen이 별도의 Scaffold를 가질 필요는 없습니다.
    // SettingsScreenUI에 Drawer와 AppBar가 이미 구성되어 있습니다.
    return SettingsScreenUI(
      formKey: _formKey,
      teamLevelController: _teamLevelController,
      dalgijiLevelController: _dalgijiLevelController,
      clearTimeControllers: _clearTimeControllers,
      selectedVipLevel: _selectedVipLevel,
      selectedJjolCounts: _selectedJjolCounts,
      onVipLevelChanged: (value) {
        setState(() { _selectedVipLevel = value; });
      },
      onJjolCountChanged: (stageName, value) {
         setState(() { _selectedJjolCounts[stageName] = value; });
      },
      onSavePressed: _handleSavePressed,
      onResetPressed: _handleResetPressed,
      // onMenuPressed 콜백은 SettingsScreenUI 내부에서 Drawer를 열도록 수정되었으므로
      // 여기서는 전달할 필요가 없습니다.
      isSetupMode: widget.isSetupMode, // isSetupMode 전달
    );
  }
}