import 'package:flutter/material.dart';

class MovieListEmpty extends StatelessWidget {
  const MovieListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    // 영화 목록이 비어 있을 때 안내 문구 표시
    return const Center(child: Text('조건에 맞는 영화가 없습니다.'));
  }
}
