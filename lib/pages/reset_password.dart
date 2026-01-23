import 'package:librisys/app/mobile/auth_service.dart';
import 'package:librisys/constants/constants.dart';
import 'package:librisys/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

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
                Text("Reset Password", style: KTextStyleTitle.pageTitle),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Current password is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Current Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "New password is required";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "New Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text("Reset Password"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword() async {
    if (_formKey.currentState?.validate() == true) {
      final user = authService.value.currentUser;
      if (user == null) {
        showCustomSnackBar(
          context,
          SnackBarType.error,
          "You need to be logged in to reset your password.",
        );
        return;
      }

      try {
        await authService.value.resetPasswordFromCurrentPassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          email: user.email!,
        );
        if (!mounted) return;
        showCustomSnackBar(
          context,
          SnackBarType.success,
          "Password has been reset successfully.",
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
