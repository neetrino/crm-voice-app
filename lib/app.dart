import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/recorder/presentation/recorder_shell_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final TokenStorage _tokenStorage = TokenStorage();
  late final ApiClient _apiClient = ApiClient(
    tokenStorage: _tokenStorage,
    onUnauthorized: _onSessionExpired,
  );

  bool _bootstrapping = true;
  bool _signedIn = false;
  String? _loginBanner;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final ok = await _tokenStorage.hasAccessToken();
    if (!mounted) return;
    setState(() {
      _signedIn = ok;
      _bootstrapping = false;
    });
  }

  void _onSessionExpired() {
    if (!mounted) return;
    setState(() {
      _signedIn = false;
      _loginBanner = 'Սեսիան ավարտվել է, մուտք գործեք նորից';
    });
  }

  Future<void> _logout() async {
    await _tokenStorage.clear();
    if (!mounted) return;
    setState(() {
      _signedIn = false;
      _loginBanner = null;
    });
  }

  void _onLoggedIn() {
    setState(() {
      _signedIn = true;
      _loginBanner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ձայնագրում',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF252D46),
          primary: const Color(0xFF252D46),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF111111),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF252D46)),
          ),
        ),
      ),
      home: _bootstrapping
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _signedIn
              ? RecorderShellPage(
                  apiClient: _apiClient,
                  onLogout: _logout,
                )
              : LoginPage(
                  apiClient: _apiClient,
                  tokenStorage: _tokenStorage,
                  onLoggedIn: _onLoggedIn,
                  bannerMessage: _loginBanner,
                ),
    );
  }
}
