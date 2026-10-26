//lib/widgets/tmdb_poster_image.dart

import 'package:flutter/material.dart';

class TmdbPosterImage extends StatelessWidget {
  const TmdbPosterImage({
    super.key,
    required this.posterPath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  final String? posterPath;
  final double width;
  final double height;
  final BoxFit fit;

  static const _baseUrl = 'https://image.tmdb.org/t/p';
  static const _size = 'w500';

  //포스터 경로를 TMDB 이미지 주소로 변환
  String? get _imageUrl {
    if (posterPath == null || posterPath!.isEmpty) return null;
    return '$_baseUrl/$_size$posterPath';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;

    if (imageUrl == null) return _placeholder();

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      //이미지 요청 실패 시 대체 아이콘 표시
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}