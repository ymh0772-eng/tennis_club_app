// [Day 18] 승률 통계 차트
// 파일명: widgets/stats_chart.dart

import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

class WinRateChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. [키워드: CustomPaint] 복잡한 그림이나 차트를 그리는 영역
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.white,
      child: Center(child: Text("여기에 원형 차트(Pie Chart)가 들어갑니다.")),
      // 실제 구현 시 PieChart(PieChartData(...)) 사용
    );
  }
}