
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AuthState {
  final String? token;
  final Map<String, dynamic>? user;

  AuthState({this.token, this.user});

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({String? token, Map<String, dynamic>? user}) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<void> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);
      final token = response['access_token'];
      final user = await _authService.fetchCurrentUser(token);
      state = AuthState(token: token, user: user);
    } catch (e) {
      print('Login failed: $e');
      state = AuthState(); // Clear state on failure
      rethrow;
    }
  }

  Future<void> register(String username, String password, String email, String fullName) async {
    try {
      await _authService.register(username, password, email, fullName);
      // After successful registration, automatically log in the user
      await login(username, password);
    } catch (e) {
      print('Registration failed: $e');
      state = AuthState(); // Clear state on failure
      rethrow;
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
