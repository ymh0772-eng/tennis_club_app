// [보관용 파일명]: lib/daily_log/day09_design.dart
// 작성일: 2025-12-09
// 설명: 앱 전체 디자인 개선(UI/UX) 및 사이드 메뉴(Drawer) 구현 (Day 9)

// 1. [라이브러리 임포트]
import 'dart:convert'; // 데이터 변환 (JSON <-> List)
import 'dart:math';    // 랜덤 매칭 알고리즘용
import 'package:flutter/material.dart'; // 플러터 UI 프레임워크
import 'package:shared_preferences/shared_preferences.dart'; // 데이터 저장소

void main() {
  runApp(const TennisApp());
}

// 2. [앱 설정 클래스] 전체 테마(색상, 폰트)를 관리하는 곳
class TennisApp extends StatelessWidget {
  const TennisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 오른쪽 위 'Debug' 띠 제거
      title: '테니스 클럽',
      
      // [핵심 키워드] ThemeData: 앱의 전반적인 색상과 스타일을 정의
      theme: ThemeData(
        useMaterial3: true, // 최신 구글 디자인 가이드 적용
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, // 기본 색상: 녹색 (테니스 코트)
          brightness: Brightness.light, // 밝은 모드
        ),
        // 앱바(상단 바) 스타일 전역 설정
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32), // 짙은 녹색 (Hex 코드)
          foregroundColor: Colors.white, // 글자색 흰색
          centerTitle: true,
        ),
        // 떠있는 버튼 스타일 전역 설정
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orangeAccent, // 포인트 컬러: 주황색 (테니스 공)
          foregroundColor: Colors.white,
        ),
      ),
      home: const MemberListScreen(),
    );
  }
}

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // [데이터 변수]
  List<Map<String, String>> members = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  // [생명주기 함수] 앱 시작 시 1회 실행
  @override
  void initState() {
    super.initState();
    _loadData(); // 저장된 데이터 불러오기
  }

  // --- [데이터 관리 로직 (CRUD)] --- 
  // (이전 Day 6~7과 동일한 로직입니다. 주석을 간소화했습니다.)
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('member_list');
    if (jsonString != null) {
      setState(() {
        List<dynamic> decodedList = jsonDecode(jsonString);
        members = decodedList.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(members);
    await prefs.setString('member_list', jsonString);
  }

  void _saveMember({int? index}) {
    if (_nameController.text.isEmpty) return;
    setState(() {
      Map<String, String> newInfo = {
        'name': _nameController.text,
        'role': _roleController.text,
        'skill': index != null ? members[index]['skill']! : '신입',
      };
      if (index == null) members.add(newInfo);
      else members[index] = newInfo;
    });
    _saveData();
    _nameController.clear();
    _roleController.clear();
    Navigator.of(context).pop();
  }

  void _removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
    _saveData();
  }

  // --- [매칭 알고리즘 로직] ---
  void _generateMatch() {
    if (members.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 4명의 회원이 필요합니다!')),
      );
      return;
    }
    List<Map<String, String>> tempList = List.from(members);
    tempList.shuffle(Random());
    
    // [UI 업데이트] 결과창도 디자인을 조금 더 다듬었습니다.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.sports_tennis, color: Colors.orange), SizedBox(width: 10), Text('매칭 결과')],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTeamBox('Team A', tempList[0]['name']!, tempList[1]['name']!, Colors.blue),
            const Padding(padding: EdgeInsets.all(8.0), child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold))),
            _buildTeamBox('Team B', tempList[2]['name']!, tempList[3]['name']!, Colors.red),
          ],
        ),
        actions: [
          TextButton(onPressed: () {Navigator.pop(context); _generateMatch();}, child: const Text('다시 뽑기')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
        ],
      ),
    );
  }

  // [함수 분리] 팀 박스 디자인을 위한 별도 위젯 함수 (코드를 깔끔하게 하기 위함)
  Widget _buildTeamBox(String teamName, String p1, String p2, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // 연한 배경색
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(teamName, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text('$p1 & $p2', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _showMemberDialog({int? index}) {
    // (다이얼로그 로직은 이전과 동일)
    if (index != null) {
      _nameController.text = members[index]['name']!;
      _roleController.text = members[index]['role']!;
    } else {
      _nameController.clear();
      _roleController.clear();
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? '새 회원 추가' : '정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '이름', icon: Icon(Icons.person))),
            TextField(controller: _roleController, decoration: const InputDecoration(labelText: '직책', icon: Icon(Icons.badge))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('취소')),
          ElevatedButton(onPressed: () => _saveMember(index: index), child: const Text('저장')),
        ],
      ),
    );
  }

  // ============================================================
  // [3. UI 화면 구성] 위젯 트리 (Widget Tree)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [핵심 키워드] AppBar: 상단 제목줄
      appBar: AppBar(
        title: const Text('명화님의 테니스 클럽'),
        elevation: 4, // 그림자 효과
        actions: [
          IconButton(
            icon: const Icon(Icons.sports_tennis),
            tooltip: '매칭 시작',
            onPressed: _generateMatch,
          ),
        ],
      ),

      // [핵심 키워드] Drawer: 왼쪽에서 나오는 사이드 메뉴
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 드로어 헤더 (배경색이 있는 상단부)
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
              accountName: Text('관리자: 명화님'),
              accountEmail: Text('Tennis Club Manager'),
              decoration: BoxDecoration(color: Color(0xFF2E7D32)), // 짙은 녹색
            ),
            // 메뉴 항목들
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('홈 화면'),
              onTap: () => Navigator.pop(context), // 메뉴 닫기
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정 (준비중)'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),

      // 몸통 부분
      body: Container(
        color: Colors.grey[100], // 전체 배경을 아주 연한 회색으로
        child: Column(
          children: [
            // 상단 요약 카드
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient( // 그라데이션 효과
                    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15), // 둥근 모서리
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 7, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('현재 등록 회원', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text('${members.length}명', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            // 리스트 뷰
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2, // 카드 그림자
                    margin: const EdgeInsets.only(bottom: 12), // 카드 간 간격
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 카드 둥글게
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.green)),
                      ),
                      title: Text(members[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(members[index]['role']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blueGrey), onPressed: () => _showMemberDialog(index: index)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _removeMember(index)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // 하단 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMemberDialog(index: null),
        child: const Icon(Icons.add),
      ),
    );
  }
}