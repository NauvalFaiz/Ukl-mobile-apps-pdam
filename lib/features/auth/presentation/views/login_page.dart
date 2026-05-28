import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_dashboard.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_event.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_state.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_dashboard.dart';
import 'package:uklmobileapps/shared/widgets/custom-iput.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) return;

    context.read<AuthBloc>().add(
      AuthLoginRequested(username: username, password: password),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => state.role.toUpperCase() == 'ADMIN'
                    ? const AdminDashboard()
                    : const CustomerDashboard(),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Login'),
              CustomInput(
                controller: _usernameController,
                labelText: "Username",
              ),
              SizedBox(height: 10),
              CustomInput(
                controller: _passwordController,
                labelText: "Password",
                isPassword: true,
              ),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}
