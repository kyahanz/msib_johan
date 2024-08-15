import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msib_johan/core/provider/data_provider.dart';
import 'register_page.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            authState.maybeWhen(
              loading: () => const CircularProgressIndicator(),
              orElse: () => ElevatedButton(
                onPressed: () {
                  ref.watch(authProvider.notifier).login(
                        context,
                        emailController.text,
                        passwordController.text,
                      );
                },
                child: const Text("Login"),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text("Register"),
            ),
            const SizedBox(height: 20),
            authState.when(
              data: (user) {
                if (user != null) {
                  return Text("Welcome, ${user.name} {$globalToken}");
                }
                return Container();
              },
              error: (error, _) => Text("Error: $error"),
              loading: () => Container(),
            ),
          ],
        ),
      ),
    );
  }
}
