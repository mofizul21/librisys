import 'package:librisys/app/mobile/auth_service.dart';
import 'package:librisys/app/mobile/auth_wrapper.dart';
import 'package:librisys/constants/constants.dart';
import 'package:librisys/pages/change_email.dart';
import 'package:librisys/pages/delete_account.dart';
import 'package:librisys/pages/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Lottie.asset(
              "assets/lotties/Welcome.json",
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Welcome, ${authService.value.currentUser?.email ?? 'User'}",
                softWrap: true,
                textAlign: TextAlign.center,
                style: KTextStyleTitle.pageTitle,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text("Change email"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ChangeEmail();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Reset password"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ResetPassword();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Delete account"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const DeleteAccount();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Logout"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                await authService.value.signOut();
                selectedPageNotifier.value = 0;
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const AuthWrapper();
                    },
                  ),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
