import 'package:librisys/app/mobile/auth_service.dart';
import 'package:librisys/constants/constants.dart';
import 'package:librisys/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ForgottenPassword extends StatefulWidget {
  const ForgottenPassword({super.key});

  @override
  State<ForgottenPassword> createState() => _ForgottenPasswordState();
}

class _ForgottenPasswordState extends State<ForgottenPassword> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              Lottie.asset("assets/lotties/ForgotPassword.json", height: 200),
              const SizedBox(height: 20),
              Text("Forgot Password", style: KTextStyleTitle.pageTitle),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Account Email",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty) {
                    showCustomSnackBar(
                      context,
                      SnackBarType.warning,
                      "Please enter your email address.",
                    );
                    return;
                  }
                  try {
                    await authService.value.sendPasswordResetEmail(email);
                    if (!mounted) return;
                    showCustomSnackBar(
                      context,
                      SnackBarType.success,
                      "If your account exists, a password reset link has been sent to your email.",
                    );
                    Navigator.of(context).pop();
                  } on FirebaseAuthException catch (e) {
                    showCustomSnackBar(
                      context,
                      SnackBarType.error,
                      "Failed to send reset email: ${e.message}",
                    );
                  } catch (e) {
                    showCustomSnackBar(
                      context,
                      SnackBarType.error,
                      "An unexpected error occurred: $e",
                    );
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
