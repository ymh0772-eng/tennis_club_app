// 파일명: lib/main.dart
// 작성일: 2025-12-05
// 설명: 앱을 껐다 켜도 데이터가 유지되도록 저장 기능 구현 (Day 6)

import 'dart:convert'; // 데이터를 문자열로 변환하기 위해 필요
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 저장소 라이브러리

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
      theme: ThemeData(primarySwatch: Colors.lightGreen),
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
  // 회원 데이터 리스트
  List<Map<String, String>> members = [];

  // 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  // [핵심] 앱이 시작될 때 딱 한 번 실행되는 함수
  @override
  void initState() {
    super.initState();
    _loadData(); // "금고에서 데이터 꺼내와!"
  }

  // [기능 1] 데이터 불러오기 (Load)
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance(); // 금고 열기
    final String? jsonString = prefs.getString('member_list'); // 'member_list'라는 이름표 붙은 봉투 꺼내기

    if (jsonString != null) {
      // 봉투가 있으면, 내용물을 풀어서(decode) 리스트에 담기
      setState(() {
        List<dynamic> decodedList = jsonDecode(jsonString);
        members = decodedList.map((item) => Map<String, String>.from(item)).toList();
      });
    } else {
      // 봉투가 없으면(처음 실행하면) 기본 데이터 추가
      setState(() {
        members = [
          {'name': '명화님', 'role': '회장', 'skill': '고수'},
        ];
      });
    }
  }

  // [기능 2] 데이터 저장하기 (Save)
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance(); // 금고 열기
    // 리스트를 통째로 문자열(JSON)로 포장해서(encode) 금고에 넣기
    String jsonString = jsonEncode(members);
    await prefs.setString('member_list', jsonString);
  }

  // 회원 추가 로직
  void _addMember() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        members.add({
          'name': _nameController.text,
          'role': _roleController.text,
          'skill': '신입',
        });
      });
      _saveData(); // [중요] 변경사항 저장!
      _nameController.clear();
      _roleController.clear();
      Navigator.of(context).pop();
    }
  }

  // 회원 삭제 로직
  void _removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
    _saveData(); // [중요] 변경사항 저장!
  }

  // 다이얼로그 보여주기 (기존과 동일)
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새 회원 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: '이름')),
              TextField(controller: _roleController, decoration: const InputDecoration(labelText: '직책')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            ElevatedButton(onPressed: _addMember, child: const Text('저장')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('테니스 클럽 명단 (자동저장)')),
      body: members.isEmpty
          ? const Center(child: Text('데이터를 불러오는 중...'))
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(members[index]['name']!),
                    subtitle: Text(members[index]['role']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeMember(index),
                    ),
                    onTap: () {
                      // 상세 화면 이동 코드는 간소화를 위해 생략했지만, 필요하면 Day 4 코드 참조 가능
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}