import 'dart:async';
import '../models/profile.dart';

class MockAuthService {
  static Profile? _currentUser;
  static final StreamController<Profile?> _controller = StreamController.broadcast();

  static bool get isAuthenticated => _currentUser != null;
  static Profile? get currentUser => _currentUser;

  static Stream<Profile?> get authState async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  static Future<Profile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = Profile(
      id: 'mock-user-id',
      email: email,
      createdAt: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  static Future<Profile> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = Profile(
      id: 'mock-user-id',
      email: email,
      createdAt: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  static Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  static Future<Profile?> getProfile() async {
    return _currentUser;
  }
}
