import 'package:flutter/material.dart';
import 'package:authentication_repository/authentication_repository.dart';

class App extends StatelessWidget {
  const App({
    required AuthenticationRepository authenticationRepository,
    super.key
    }) : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}