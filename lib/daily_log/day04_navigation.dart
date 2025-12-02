// 파일명: lib/main.dart
// 작성일: 2025-12-02
// 설명: 회원 리스트 클릭 시 상세 화면 이동 기능 (Day 4)

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

// === [1번 화면] 회원 목록 ===
class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // 회원 데이터 (이름만 있던 리스트에서 -> 상세 정보를 담은 Map 형태로 업그레이드)
  List<Map<String, String>> members = [
    {'name': '명화님', 'role': '회장', 'skill': '고수'},
    {'name': '홍길동', 'role': '총무', 'skill': '중수'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('테니스 클럽 명단')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(members[index]['name']!), // 이름 표시
              subtitle: Text(members[index]['role']!), // 직책 표시
              trailing: const Icon(Icons.arrow_forward_ios),
              // [핵심] 클릭 시 상세 화면으로 이동
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(member: members[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// === [2번 화면] 상세 정보 ===
class DetailScreen extends StatelessWidget {
  // 생성자: 목록 화면에서 넘겨받은 회원 정보
  final Map<String, String> member;

  const DetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 바 (자동으로 뒤로가기 화살표가 생김)
      appBar: AppBar(
        title: Text('${member['name']}님의 프로필'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              '이름: ${member['name']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('직책: ${member['role']}', style: const TextStyle(fontSize: 20)),
            Text('실력: ${member['skill']}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 (현재 화면 닫기)
              },
              child: const Text('목록으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}