// [보관용 파일명]: lib/daily_log/day09_study.dart
// 작성일: 2025-12-11
// 설명: 앱의 실행 순서와 데이터 처리 로직 상세 분석

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// [순서 1] 앱의 시작 (Entry Point)
// : 사용자가 앱 아이콘을 누르면 가장 먼저 실행되는 곳
// ============================================================
void main() {
  runApp(const TennisApp());
}

// ============================================================
// [순서 2] 앱의 뼈대와 테마 설정 (Configuration)
// ============================================================
class TennisApp extends StatelessWidget {
  const TennisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '테니스 클럽',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), // 테마색 설정
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      // [순서 3] 설정이 끝나면 첫 번째 화면(MemberListScreen)을 띄웁니다.
      home: const MemberListScreen(),
    );
  }
}

// ============================================================
// [순서 4] 메인 화면의 기능과 상태 관리 (State)
// : 여기가 실제 작업이 일어나는 핵심 구역입니다.
// ============================================================
class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // ----------------------------------------------------------
  // [데이터 저장소] (RAM)
  // ----------------------------------------------------------
  List<Map<String, String>> members = []; // 화면에 보여줄 명단
  
  // 입력창 관리자 (텍스트 필드 제어용)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  // ----------------------------------------------------------
  // [순서 5] 초기화 (Initialization)
  // : 화면이 처음 만들어질 때 딱 한 번 실행됩니다.
  // ----------------------------------------------------------
  @override
  void initState() {
    super.initState();
    // "앱 켜졌으니, 저장된 파일(기기 내부)에서 명단 가져와!"
    _loadData(); 
  }

  // ----------------------------------------------------------
  // [로직 1] 데이터 불러오기 (Load Logic)
  // ----------------------------------------------------------
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance(); // 1. 금고 열기
    final String? jsonString = prefs.getString('member_list'); // 2. 내용물 꺼내기

    if (jsonString != null) {
      // 3. 내용물이 있으면 리스트로 변환해서 'members' 변수에 담기
      setState(() {
        List<dynamic> decodedList = jsonDecode(jsonString);
        members = decodedList.map((item) => Map<String, String>.from(item)).toList();
      });
      // (setState를 했으므로 화면이 자동으로 다시 그려집니다.)
    }
  }

  // ----------------------------------------------------------
  // [로직 2] 데이터 저장하기 (Save Logic)
  // ----------------------------------------------------------
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(members); // 리스트를 문자열로 포장
    await prefs.setString('member_list', jsonString); // 기기에 덮어쓰기
  }

  // ----------------------------------------------------------
  // [로직 3] 회원 추가 및 수정 (핵심 로직!)
  // : 사용자가 다이얼로그에서 '저장'을 눌렀을 때 실행됨
  // ----------------------------------------------------------
  void _saveMember({int? index}) {
    // 1. 이름이 비어있으면 저장 안 함 (강제 종료)
    if (_nameController.text.isEmpty) return;

    // 2. 화면 갱신 시작
    setState(() {
      // 3. 입력창에 적힌 내용으로 '새 명함' 만들기
      Map<String, String> newInfo = {
        'name': _nameController.text,
        'role': _roleController.text,
        // 수정일 때는 기존 실력 유지, 새 추가일 때는 '신입'
        'skill': index != null ? members[index]['skill']! : '신입',
      };

      // 4. [분기점] 추가냐? 수정이냐?
      if (index == null) {
        // (상황 A) index가 없다 -> 새 회원이므로 리스트 끝에 추가
        members.add(newInfo); 
      } else {
        // (상황 B) index가 있다 -> 기존 회원이므로 그 자리를 교체 (덮어쓰기)
        members[index] = newInfo; 
      }
    });

    // 5. 변경된 리스트를 영구 저장
    _saveData();
    
    // 6. 뒷정리 (입력창 비우고 창 닫기)
    _nameController.clear();
    _roleController.clear();
    Navigator.of(context).pop();
  }

  // ----------------------------------------------------------
  // [로직 4] 회원 삭제
  // ----------------------------------------------------------
  void _removeMember(int index) {
    setState(() {
      members.removeAt(index); // 리스트에서 해당 번호 삭제
    });
    _saveData(); // 변경사항 저장
  }

  // ----------------------------------------------------------
  // [로직 5] 대진표 생성 알고리즘
  // ----------------------------------------------------------
  void _generateMatch() {
    // 1. 인원수 검사
    if (members.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 4명의 회원이 필요합니다!')),
      );
      return;
    }
    
    // 2. 섞기 (Shuffle)
    List<Map<String, String>> tempList = List.from(members);
    tempList.shuffle(Random());
    
    // 3. 결과 보여주기 (생략 - 이전 코드와 동일)
    // ... showDialog 코드 ...
    _showMatchResult(tempList); // (코드가 길어서 아래 함수로 뺐습니다)
  }
  
  // (결과창 띄우는 함수 - 내용은 생략하고 구조만 보여드림)
  void _showMatchResult(List<Map<String, String>> list) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
              // ... 대진표 UI 코드 ...
          )
      );
  }

  // ----------------------------------------------------------
  // [순서 6] 화면 그리기 (UI Build)
  // : 위에서 데이터가 준비되면 플러터가 이 함수를 실행해 화면을 그립니다.
  // : setState()가 호출될 때마다 이 함수는 '다시' 실행됩니다.
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [구역 A] 지붕 (AppBar)
      appBar: AppBar(
        title: const Text('명화님의 테니스 클럽'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sports_tennis),
            onPressed: _generateMatch, // 클릭 시 [로직 5] 실행
          ),
        ],
      ),
      
      // [구역 B] 왼쪽 서랍 (Drawer)
      drawer: Drawer(
        // ... 메뉴 코드 ...
      ),

      // [구역 C] 몸통 (Body)
      body: Column(
        children: [
          // 상단 요약 카드
          Container(
             // ... 디자인 코드 ...
             child: Text('총 ${members.length}명'), // 현재 인원수 표시
          ),
          
          // 리스트 뷰 (반복문 공장)
          Expanded(
            child: ListView.builder(
              itemCount: members.length, // "만약 회원이 10명이면?"
              itemBuilder: (context, index) { // "0번부터 9번까지 10번 반복해라"
                return Card(
                  child: ListTile(
                    // [중요] index 번째 사람의 이름을 꺼내서 찍어줌
                    title: Text(members[index]['name']!), 
                    subtitle: Text(members[index]['role']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 수정 버튼 클릭 -> 다이얼로그 열기
                        IconButton(icon: Icon(Icons.edit), onPressed: () => _showMemberDialog(index: index)),
                        // 삭제 버튼 클릭 -> [로직 4] 실행
                        IconButton(icon: Icon(Icons.delete), onPressed: () => _removeMember(index)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      // [구역 D] 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMemberDialog(index: null), // index 없이 호출 (추가 모드)
        child: const Icon(Icons.add),
      ),
    );
  }
  
  // (다이얼로그 띄우는 함수는 아래에 숨겨둠)
  void _showMemberDialog({int? index}) {
      // ... 다이얼로그 코드 ...
      // 저장 버튼 누르면 _saveMember(index: index) 실행 -> [로직 3] 으로 이동
  }
}