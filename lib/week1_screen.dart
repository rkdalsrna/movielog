import 'package:flutter/material.dart';

class Week1Screen extends StatelessWidget {
  const Week1Screen ({super.key});

  static const _backgroundColor = Color(0xFFFAF9F5);
  static const _primaryColor = Color(0xFF543A92);
  static const _titleColor = Color(0xFF1D1D1B);
  static const _supportingTextColor = Color(0xFF4D4955);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 64), //상단 여백
              Text(
                'FLUTTER 0주차',
                style: TextStyle(
                  color: _supportingTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 64),
              Icon(
                Icons.movie_outlined,
                size: 64,
                color: _primaryColor,
              ),
              SizedBox(height: 58),
              Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _titleColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  letterSpacing: -1.2,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _supportingTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  letterSpacing: -0.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
