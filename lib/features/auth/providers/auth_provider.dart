import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/mock_auth_service.dart';
import '../../../models/profile.dart';

final authStateProvider = StreamProvider<Profile?>((ref) {
  return MockAuthService.authState;
});

final authLoadingProvider = StateProvider<bool>((ref) => false);

final authErrorProvider = StateProvider<String?>((ref) => null);

final signInProvider = FutureProvider.family<void, Map<String, String>>((ref, credentials) async {
  ref.read(authLoadingProvider.notifier).state = true;
  ref.read(authErrorProvider.notifier).state = null;
  try {
    await MockAuthService.signInWithEmail(
      email: credentials['email']!,
      password: credentials['password']!,
    );
  } catch (e) {
    ref.read(authErrorProvider.notifier).state = e.toString();
    rethrow;
  } finally {
    ref.read(authLoadingProvider.notifier).state = false;
  }
});

final signUpProvider = FutureProvider.family<void, Map<String, String>>((ref, credentials) async {
  ref.read(authLoadingProvider.notifier).state = true;
  ref.read(authErrorProvider.notifier).state = null;
  try {
    await MockAuthService.signUpWithEmail(
      email: credentials['email']!,
      password: credentials['password']!,
    );
  } catch (e) {
    ref.read(authErrorProvider.notifier).state = e.toString();
    rethrow;
  } finally {
    ref.read(authLoadingProvider.notifier).state = false;
  }
});

final signOutProvider = Provider<Future<void> Function()>((ref) {
  return () => MockAuthService.signOut();
});
