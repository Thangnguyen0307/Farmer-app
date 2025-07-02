import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final fullName = user?.fullName ?? 'Người dùng';

    return Text(
      'Xin chào, $fullName',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
