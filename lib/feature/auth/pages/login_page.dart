import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/auth_service.dart';
import 'package:pebble_type/feature/auth/widgets/login_form.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/wishlist/providers/wishlist_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    try {
      setState(() {
        _isLoading = true;
      });
      if (_formKey.currentState?.validate() ?? false) {
        await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        ref.invalidate(cartProvider);
        ref.invalidate(wishlistProvider);
        if (mounted) {
          final destination = safeReturnPath(
            GoRouterState.of(context).uri.queryParameters['from'],
          );
          if (destination != null) {
            context.go(destination);
          } else if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.dashboard);
          }
        }
      }
    } on DioException catch (e) {
      final message = AuthService.errorMessage(
        e,
        fallback: 'Login failed. Please try again.',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 8,
          ),
          child: LoginForm(
            emailController: _emailController,
            passwordController: _passwordController,
            onLogInPressed: _handleLogin,
            isLoading: _isLoading,
            formKey: _formKey,
          ),
        ),
      ),
    );
  }
}
