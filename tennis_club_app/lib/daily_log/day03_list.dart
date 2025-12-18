// 파일명: lib/main.dart
// 작성일: 2025-12-02
// 설명: 회원 이름 입력 및 리스트 추가 기능 (Day 3)

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

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // 1. [데이터] 회원 명단 (문자열 리스트)
  // 처음엔 '명화님' 한 명만 들어있음
  List<String> members = ['명화님'];

  // 2. [도구] 입력창의 글자를 가져오는 컨트롤러
  final TextEditingController _nameController = TextEditingController();

  // 3. [함수] 회원을 추가하는 동작
  void _addMember() {
    setState(() {
      // 입력창에 내용이 있을 때만 실행
      if (_nameController.text.isNotEmpty) {
        members.add(_nameController.text); // 리스트에 추가
        _nameController.clear(); // 입력창 비우기
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테니스 클럽 명단 관리'),
        backgroundColor: Colors.lightGreen,
      ),
      // 화면 구조: 위에는 리스트, 아래는 입력창
      body: Column(
        children: [
          // 4. [위젯] 리스트 보여주기 (Expanded로 남은 공간 꽉 채움)
          Expanded(
            child: ListView.builder(
              itemCount: members.length, // 데이터 개수만큼
              itemBuilder: (context, index) {
                // 각 항목의 디자인 (카드 모양)
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text('${index + 1}'), // 번호
                    ),
                    title: Text(members[index]), // 이름
                    trailing: const Icon(Icons.person),
                  ),
                );
              },
            ),
          ),
          // 5. [위젯] 입력창 구역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController, // 컨트롤러 연결
                    decoration: const InputDecoration(
                      hintText: '회원 이름 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addMember, // 버튼 누르면 추가
                  child: const Text('추가'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}