import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/constants.dart';
import 'core/firestore_service.dart';
import 'core/remote_config_service.dart';
import 'core/auth_service.dart';
import 'core/update_service.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/audio_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/centers_screen.dart';
import 'screens/more_screen.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final appId = defaultTargetPlatform == TargetPlatform.iOS
        ? '1:881638212469:ios:1a67a064aad27285b7893c'
        : '1:881638212469:android:89bfa42941ad7945b7893c';

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey:            'AIzaSyBF7Qn4Ytrys9WLuBU41G2KOuxBN0GWGO8',
        appId:             appId,
        messagingSenderId: '881638212469',
        projectId:         'yct-app',
        storageBucket:     'yct-app.firebasestorage.app',
      ),
    );

    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FirestoreService.init();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryDark,
      statusBarIconBrightness: Brightness.light,
    ));

    await RemoteConfigService.init();

    runApp(const YCTApp());

    unawaited(AuthService.init());

  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  });
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.bg),
        scaffoldBackgroundColor: AppColors.bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0),
        fontFamily: 'Roboto',
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

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _idx = 0;
  bool _maintenance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _maintenance = RemoteConfigService.maintenanceMode;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_maintenance) {
        await UpdateService.checkAndShowIfRequired(context);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      RemoteConfigService.refresh().then((_) {
        if (mounted) setState(() => _maintenance = RemoteConfigService.maintenanceMode);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _switchTab(int i) => setState(() => _idx = i);

  @override
  Widget build(BuildContext context) {
    if (_maintenance) return const _MaintenanceScreen();

    // Tab indices:
    // 0 = Home, 1 = Library, 2 = Audio, 3 = Programs, 4 = Centers, 5 = More
    final screens = [
      HomeScreen(onSwitchTab: _switchTab),
      const LibraryScreen(),
      const AudioScreen(),
      const ProgramsScreen(),
      const CentersScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _idx, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryLight,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: 'Library'),
          NavigationDestination(
            icon: Icon(Icons.headphones_outlined),
            selectedIcon: Icon(Icons.headphones, color: AppColors.primary),
            label: 'Audio'),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event, color: AppColors.primary),
            label: 'Programs'),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on, color: AppColors.primary),
            label: 'Centers'),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz, color: AppColors.primary),
            label: 'More'),
        ],
      ),
    );
  }
}

class _MaintenanceScreen extends StatelessWidget {
  const _MaintenanceScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20)]),
                  child: ClipOval(child: Image.asset(
                    'assets/images/yct_logo.png', fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('YCT', style: TextStyle(
                        color: AppColors.primary, fontSize: 20,
                        fontWeight: FontWeight.bold)))))),
                const SizedBox(height: 32),
                const Text('యోగ చైతన్య సంస్థ',
                  style: TextStyle(color: AppColors.teal,
                    fontSize: 14, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                const Text('Yoga Consciousness Trust',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white,
                    fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2))),
                  child: Column(children: [
                    const Icon(Icons.celebration,
                      color: AppColors.saffron, size: 36),
                    const SizedBox(height: 12),
                    const Text('Launching September 30, 2026',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.saffron,
                        fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('The official YCT app is coming soon.\nStay tuned for our launch!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13, height: 1.6)),
                  ])),
                const SizedBox(height: 32),
                Text('తపస్వభ్యో ఉధికో యోగీ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
