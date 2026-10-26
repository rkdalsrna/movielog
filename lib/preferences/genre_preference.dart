import 'package:shared_preferences/shared_preferences.dart';

class GenrePreference {
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _selectedGenresKey = 'selected_genres';

  final SharedPreferencesAsync _preferences;

  Future<Set<String>> read() async {
    // 마지막으로 저장한 장르 목록 조회
    final genres = await _preferences.getStringList(_selectedGenresKey);
    return {...?genres};
  }

  Future<void> save(Set<String> genres) async {
    if (genres.isEmpty) {
      // 선택 장르가 없으면 저장값 제거
      await clear();
      return;
    }

    // 다중 선택 장르를 문자열 목록으로 저장
    await _preferences.setStringList(_selectedGenresKey, genres.toList());
  }

  Future<void> clear() async {
    await _preferences.remove(_selectedGenresKey);
  }
}
