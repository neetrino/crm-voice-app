import 'auth_tokens.dart';
import 'user_model.dart';

class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.tokens,
  });

  final UserModel user;
  final AuthTokens tokens;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    final tokensMap = json['tokens'] as Map<String, dynamic>? ?? {};
    return AuthResponse(
      user: UserModel.fromJson(userMap),
      tokens: AuthTokens.fromJson(tokensMap),
    );
  }
}
