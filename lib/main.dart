import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/audio_screen.dart';
import 'screens/centers_screen.dart';
import 'screens/more_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.primaryDark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const YCTApp());
}

class YCTApp extends StatelessWidget {
  const YCTApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoga Consciousness Trust',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, background: AppColors.bg),
        scaffoldBackgroundColor: AppColors.bg,
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  final List<Widget> _screens = const [
    HomeScreen(), LibraryScreen(), AudioScreen(), CentersScreen(), MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryLight,
        elevation: 8,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.primary), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: AppColors.primary), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.headphones_outlined), selectedIcon: Icon(Icons.headphones, color: AppColors.primary), label: 'Audio'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on, color: AppColors.primary), label: 'Centers'),
          NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz, color: AppColors.primary), label: 'More'),
        ],
      ),
    );
  }
}
