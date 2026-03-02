import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(authRepository: ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  AuthController({required AuthRepository authRepository}) : _authRepository = authRepository, super(false);

  void login(BuildContext context, String email, String password) async {
    state = true;
    try {
      await _authRepository.login(email: email, password: password);
      // සාර්ථක නම් Login Screen එක වහනවා
      if (context.mounted) Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      state = false;
    }
  }

  void register(BuildContext context, String email, String password, String name, String role) async {
    state = true;
    try {
      await _authRepository.register(email: email, password: password, name: name, role: role);
      // සාර්ථක නම් Login Screen එක වහනවා
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      state = false;
    }
  }
}