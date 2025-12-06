// [보관용 파일명]: lib/daily_log/day07_update.dart
// 작성일: 2025-12-07
// 설명: 회원 정보 수정(Update) 기능 구현 (Day 7)

import 'dart:convert';
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
  List<Map<String, String>> members = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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

  // [핵심 로직] 회원 추가 또는 수정 (Create or Update)
  // index가 null이면 '새 추가', 숫자가 있으면 '수정'으로 판단
  void _saveMember({int? index}) {
    if (_nameController.text.isEmpty) return;

    setState(() {
      // 입력된 데이터 포장
      Map<String, String> newInfo = {
        'name': _nameController.text,
        'role': _roleController.text,
        'skill': index != null ? members[index]['skill']! : '신입', // 수정 시엔 기존 실력 유지
      };

      if (index == null) {
        // [추가 모드] 리스트 끝에 추가
        members.add(newInfo);
      } else {
        // [수정 모드] 해당 번호(index)의 데이터를 교체
        members[index] = newInfo;
      }
    });

    _saveData(); // 저장소에 반영
    _nameController.clear();
    _roleController.clear();
    Navigator.of(context).pop(); // 창 닫기
  }

  void _removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
    _saveData();
  }

  // [UI 핵심] 다이얼로그 하나로 '추가'와 '수정'을 모두 처리
  void _showMemberDialog({int? index}) {
    // 수정 모드라면, 기존 데이터를 입력창에 미리 채워넣기(Pre-fill)
    if (index != null) {
      _nameController.text = members[index]['name']!;
      _roleController.text = members[index]['role']!;
    } else {
      // 추가 모드라면, 빈칸으로 시작
      _nameController.clear();
      _roleController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? '새 회원 추가' : '회원 정보 수정'), // 제목도 상황에 따라 바뀜
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: '이름')),
              TextField(controller: _roleController, decoration: const InputDecoration(labelText: '직책')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              // 저장 버튼을 누르면 index 정보를 같이 넘김
              onPressed: () => _saveMember(index: index),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('테니스 클럽 명단 관리')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(members[index]['name']!),
              subtitle: Text(members[index]['role']!),
              
              // [UI 변경] 수정/삭제 버튼을 나란히 배치
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // 최소한의 공간만 차지
                children: [
                  // 수정 버튼 (연필)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showMemberDialog(index: index), // 수정 모드로 다이얼로그 열기
                  ),
                  // 삭제 버튼 (휴지통)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeMember(index),
                  ),
                ],
              ),
              onTap: () {
                // 상세 화면 이동 (Day 4 코드 활용 가능)
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMemberDialog(index: null), // index 없이 호출 -> 추가 모드
        child: const Icon(Icons.add),
      ),
    );
  }
}