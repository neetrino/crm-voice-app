import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/recorder/presentation/record_page.dart';

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
      _loginBanner = 'Your session has expired. Please sign in again.';
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
      title: 'crm-voice-app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: _bootstrapping
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _signedIn
              ? RecordPage(
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
