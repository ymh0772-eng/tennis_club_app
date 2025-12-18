// [Day 11] 회원 검색 기능
// 파일명: day11_search_logic.dart

import 'package:flutter/material.dart';

class SearchFeature extends StatefulWidget {
  @override
  _SearchFeatureState createState() => _SearchFeatureState();
}

class _SearchFeatureState extends State<SearchFeature> {
  // 1. [키워드: Data Source] 전체 데이터와 검색된 데이터를 분리해야 함
  final List<Map<String, dynamic>> _allMembers = [
    {"id": 1, "name": "김철수", "level": "A"},
    {"id": 2, "name": "이영희", "level": "B"},
    {"id": 3, "name": "박민수", "level": "A"},
  ];

  // 2. [기능: Display List] 화면에 실제로 보여질 리스트 (초기값은 전체)
  List<Map<String, dynamic>> _foundMembers = [];

  @override
  void initState() {
    super.initState();
    _foundMembers = _allMembers; // 처음엔 다 보여줌
  }

  // 3. [동작: Filtering Logic] 검색어가 입력될 때마다 실행되는 함수
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // 4. 검색어가 없으면 전체 리스트 복구
      results = _allMembers;
    } else {
      // 5. [알고리즘: Where] 이름에 검색어가 포함된 항목만 골라냄
      // toLowerCase()를 사용하여 대소문자 구분 없이 검색
      results = _allMembers
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // 6. [동작: UI Update] 상태 변경을 통해 화면 갱신
    setState(() {
      _foundMembers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 7. [위젯: Search Bar] 검색 입력창
        TextField(
          onChanged: (value) => _runFilter(value), // 키 입력 시마다 필터링 실행
          decoration: InputDecoration(
            labelText: '회원 검색', 
            suffixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _foundMembers.length,
            itemBuilder: (context, index) => Card(
              // 8. 검색된 결과만 리스트로 출력
              child: ListTile(
                title: Text(_foundMembers[index]['name']),
                subtitle: Text("Level: ${_foundMembers[index]['level']}"),
              ),
            ),
          ),
        ),
      ],
    );
  }
}