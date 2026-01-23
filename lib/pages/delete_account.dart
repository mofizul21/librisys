import 'package:librisys/app/mobile/auth_service.dart';
import 'package:librisys/app/mobile/auth_wrapper.dart';
import 'package:librisys/constants/constants.dart';
import 'package:librisys/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
                Lottie.asset("assets/lotties/TrashBin.json", height: 200),
                const SizedBox(height: 20),
                Text("Delete Account", style: KTextStyleTitle.pageTitle),
                const SizedBox(height: 20),
                Text(
                  "This action is irreversible. Please enter your password to confirm.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
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
                  onPressed: _deleteAccount,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteAccount() async {
    if (_formKey.currentState?.validate() == true) {
      final user = authService.value.currentUser;
      if (user == null || user.email == null) {
        showCustomSnackBar(
          context,
          SnackBarType.error,
          "You need to be logged in to delete your account.",
        );
        return;
      }

      try {
        await authService.value.deleteAccount(
          email: user.email!,
          password: _passwordController.text,
        );
        if (!mounted) return;
        showCustomSnackBar(
          context,
          SnackBarType.success,
          "Account deleted successfully.",
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
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
