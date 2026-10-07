import 'package:flutter/material.dart';

class MovieListLoading extends StatelessWidget {
  const MovieListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    // 영화 목록 요청 중 로딩 표시
    return const Center(child: CircularProgressIndicator());
  }
}
