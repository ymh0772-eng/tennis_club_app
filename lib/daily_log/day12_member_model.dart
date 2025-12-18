// [Day 12] 데이터 모델 클래스화
// 파일명: models/member_model.dart

// 1. [키워드: Class] 회원을 정의하는 설계도 생성
class Member {
  final String id;
  final String name;
  final String level;
  final int age;

  Member({
    required this.id,
    required this.name,
    required this.level,
    required this.age,
  });

  // 2. [기능: From JSON] 저장된 데이터(Map)를 객체로 변환하는 공장(Factory)
  // Shared Preferences나 DB에서 가져온 데이터를 쓸 수 있게 만듦
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      age: json['age'],
    );
  }

  // 3. [기능: To JSON] 객체를 저장 가능한 형태(Map)로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'age': age,
    };
  }
}