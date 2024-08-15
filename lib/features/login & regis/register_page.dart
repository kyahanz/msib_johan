import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/provider/data_provider.dart';

class RegisterScreen extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
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
                  ref.watch(authProvider.notifier).register(
                        context,
                        nameController.text,
                        emailController.text,
                        passwordController.text,
                      );
                },
                child: const Text("Register"),
              ),
            ),
            authState.when(
              data: (user) {
                if (user != null) {
                  return Text("");
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
