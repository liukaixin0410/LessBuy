import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/home/pages/home_page.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: '断舍离消费助手',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: authState.maybeWhen(
        data: (user) => user != null ? const HomePage() : const LoginPage(),
        orElse: () => const LoginPage(),
      ),
    );
  }
}
