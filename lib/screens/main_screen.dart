import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:movielog/theme/app_colors.dart';

import '../view_models/auth_view_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 어느 탭으로 진입하든 내 정보를 한 번 불러와 보관함
        context.read<AuthViewModel>().loadMember();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack으로 선택하지 않은 탭의 화면 상태 유지
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        indicatorColor: AppColors.navigationIndicator, //네비게이션 바 누르면 나오는 색상
        onDestinationSelected: (index) {
          // 선택한 탭의 기존 Navigation 상태로 이동
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: '영화',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
