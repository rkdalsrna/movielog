import 'package:flutter/material.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/week1_screen.dart';
import 'package:movielog/week1_screen_01.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      home: const Week1Screen(),
      // home: const Week1Screen01(),
    );
  }
}
