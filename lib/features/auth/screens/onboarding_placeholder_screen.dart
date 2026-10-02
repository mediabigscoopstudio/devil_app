import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_provider.dart';

class OnboardingPlaceholderScreen extends StatelessWidget {
  const OnboardingPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Stage 2 Onboarding', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Onboarding',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              'Stage 2 onboarding will be implemented here.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
              },
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}
