import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/auth_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.apiClient,
    required this.tokenStorage,
    required this.onLoggedIn,
    this.bannerMessage,
  });

  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final VoidCallback onLoggedIn;
  final String? bannerMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthApi _authApi = AuthApi(widget.apiClient);
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final res = await _authApi.login(
        _email.text.trim(),
        _password.text,
      );
      if (res.user.role != 'ADMIN') {
        await widget.tokenStorage.clear();
        if (!mounted) return;
        setState(() {
          _error = 'Միայն ադմինիստրատորը կարող է օգտվել հավելվածից';
          _loading = false;
        });
        return;
      }
      await widget.tokenStorage.saveTokens(
        accessToken: res.tokens.accessToken,
        refreshToken: res.tokens.refreshToken,
      );
      if (!mounted) return;
      widget.onLoggedIn();
    } on ApiException catch (e) {
      setState(() {
        _error =
            e.statusCode == 401 ? 'Սխալ էլ. հասցե կամ գաղտնաբառ' : e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Չհաջողվեց մուտք գործել';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _LoginForm(
                      email: _email,
                      password: _password,
                      loading: _loading,
                      error: _error,
                      bannerMessage: widget.bannerMessage,
                      onSubmit: _submit,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.email,
    required this.password,
    required this.loading,
    required this.error,
    required this.bannerMessage,
    required this.onSubmit,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool loading;
  final String? error;
  final String? bannerMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Մուտք',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Մուտք գործեք ադմինիստրատորի հաշվով',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (bannerMessage != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(bannerMessage!)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        AutofillGroup(
          child: Column(
            children: [
              AppTextField(
                controller: email,
                label: 'Էլ. հասցե',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                enabled: !loading,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: password,
                label: 'Գաղտնաբառ',
                obscure: true,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                enabled: !loading,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        AppButton(
          label: 'Մուտք գործել',
          loading: loading,
          onPressed: loading ? null : onSubmit,
        ),
      ],
    );
  }
}
