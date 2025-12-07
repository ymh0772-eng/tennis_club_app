// [보관용 파일명]: lib/daily_log/day08_matchmaking.dart
// 작성일: 2025-12-08
// 설명: 복식 경기 대진표 자동 생성 알고리즘 구현 (Day 8)

import 'dart:convert';
import 'dart:math'; // 무작위(Random) 기능을 쓰기 위한 도구
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

  void _removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
    _saveData();
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? '새 회원 추가' : '회원 정보 수정'),
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
              onPressed: () => _saveMember(index: index),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // [Day 8 핵심 로직] 무작위 대진표 생성 함수
  void _generateMatch() {
    // 1. 인원수 체크: 최소 4명은 있어야 복식 경기가 가능
    if (members.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 4명의 회원이 필요합니다!')),
      );
      return;
    }

    // 2. 무작위 섞기 (Shuffle)
    // 원본 리스트를 건드리지 않기 위해 복사본(tempList)을 만듭니다.
    List<Map<String, String>> tempList = List.from(members);
    tempList.shuffle(Random()); // 무작위로 섞음

    // 3. 앞에서부터 4명 뽑기
    Map<String, String> p1 = tempList[0];
    Map<String, String> p2 = tempList[1];
    Map<String, String> p3 = tempList[2];
    Map<String, String> p4 = tempList[3];

    // 4. 결과 보여주기 (Dialog)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎾 복식 경기 매칭 결과'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Team A', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            Text('${p1['name']} & ${p2['name']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Team B', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            Text('${p3['name']} & ${p4['name']}', style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          // 마음에 안 들면 다시 뽑기
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateMatch(); // 재귀 호출 (다시 실행)
            },
            child: const Text('다시 뽑기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테니스 클럽'),
        actions: [
          // [UI 추가] 상단 바 우측에 '게임 생성' 버튼 추가
          IconButton(
            icon: const Icon(Icons.sports_tennis),
            tooltip: '게임 매칭',
            onPressed: _generateMatch,
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 안내 문구
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            width: double.infinity,
            child: Text(
              '총 회원 수: ${members.length}명\n우측 상단 테니스공 아이콘을 눌러 게임을 만드세요!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(members[index]['name']!),
                    subtitle: Text('${members[index]['role']!} | ${members[index]['skill']!}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showMemberDialog(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeMember(index),
                        ),
                      ],
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