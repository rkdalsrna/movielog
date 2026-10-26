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
    if (posterPath == null || posterPath!.isEmpty) return null; //포스터 경로가 없으면 null 반환
    return '$_baseUrl/$_size$posterPath'; //기본 주소와 이미지 크기, 포스터 경로 결합
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;

    if (imageUrl == null) return _placeholder(); //포스터가 없으면 대체 아이콘 표시

    return Image.network(
      imageUrl, //실제 TMDB 포스터 이미지 요청
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder(), //이미지 요청 실패 시 대체 아이콘 표시
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