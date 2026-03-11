import 'package:flutter/material.dart';

class AuthRoutes {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String resetPassword = '/auth/reset-password';

  static Map<String, Widget Function(BuildContext)> get routes => {
    login: (context) => throw UnimplementedError('Login screen not implemented'),
    register: (context) => throw UnimplementedError('Register screen not implemented'),
    resetPassword: (context) => throw UnimplementedError('Reset password screen not implemented'),
  };
}
