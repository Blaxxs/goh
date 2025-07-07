// lib/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // 숫자 포맷팅을 위해 추가
import '../../core/constants/box_constants.dart'; // AppScreen enum을 위해 추가
import '../../core/widgets/app_drawer.dart'; // AppDrawer 및 AppScreen enum 사용
import 'journal_screen_ui.dart'; // 일지 추가 다이얼로그 import\
import '../../data/models/journal_entry.dart'; // JournalEntry 모델 import
import '../../core/services/settings_service.dart'; // SettingsService import
import '../../core/constants/stage_constants.dart';      // stageBaseData 사용
import '../../core/constants/drop_item_constants.dart'; // DropInfo, DropCategory, goldDemonSellPrices 사용
import 'package:flutter_slidable/flutter_slidable.dart'; // flutter_slidable import 추가

// 점유율 표시 타입을 위한 Enum
enum JournalShareType { soulStone, gold }

const String _soulStoneLabel = '영혼석';
const String _goldLabel = '골드';
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 점유율 표시 관련 상태 변수
  JournalShareType _currentShareType = JournalShareType.soulStone;
  double _totalMonthSoulStones = 0.0;
  double _totalMonthGold = 0.0;
  Map<String, double> _monthlyStageSoulStoneSharesPercent = {};
  Map<String, double> _monthlyStageGoldSharesPercent = {};
  Map<String, double> _monthlyStageSoulStoneSums = {}; // 스테이지별 월간 영혼석 합계 (절대값)
  Map<String, double> _monthlyStageGoldSums = {};    // 스테이지별 월간 골드 합계 (절대값)
  late StartingDayOfWeek _startingDayOfWeek; // 캘린더 시작 요일 상태 변수

  @override
  void initState() {
    super.initState();
        debugPrint('[JournalScreenState] initState called.');
    _selectedDay = _focusedDay;
    _startingDayOfWeek = SettingsService.instance.appSettings.startingDayOfWeek; // 초기값 로드
    _updateMonthlyTotalsAndShares(); // 초기 점유율 계산
  }

  // JournalEntry의 최종 골드를 계산하는 헬퍼 함수
  double _calculateFinalGoldForEntry(JournalEntry entry) {
    double finalGold = entry.earnedGold.toDouble();
    final stageDataForEntry = stageBaseData[entry.stage];
    if (stageDataForEntry != null) {
      final List<dynamic>? dropsDynamic = stageDataForEntry['drops'] as List<dynamic>?;
      if (dropsDynamic != null) {
        final List<DropInfo> drops = dropsDynamic.whereType<DropInfo>().toList();
        final int goldDemonDropIndex = drops.indexWhere((d) => d.category == DropCategory.goldDemon && goldDemonSellPrices.containsKey(d.itemId));
        final DropInfo? goldDemonDrop = (goldDemonDropIndex != -1) ? drops[goldDemonDropIndex] : null;

        if (goldDemonDrop != null) {
          final int demonPrice = goldDemonSellPrices[goldDemonDrop.itemId] ?? 0;
          finalGold += (entry.earnedGoldDemons * demonPrice);
        }
      }
    }
    return finalGold;
  }

  // 월별 총계 및 스테이지별 점유율 계산
  Future<void> _updateMonthlyTotalsAndShares() async {
    if (!mounted) return;

    final DateTime monthToProcess = DateTime(_focusedDay.year, _focusedDay.month);
    List<JournalEntry> allEntries = SettingsService.instance.getAllJournalEntries();
    List<JournalEntry> monthEntries = allEntries.where((entry) {
      return entry.date.year == monthToProcess.year && entry.date.month == monthToProcess.month;
    }).toList();

    double currentMonthTotalSoulStones = 0;
    double currentMonthTotalGold = 0;
    Map<String, double> stageSoulStoneSums = {};
    Map<String, double> stageGoldSums = {};

    for (var entry in monthEntries) {
      currentMonthTotalSoulStones += entry.netSoulStones;
      double entryFinalGold = _calculateFinalGoldForEntry(entry);
      currentMonthTotalGold += entryFinalGold;

      stageSoulStoneSums[entry.stage] = (stageSoulStoneSums[entry.stage] ?? 0) + entry.netSoulStones;
      stageGoldSums[entry.stage] = (stageGoldSums[entry.stage] ?? 0) + entryFinalGold;
    }

    Map<String, double> ssShares = {};
    if (currentMonthTotalSoulStones.abs() > 0.001) {
      stageSoulStoneSums.forEach((stage, sum) {
        ssShares[stage] = (sum / currentMonthTotalSoulStones) * 100;
      });
    }

    Map<String, double> goldShares = {};
    if (currentMonthTotalGold.abs() > 0.001) {
      stageGoldSums.forEach((stage, sum) {
        goldShares[stage] = (sum / currentMonthTotalGold) * 100;
      });
    }

    if (mounted) {
      setState(() {
        _totalMonthSoulStones = currentMonthTotalSoulStones;
        _totalMonthGold = currentMonthTotalGold;
        _monthlyStageSoulStoneSharesPercent = ssShares;
        _monthlyStageGoldSharesPercent = goldShares;
        _monthlyStageSoulStoneSums = stageSoulStoneSums; // 상태 변수에 저장
        _monthlyStageGoldSums = stageGoldSums;       // 상태 변수에 저장
      });
    }
  }

  // 캘린더 시작 요일 설정 다이얼로그
  Future<void> _showCalendarSettingsDialog() async {
    StartingDayOfWeek? selected = await showDialog<StartingDayOfWeek>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('캘린더 시작 요일 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: StartingDayOfWeek.values.where((day) => day == StartingDayOfWeek.sunday || day == StartingDayOfWeek.monday).map((day) { // 일요일과 월요일만 제공
              return RadioListTile<StartingDayOfWeek>(
                title: Text(day == StartingDayOfWeek.sunday ? '일요일' : '월요일'),
                value: day,
                groupValue: _startingDayOfWeek,
                onChanged: (StartingDayOfWeek? value) {
                  Navigator.of(context).pop(value);
                },
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (selected != null && selected != _startingDayOfWeek) {
      await SettingsService.instance.updateAppSettings(startingDayOfWeek: selected);
      if (mounted) {
        setState(() {
          _startingDayOfWeek = selected;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 테마 가져오기
    return Scaffold(
      appBar: AppBar(
        title: const Text('일지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '캘린더 설정',
            onPressed: _showCalendarSettingsDialog,
          ),
        ],
      ),
      drawer: const AppDrawer(currentScreen: AppScreen.journal), // 현재 화면을 journal로 설정
      body: SingleChildScrollView( // 화면 전체를 스크롤 가능하게 만듭니다.
        child: Column(
          children: [
            // 점유율 변경 버튼 (단일 버튼 + 아이콘)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sync_alt_rounded, size: 20), // 아이콘 변경 가능
                label: Text(
                  _currentShareType == JournalShareType.soulStone ? '$_goldLabel 점유율 보기' : '$_soulStoneLabel 점유율 보기',
                ),
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _currentShareType = _currentShareType == JournalShareType.soulStone
                          ? JournalShareType.gold
                          : JournalShareType.soulStone;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 38)),
              ),
            ),
            // 월별 스테이지 점유율 표시 위젯 (캘린더 위로 이동)
            _buildMonthlyShareDisplay(),
            TableCalendar(
              locale: 'ko_KR', // 한국어 로케일 설정
              firstDay: DateTime.utc(2020, 1, 1), // 달력 시작일
              lastDay: DateTime.utc(2030, 12, 31), // 달력 종료일
              focusedDay: _focusedDay,
              availableGestures: AvailableGestures.horizontalSwipe, // 수평 스와이프만 허용
              startingDayOfWeek: _startingDayOfWeek, // 설정된 시작 요일 적용
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                if (mounted) {
                  setState(() {
                    _focusedDay = focusedDay; // _focusedDay를 setState 내에서 업데이트
                  });
                  _updateMonthlyTotalsAndShares(); // 업데이트된 _focusedDay를 사용하여 점유율 재계산
                }
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, // 주/월 변경 버튼 숨김
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500), // 헤더 제목 스타일
                formatButtonTextStyle: TextStyle(fontSize: 13.0),
                formatButtonDecoration: BoxDecoration( // 포맷 버튼 꾸미기
                  border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                leftChevronIcon: Icon(Icons.chevron_left, size: 24),
                rightChevronIcon: Icon(Icons.chevron_right, size: 24),
              ),
              daysOfWeekHeight: 28.0, // 요일 표시 영역 높이 조정
              rowHeight: 60.0, // 각 행의 높이를 늘려 세로 크기 증가 (기존 55.0)
              calendarStyle: CalendarStyle(
                // cellHeight: 55.0, // 각 날짜 셀의 높이를 늘려 세로 크기 증가 (rowHeight와 함께 사용 시 주의)
                selectedDecoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.rectangle,
                  // borderRadius: BorderRadius.circular(6.0), // Remove or comment out
                ),
                selectedTextStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  shape: BoxShape.rectangle,
                  // borderRadius: BorderRadius.circular(6.0), // Remove or comment out
                ),
                todayTextStyle: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                // 토요일은 holidayPredicate와 holidayTextStyle로 처리, 일요일만 weekendTextStyle로 처리
                // ignore: deprecated_member_use
                weekendTextStyle: TextStyle(color: theme.colorScheme.error.withOpacity(0.9), fontSize: 15.0), // 일요일 스타일
                // ignore: deprecated_member_use
                outsideTextStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.4), fontSize: 14.0),
                defaultTextStyle: TextStyle(fontSize: 15.0, color: theme.textTheme.bodyLarge?.color
                ), // Added missing comma here
                holidayTextStyle: const TextStyle(color: Colors.blue, fontSize: 15.0, fontWeight: FontWeight.w500), // 토요일 스타일
                holidayDecoration: const BoxDecoration(shape: BoxShape.rectangle), // 기본 모양 유지
              ),
              holidayPredicate: (day) { // 토요일을 휴일로 간주하여 스타일 적용
                return day.weekday == DateTime.saturday;
              },
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) { // 요일 표시 커스텀 빌더를 calendarBuilders 내부로 이동
                  final text = DateFormat.E('ko_KR').format(day);
                  TextStyle? style;
                  if (day.weekday == DateTime.saturday) {
                    style = TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w500);
                  } else if (day.weekday == DateTime.sunday) {
                    style = TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500);
                  } else {
                    // ignore: deprecated_member_use
                    style = TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8), fontSize: 13);
                  }
                  return Center(child: Text(text, style: style));
                },
                markerBuilder: (context, date, events) {
                  final entriesForDay = SettingsService.instance.getEntriesForDay(date); // SettingsService에서 일지 목록 가져옴
                  if (entriesForDay.isNotEmpty) {
                    // 항상 해당 날짜의 총 순수 영혼석을 표시
                    double dailyNetSoulStones = 0;
                    for (var entry in entriesForDay) {
                      dailyNetSoulStones += entry.netSoulStones;
                    }

                    if (dailyNetSoulStones.abs() < 0.001) { // 값이 0이면 마커 표시 안 함
                      return null;
                    }

                    final formatter = NumberFormat('+ #,##0; - #,##0; 0', 'ko_KR'); // 양수, 음수, 0 포맷
                    String displayText;
                    Color textColor;

                    displayText = formatter.format(dailyNetSoulStones);
                    if (dailyNetSoulStones > 0) {
                      textColor = Colors.blue;
                    } else if (dailyNetSoulStones < 0) {
                      textColor = Colors.red;
                    } else {
                      textColor = theme.textTheme.bodySmall?.color ?? Colors.black87;
                    }

                    // 순수 영혼석 값을 셀 하단 중앙에 위치하도록 변경
                    return Positioned(
                        left: 0,
                        right: 0,
                        bottom: 3, // 날짜 숫자 아래에 적절히 위치하도록 조정
                        child: Center( // 가로 중앙 정렬
                          child: Text(
                            displayText,
                            style: TextStyle(
                              color: textColor, // 글자 크기 증가
                              fontSize: 10.5, // 기존 9.5에서 증가
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                  }
                  return null; // 해당 날짜에 항목 없으면 마커 없음
                },
              ),
            ),
            // "일지 추가" 버튼 (캘린더 아래, 목록 위)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('선택된 날짜에 일지 추가'),
                onPressed: () async {
                  final newEntry = await showDialog<JournalEntry?>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AddJournalDialog(initialDate: _selectedDay ?? _focusedDay);
                    },
                  );
                  if (newEntry != null && mounted) {
                    SettingsService.instance.addJournalEntry(newEntry);
                    await _updateMonthlyTotalsAndShares();
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
              ),
            ),
            // 선택된 날짜의 일지 목록 표시 위젯 호출 추가
            _buildJournalEntryList(),
          ],
        ),
      ),
    );
  }

  // 선택된 날짜의 일지 목록을 표시하는 위젯 빌드 함수
  Widget _buildJournalEntryList() {
    // Use _selectedDay directly, handle null inside getEntriesForDay
    debugPrint('[_buildJournalEntryList] Building list for selected day: $_selectedDay');

    final entries = SettingsService.instance.getEntriesForDay(_selectedDay ?? DateTime.now()); // SettingsService에서 일지 목록 가져옴
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##0', 'ko_KR');

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center( // 텍스트 중앙 정렬
          child: Text(
            _selectedDay != null ? '해당 날짜에 기록된 일지가 없습니다.' : '날짜를 선택하여 일지를 확인하세요.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center, // 텍스트 중앙 정렬 적용
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Column 내부에 ListView를 사용하므로 true로 설정
      physics: const NeverScrollableScrollPhysics(), // 부모 스크롤 사용
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        String netSoulStonesDisplay;
        Color netSoulStonesColor;

        if (entry.netSoulStones > 0) {
          netSoulStonesDisplay = '+${formatter.format(entry.netSoulStones)}';
          netSoulStonesColor = Colors.blue;
        } else if (entry.netSoulStones < 0) {
          netSoulStonesDisplay = formatter.format(entry.netSoulStones);
          netSoulStonesColor = Colors.red;
        } else {
          netSoulStonesDisplay = '0';
          netSoulStonesColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
        }

        // 최종 골드 계산 로직
        int finalGold = entry.earnedGold;
        final stageData = stageBaseData[entry.stage]; // _calculateFinalGoldForEntry와 중복 로직, 추후 정리 가능
        if (stageData != null) {
          final List<dynamic>? dropsDynamic = stageData['drops'] as List<dynamic>?;
          if (dropsDynamic != null) {
            final List<DropInfo> drops = dropsDynamic.whereType<DropInfo>().toList();
            final int goldDemonDropIndex = drops.indexWhere((d) => d.category == DropCategory.goldDemon && goldDemonSellPrices.containsKey(d.itemId));
            final DropInfo? goldDemonDrop = (goldDemonDropIndex != -1) ? drops[goldDemonDropIndex] : null;

            if (goldDemonDrop != null) {
              final int demonPrice = goldDemonSellPrices[goldDemonDrop.itemId] ?? 0;
              finalGold += (entry.earnedGoldDemons * demonPrice);
            }
          }
        }

        // Slidable 위젯으로 Card를 감싸서 스와이프 시 액션 버튼 표시
        return Slidable(
          key: ObjectKey(entry), // 각 항목에 고유한 키 제공 (객체 자체를 키로 사용)
          // 왼쪽으로 스와이프 시 나타날 액션들 (EndActionPane)
          endActionPane: ActionPane(
            motion: const StretchMotion(), // 스와이프 시 액션 버튼이 늘어나는 효과
            extentRatio: 0.15, // 액션 버튼이 차지할 너비 비율 (항목 너비의 25%만 보이도록 설정)
            children: [
              // 편집 버튼 (선택적 추가)
              // SlidableAction(onPressed: (context) { /* 편집 로직 */ }, backgroundColor: Colors.blue, foregroundColor: Colors.white, icon: Icons.edit, label: '편집'),
              // 삭제 버튼
              SlidableAction(
                onPressed: (context) {
                  // 삭제 버튼 클릭 시 실행될 로직
                  if (_selectedDay != null) {
                    SettingsService.instance.removeJournalEntry(_selectedDay!, entry); // 일지 삭제
                    _updateMonthlyTotalsAndShares().then((_) { // 월별 데이터 재계산 후 UI 갱신
                      if (mounted) setState(() {});
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${entry.stage} 일지가 삭제되었습니다.')),
                    );
                  }
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete_sweep_outlined,
                label: '삭제',
                // borderRadius: BorderRadius.circular(8.0), // 버튼 모서리 둥글게 (선택 사항)
              ),
            ],
          ),
          // 실제 목록 아이템
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: ListTile(
              title: Text(entry.stage, style: theme.textTheme.titleMedium),
              subtitle: Column( // 여러 정보를 표시하기 위해 Column 사용
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '영혼석: 소모 ${formatter.format(entry.consumedSoulStones)} / 획득 ${formatter.format(entry.earnedSoulStones)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text( // 획득 골드 및 돈악마 개수 표시
                    '획득 골드: ${formatter.format(entry.earnedGold)} / 돈악마: ${formatter.format(entry.earnedGoldDemons)}개',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) * 0.95),
                  ),
                  if (finalGold > 0) // 최종 골드가 0보다 클 때만 표시
                    Text( // 최종 골드 표시
                      '최종 골드: ${formatter.format(finalGold)}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) * 0.95, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                ],
              ),
              trailing: SizedBox( // 너비를 고정하거나 제한하여 UI 일관성 유지
                width: 60, // 예시 너비, 필요에 따라 조절
                child: Text(
                  netSoulStonesDisplay,
                  textAlign: TextAlign.right, // 오른쪽 정렬
                  style: TextStyle(
                    color: netSoulStonesColor,
                    fontWeight: FontWeight.bold,
                    fontSize: theme.textTheme.titleMedium?.fontSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 월별 스테이지 점유율을 표시하는 위젯
  Widget _buildMonthlyShareDisplay() {
    final theme = Theme.of(context);
    Map<String, double> currentMonthSums;
    Map<String, double> currentMonthPercentages;
    String titleLine1;
    final formatter = NumberFormat('#,##0', 'ko_KR');
    final percentFormatter = NumberFormat('0\'%\'', 'ko_KR'); // 소수점 없이 정수만 표시, % 기호 포함

    if (_currentShareType == JournalShareType.soulStone) {
      currentMonthSums = _monthlyStageSoulStoneSums;
      currentMonthPercentages = _monthlyStageSoulStoneSharesPercent;
      titleLine1 = '${_focusedDay.month}월 총 획득 $_soulStoneLabel: ${formatter.format(_totalMonthSoulStones.round())}';
    } else {
      currentMonthSums = _monthlyStageGoldSums;
      currentMonthPercentages = _monthlyStageGoldSharesPercent;
      titleLine1 = '${_focusedDay.month}월 총 획득 $_goldLabel: ${formatter.format(_totalMonthGold.round())}';
    }

    if (currentMonthSums.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text('이번 달 기록된 데이터가 없거나 점유율을 계산할 수 없습니다.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
      );
    }

    // 점유율(백분율) 기준으로 내림차순 정렬
    var sortedStageEntries = currentMonthPercentages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 둘째 줄: 절대값 표시
    String valueLine = sortedStageEntries
        .map((entry) => '${entry.key}: ${formatter.format(currentMonthSums[entry.key]?.round() ?? 0)}')
        .join(', ');

    // 셋째 줄: 백분율 표시
    String percentageLine = sortedStageEntries
        .map((entry) => '${entry.key}: ${percentFormatter.format(entry.value.floor())}') // entry.value.floor()로 소수점 버림
        .join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: theme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titleLine1, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(valueLine, style: theme.textTheme.bodySmall, softWrap: true),
            const SizedBox(height: 4),
            Text(percentageLine, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600), softWrap: true),
          ],
        ),
      ),
    );
  }
}
