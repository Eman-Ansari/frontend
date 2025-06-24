import 'package:authenticationtry/auth_provider.dart';
import 'package:authenticationtry/home_screen.dart';
import 'package:authenticationtry/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthChecker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return user != null ? HomeScreen() : LoginScreen();
  }
}
