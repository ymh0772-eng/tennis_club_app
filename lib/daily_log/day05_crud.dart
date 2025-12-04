// 파일명: lib/main.dart
// 작성일: 2025-12-05 (가정)
// 설명: 회원 추가 및 삭제 기능 구현 (Day 5)

import 'package:flutter/material.dart';

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

// === [메인 화면 클래스] ===
class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // [Data Field] 회원 데이터 리스트 (상태 관리 대상)
  List<Map<String, String>> members = [
    {'name': '명화님', 'role': '회장', 'skill': '고수'},
    {'name': '홍길동', 'role': '총무', 'skill': '중수'},
  ];

  // [Controller] 텍스트 입력값을 제어하는 컨트롤러 인스턴스 생성
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  // [Method] 회원 추가 로직
  void _addMember() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        // 리스트에 새로운 Map 객체를 추가 (Create)
        members.add({
          'name': _nameController.text,
          'role': _roleController.text,
          'skill': '신입', // 실력은 기본값으로 설정
        });
      });
      _nameController.clear(); // 입력창 초기화
      _roleController.clear();
      Navigator.of(context).pop(); // 다이얼로그 닫기
    }
  }

  // [Method] 회원 삭제 로직
  void _removeMember(int index) {
    setState(() {
      members.removeAt(index); // 해당 인덱스의 데이터 삭제 (Delete)
    });
  }

  // [Method] 입력창(Dialog) 띄우기
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새 회원 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: '직책'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // 취소
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: _addMember, // 저장 버튼 클릭 시 _addMember 메소드 실행
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
      
      // [ListView Widget] 데이터 렌더링
      body: members.isEmpty
          ? const Center(child: Text('등록된 회원이 없습니다.')) // 데이터가 0개일 때
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(members[index]['name']!),
                    subtitle: Text(members[index]['role']!),
                    
                    // [Event] 클릭 시 상세 화면 이동 (Day 4 기능 유지)
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(member: members[index]),
                        ),
                      );
                    },
                    
                    // [Event] 삭제 버튼 클릭 (Day 5 추가)
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeMember(index),
                    ),
                  ),
                );
              },
            ),
            
      // [Event] 추가 버튼 클릭 -> 다이얼로그 호출
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// === [상세 화면 클래스] (Day 4와 동일) ===
class DetailScreen extends StatelessWidget {
  final Map<String, String> member;

  const DetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${member['name']}님의 프로필')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text('이름: ${member['name']}', style: const TextStyle(fontSize: 24)),
            Text('직책: ${member['role']}', style: const TextStyle(fontSize: 20)),
            Text('실력: ${member['skill']}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('목록으로'),
            ),
          ],
        ),
      ),
    );
  }
}