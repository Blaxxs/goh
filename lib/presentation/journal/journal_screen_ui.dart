import 'package:flutter/material.dart';
// 날짜 포맷팅을 위해 필요
import 'package:flutter/services.dart'; // 숫자 입력 제한을 위해 필요
import 'package:dropdown_button2/dropdown_button2.dart'; // 향상된 드롭다운 사용
import '../../core/constants/stage_constants.dart'; // 스테이지 목록을 위해 필요
import '../../data/models/journal_entry.dart'; // JournalEntry 모델 import

class AddJournalDialog extends StatefulWidget {
  final DateTime initialDate; // 캘린더에서 선택된 초기 날짜

  const AddJournalDialog({super.key, required this.initialDate});

  @override
  State<AddJournalDialog> createState() => _AddJournalDialogState();
}

class _AddJournalDialogState extends State<AddJournalDialog> {
  // 날짜 선택 기능 제거로 _dateController 및 _selectedDate 제거
  String? _selectedStage;
  late TextEditingController _consumedSoulStonesController;
  late TextEditingController _earnedSoulStonesController;
  late TextEditingController _goldDemonCountController; // 돈악마 개수 컨트롤러
  late TextEditingController _earnedGoldController; // 획득 골드 컨트롤러

  @override
  void initState() {
    super.initState();
    _consumedSoulStonesController = TextEditingController();
    _earnedSoulStonesController = TextEditingController();
    _goldDemonCountController = TextEditingController();
    _earnedGoldController = TextEditingController();
  }

  @override
  void dispose() {
    _consumedSoulStonesController.dispose();
    _earnedSoulStonesController.dispose();
    _goldDemonCountController.dispose();
    _earnedGoldController.dispose();
    super.dispose();
  }

  // 일지 저장 (현재는 콘솔 출력 및 다이얼로그 닫기만 구현)
  void _saveJournalEntry() {
    if (_selectedStage == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스테이지를 선택해주세요.')),
      );
      return;
    }

    final int? consumedSoulStones = int.tryParse(_consumedSoulStonesController.text);
    if (consumedSoulStones == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소모 영혼석을 올바른 숫자로 입력해주세요.')),
      );
      return;
    }

    final int? earnedSoulStones = int.tryParse(_earnedSoulStonesController.text);
    if (earnedSoulStones == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('획득 영혼석을 올바른 숫자로 입력해주세요.')),
      );
      return;
    }

    // 획득 골드 및 돈악마 개수 파싱 (입력 안했으면 0으로 처리)
    final int earnedGold = int.tryParse(_earnedGoldController.text) ?? 0;
    final int earnedGoldDemons = int.tryParse(_goldDemonCountController.text) ?? 0;

    // 유효성 검사 (선택적: 음수 입력 방지 등)
    // if (earnedGold < 0 || earnedGoldDemons < 0) {
    //   // ... 오류 메시지 표시 ...
    // }

    // JournalEntry 객체 생성
    final newEntry = JournalEntry(
      date: widget.initialDate, // 초기 날짜는 위젯의 initialDate 사용
      stage: _selectedStage!,
      consumedSoulStones: consumedSoulStones,
      earnedSoulStones: earnedSoulStones,
      earnedGold: earnedGold, // 파싱된 값 전달
      earnedGoldDemons: earnedGoldDemons, // 파싱된 값 전달
    );

    debugPrint('일지 저장 시도:');
    debugPrint('날짜: ${newEntry.date}');
    debugPrint('스테이지: ${newEntry.stage}');
    debugPrint('소모 영혼석: ${newEntry.consumedSoulStones}');
    debugPrint('획득 영혼석: ${newEntry.earnedSoulStones}');
    debugPrint('획득 골드: ${newEntry.earnedGold}');
    debugPrint('획득 돈악마: ${newEntry.earnedGoldDemons}');
    debugPrint('순수 영혼석: ${newEntry.netSoulStones}');

    Navigator.of(context).pop(newEntry); // 생성된 JournalEntry 객체 반환
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 현재 테마 가져오기
    final List<String> stageNames = stageNameList; // 스테이지 이름 목록

    return AlertDialog(
      title: const Text('일지 추가', textAlign: TextAlign.center),
      actions: <Widget>[
        TextButton( // 취소 버튼
          child: const Text('취소'),
          onPressed: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
        ),
        ElevatedButton(
          onPressed: _saveJournalEntry,
          child: const Text('저장'), // 저장 함수 호출
        ),
      ],
      content: SizedBox( // 얼럿의 가로 길이를 30% 키우기 위해 SizedBox로 감쌈
        width: MediaQuery.of(context).size.width * 0.91, // 화면 너비의 약 91% (기존 70%에서 30% 증가)
        child: SingleChildScrollView( // 내용이 길어질 경우 스크롤 가능하도록
          child: Column(
            mainAxisSize: MainAxisSize.min, // 컬럼 크기를 내용에 맞게 조절
            crossAxisAlignment: CrossAxisAlignment.start, // 자식 위젯들을 왼쪽으로 정렬
            children: [
              DropdownButtonFormField2<String>(
                decoration: InputDecoration(
                  labelText: '스테이지',
                  labelStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
                    fontSize: (theme.inputDecorationTheme.labelStyle?.fontSize ?? 16.0) * 0.8, // 폰트 크기 20% 감소
                  ),
                  border: OutlineInputBorder( // border는 decoration 안에 있어야 합니다.
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  isDense: true, // isDense는 decoration 안에 있어야 합니다.
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.4, horizontal: 12.0), // contentPadding은 decoration 안에 있어야 합니다.
                ),
                isExpanded: true, // isExpanded는 DropdownButtonFormField2의 직접적인 매개변수입니다.
                hint: Center( // hint도 DropdownButtonFormField2의 직접적인 매개변수입니다.
                  child: Text(
                    '선택',
                    style: theme.inputDecorationTheme.hintStyle?.copyWith(
                      fontSize: (theme.inputDecorationTheme.hintStyle?.fontSize ?? 14.0) * 0.8, // 폰트 크기 20% 감소
                    ),
                  ),
                ),
                items: stageNames.map((String stage) { // items는 DropdownButtonFormField2의 직접적인 매개변수입니다.
                  return DropdownMenuItem<String>(
                    value: stage,
                    child: Center(child: Text(stage, overflow: TextOverflow.ellipsis)), // 아이템 텍스트 중앙 정렬
                  );
                }).toList(),
                value: _selectedStage,
                onChanged: (String? newValue) {
                  setState(() { _selectedStage = newValue; });
                },
                selectedItemBuilder: (context) { // 선택된 아이템 표시 방식 변경
                  return stageNames.map((String item) {
                    return Center(
                      child: Text(
                        _selectedStage == item ? item : '', // 선택된 아이템만 표시
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16.0) * 0.8, // 폰트 크기를 줄여서 잘림 방지
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                buttonStyleData: const ButtonStyleData(height: 23, padding: EdgeInsets.only(right: 8)), // 버튼 높이를 23으로 되돌림
                iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down, color: Colors.grey), iconSize: 24),
                dropdownStyleData: DropdownStyleData(maxHeight: 250, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), offset: const Offset(0, -4), scrollbarTheme: ScrollbarThemeData(radius: const Radius.circular(40), thickness: WidgetStateProperty.all(6), thumbVisibility: WidgetStateProperty.all(true))),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  // menuItemBuilder에서 각 Text를 Center로 감싸는 것이 더 확실할 수 있음
                ),
              ),
          
            const SizedBox(height: 16), // 간격 추가
            // 소모 영혼석 및 획득 영혼석 입력 필드를 한 행에 배치
            Row(
              children: [
                Expanded( // 남은 공간을 채우도록 확장
                  child: TextFormField(
                    controller: _consumedSoulStonesController,
                    keyboardType: TextInputType.number, // 숫자 키보드
                    textAlign: TextAlign.center, // 입력 텍스트 중앙 정렬
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 입력 가능하도록 제한
                    decoration: InputDecoration(
                      labelStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
                        fontSize: (theme.inputDecorationTheme.labelStyle?.fontSize ?? 16.0) * 0.8, // 폰트 크기 20% 감소
                      ),
                      labelText: '소모 영혼석', // 라벨 텍스트
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
                      ),
                      isDense: true, // 입력 필드 높이 줄이기
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0), // 내부 여백
                    ),
                  ),
                ),
                const SizedBox(width: 8), // 필드 사이 간격
                Expanded( // 남은 공간을 채우도록 확장
                  child: TextFormField(
                    controller: _earnedSoulStonesController,
                    keyboardType: TextInputType.number, // 숫자 키보드
                    textAlign: TextAlign.center, // 입력 텍스트 중앙 정렬
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 입력 가능하도록 제한
                    decoration: InputDecoration( // 라벨 텍스트
                      labelStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
                        fontSize: (theme.inputDecorationTheme.labelStyle?.fontSize ?? 16.0) * 0.8, // 폰트 크기 20% 감소
                      ),
                      labelText: '획득 영혼석', // 라벨 텍스트
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
                      ),
                      isDense: true, // 입력 필드 높이 줄이기
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0), // 내부 여백
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // 간격 추가
            // 획득 골드, 획득 돈악마 개수 입력 필드를 한 행에 배치 (Row 사용)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // 필드 높이가 다를 경우 상단 정렬
              children: [
                Expanded( // 획득 골드 입력 필드
                  flex: 2,
                  child: TextFormField(
                    controller: _earnedGoldController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center, // 입력 텍스트 중앙 정렬
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration( // 라벨 텍스트
                      labelStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
                        fontSize: (theme.inputDecorationTheme.labelStyle?.fontSize ?? 16.0) * 0.8, // 폰트 크기 20% 감소
                      ),
                      labelText: '획득 골드', // 라벨 텍스트
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded( // 획득 돈악마 개수 입력 필드
                  flex: 2,
                  child: TextFormField(
                    controller: _goldDemonCountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center, // 입력 텍스트 중앙 정렬
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
                        fontSize: (theme.inputDecorationTheme.labelStyle?.fontSize ?? 16.0) * 0.8, // 폰트 크기 20% 감소
                      ),
                      labelText: '획득 돈악마',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    ),
                  ),
                ),
              ],
              ),
          ],
            ), // Column
        ), // SingleChildScrollView
      ), // SizedBox
    ); // AlertDialog
  }
}