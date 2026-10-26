import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movielog/movie_log_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일을 메모리에 로드 , 앱 실행 전에 .env를 읽기
  await dotenv.load(fileName: '.env');

  // Flutter 앱 실행
  runApp(const MovieLogApp());
}