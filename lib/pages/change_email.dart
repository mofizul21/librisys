import 'package:librisys/app/mobile/auth_service.dart';
import 'package:librisys/constants/constants.dart';
import 'package:librisys/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                Lottie.asset("assets/lotties/ChangePassword.json", height: 200),
                const SizedBox(height: 20),
                Text("Change Email", style: KTextStyleTitle.pageTitle),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "New email is required";
                    }
                    if (!value.contains('@')) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "New Email",
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateEmail,
                  child: const Text("Change Email"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateEmail() async {
    if (_formKey.currentState?.validate() == true) {
      try {
        await authService.value.updateEmail(
          newEmail: _emailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        showCustomSnackBar(
          context,
          SnackBarType.success,
          "A verification link has been sent to your new email. Please verify to complete the change.",
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        showCustomSnackBar(
          context,
          SnackBarType.error,
          e.message ?? "An error occurred",
        );
      }
    }
  }
}
