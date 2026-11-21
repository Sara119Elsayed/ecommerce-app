import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/cubit/auth_cubit.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/webservices/auth_service.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../../../shop/presentation/screens/shop_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AuthRepository _repository;
  late final AuthCubit _cubit;

  @override
  void initState() {
    super.initState();
    _repository = DummyJsonAuthRepository(AuthService());
    _cubit = AuthCubit(_repository);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _login() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _cubit.login(
      email: _usernameController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthSuccess || current is AuthFailure,
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ShopScreen()),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wideLayout = constraints.maxWidth >= 850;
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: wideLayout ? 40 : 24,
                          vertical: wideLayout ? 40 : 32,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1080),
                            child: wideLayout
                                ? Row(
                                    children: [
                                      const Expanded(
                                        child: AuthBrandPanel(),
                                      ),
                                      const SizedBox(width: 56),
                                      SizedBox(
                                        width: 420,
                                        child: _buildLoginCard(
                                          context,
                                          loading,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const AuthBrandPanel(compact: true),
                                      const SizedBox(height: 32),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 460,
                                        ),
                                        child: _buildLoginCard(
                                          context,
                                          loading,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool loading) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECE9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3029).withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back',
              style: textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF1E3029),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in with your account to continue.',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF68766F),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            AuthTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Enter your username',
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enabled: !loading,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              obscureText: _obscurePassword,
              enabled: !loading,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your password'
                  : null,
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: loading
                    ? null
                    : () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AuthSubmitButton(
              loading: loading,
              onPressed: loading ? null : _login,
            ),
            const SizedBox(height: 20),
            Text(
              'Your everyday essentials are just a sign in away.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7A857F),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
