import 'package:flutter/material.dart';
import 'package:movielog/week1_screen.dart';
import 'package:movielog/week0_screen.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Week0Screen(),
      // home: const Week1Screen(),
    );
  }
}