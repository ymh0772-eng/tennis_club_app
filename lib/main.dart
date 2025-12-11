// [보관용 파일명]: lib/daily_log/day10_swipe_undo.dart
// 작성일: 2025-12-12
// 설명: 밀어서 삭제(Swipe) 및 실행 취소(Undo) 기능 구현 (Day 10)

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TennisApp());
}

class TennisApp extends StatelessWidget {
  const TennisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '테니스 클럽',
      // [디자인] 테마 설정 (Day 9와 동일)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orangeAccent,
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
  List<Map<String, String>> members = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- [데이터 관리 로직] ---

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
      if (index == null) {
        members.add(newInfo);
      } else {
        members[index] = newInfo;
      }
    });
    _saveData();
    _nameController.clear();
    _roleController.clear();
    Navigator.of(context).pop();
  }

  // [New 로직] 삭제 및 실행 취소 (Undo) 기능
  void _deleteWithUndo(int index) {
    // 1. [임시 보관] 지우기 전에 데이터를 변수에 잠깐 복사해둡니다. (보험)
    final deletedMember = members[index];
    final deletedIndex = index;

    // 2. [삭제 실행] 리스트에서 제거하고 저장
    setState(() {
      members.removeAt(index);
    });
    _saveData();

    // 3. [피드백 UI] 하단에 안내 메시지(SnackBar) 띄우기
    ScaffoldMessenger.of(context).clearSnackBars(); // 기존 메시지 끄기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedMember['name']}님이 삭제되었습니다.'),
        duration: const Duration(seconds: 3), // 3초간 표시
        action: SnackBarAction(
          label: '실행 취소', // 버튼 이름
          onPressed: () {
            // 4. [복구 로직] 사용자가 '실행 취소'를 누르면 실행됨
            setState(() {
              // 아까 복사해둔 위치(deletedIndex)에 데이터(deletedMember)를 다시 끼워넣음
              members.insert(deletedIndex, deletedMember);
            });
            _saveData(); // 복구된 리스트 저장
          },
        ),
      ),
    );
  }

  void _generateMatch() {
    if (members.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 4명의 회원이 필요합니다!')),
      );
      return;
    }
    List<Map<String, String>> tempList = List.from(members);
    tempList.shuffle(Random());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.sports_tennis, color: Colors.orange), SizedBox(width: 10), Text('매칭 결과')]),
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

  Widget _buildTeamBox(String teamName, String p1, String p2, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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

  // --- [화면 그리기 (UI)] ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('명화님의 테니스 클럽'),
        actions: [
          IconButton(icon: const Icon(Icons.sports_tennis), onPressed: _generateMatch),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.green)),
              accountName: Text('관리자: 명화님'),
              accountEmail: Text('Tennis Club Manager'),
              decoration: BoxDecoration(color: Color(0xFF2E7D32)),
            ),
            ListTile(leading: const Icon(Icons.home), title: const Text('홈 화면'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 상단 요약 카드
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 7, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  const Text('현재 등록 회원', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text('${members.length}명', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          // [핵심 UI 변경] 리스트 뷰
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: members.length,
              itemBuilder: (context, index) {
                // [New 위젯] Dismissible: 밀어서 삭제 기능 제공
                return Dismissible(
                  // (1) Key: 이 항목의 고유 신분증 (이름을 사용)
                  // 리스트에서 항목을 지울 때 플러터가 헷갈리지 않게 함
                  key: Key(members[index]['name']!),
                  
                  // (2) Background: 밀었을 때 뒤에 보이는 빨간 배경
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  
                  // (3) Direction: 오른쪽에서 왼쪽으로 밀 때만 작동
                  direction: DismissDirection.endToStart,

                  // (4) onDismissed: 실제로 끝까지 밀었을 때 실행할 함수
                  onDismissed: (direction) {
                    _deleteWithUndo(index); // 삭제 및 실행 취소 로직 호출
                  },

                  // 원래 카드 UI (보여지는 부분)
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.green)),
                      ),
                      title: Text(members[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(members[index]['role']!),
                      // 삭제 버튼은 이제 '밀어서 삭제'로 대체되었으므로 수정 버튼만 남김
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => _showMemberDialog(index: index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMemberDialog(index: null),
        child: const Icon(Icons.add),
      ),
    );
  }
}