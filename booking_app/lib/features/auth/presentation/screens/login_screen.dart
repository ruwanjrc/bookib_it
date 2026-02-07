import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

final authModeProvider = StateProvider<bool>((ref) => true);
final userRoleProvider = StateProvider<String>((ref) => 'customer');

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = ref.watch(authModeProvider);
    final userRole = ref.watch(userRoleProvider);
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(isLogin ? "Login" : "Register", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (!isLogin) ...[
              CustomTextField(hintText: "Name", prefixIcon: Icons.person, controller: nameController),
              const SizedBox(height: 10),
              Row(
                children: [
                  _roleBtn('customer', 'Customer', userRole == 'customer'),
                  const SizedBox(width: 10),
                  _roleBtn('vendor', 'Business', userRole == 'vendor'),
                ],
              ),
            ],
            CustomTextField(hintText: "Email", prefixIcon: Icons.email, controller: emailController),
            CustomTextField(hintText: "Password", prefixIcon: Icons.lock, isPassword: true, controller: passwordController),
            const SizedBox(height: 30),
            PrimaryButton(
              text: isLogin ? "Sign In" : "Sign Up",
              isLoading: isLoading,
              onPressed: () {
                if (isLogin) {
                  ref.read(authControllerProvider.notifier).login(context, emailController.text.trim(), passwordController.text.trim());
                } else {
                  ref.read(authControllerProvider.notifier).register(context, emailController.text.trim(), passwordController.text.trim(), nameController.text.trim(), userRole);
                }
              },
            ),
            TextButton(
              onPressed: () => ref.read(authModeProvider.notifier).state = !isLogin,
              child: Text(isLogin ? "Create Account" : "Back to Login"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBtn(String role, String label, bool isSelected) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: isSelected ? AppColors.primary : Colors.grey[200]),
        onPressed: () => ref.read(userRoleProvider.notifier).state = role,
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      ),
    );
  }
}