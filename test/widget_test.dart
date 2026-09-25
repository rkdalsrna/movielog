import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/movie_log_app.dart';

void main() {
  testWidgets('시작 화면의 주요 문구를 표시한다', (tester) async {
    await tester.pumpWidget(const MovieLogApp());

    expect(find.text('FLUTTER 0주차'), findsOneWidget);
    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    expect(
      find.text('보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요'),
      findsOneWidget,
    );
    expect(find.text('시작하기'), findsNothing);
  });
}
