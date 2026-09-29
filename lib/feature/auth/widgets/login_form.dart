import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_assets.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/constants/app_strings.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/core/widgets/app_button.dart';
import 'package:pebble_type/core/widgets/app_text_field.dart';
import 'package:pebble_type/core/widgets/string_link_button.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogInPressed;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required GlobalKey<FormState> formKey,
    required this.onLogInPressed,
    required this.isLoading,
  }) : _formKey = formKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDimensions.spacingLg),
        //app logo-----------------------------------------------------
        Hero(
          tag: 'app-logo',
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: SvgPicture.asset(AppAssets.appLogo),
          ),
        ),
        SizedBox(height: AppDimensions.spacingSm),
        Column(
          children: [
            //welcome text------------------------------------------------
            Text(
              AppStrings.welcomeBack,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppDimensions.spacingXm),
            Text(
              AppStrings.signInSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        //login form------------------------------------------------
        SizedBox(height: AppDimensions.spacingMd),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //email fields---------------------------------------
              Text(AppStrings.emailLabel, style: AppTextStyles.bodyLg),
              SizedBox(height: AppDimensions.spacingSm),
              AppTextField(
                label: AppStrings.emailHint,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                  ).hasMatch(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              //password field---------------------------------------
              SizedBox(height: AppDimensions.spacingSm),
              Text(AppStrings.passwordLabel, style: AppTextStyles.bodyLg),
              SizedBox(height: AppDimensions.spacingSm),
              AppTextField(
                label: AppStrings.passwordHint,
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingSm),
              StringLinkButton(
                alignment: Alignment.centerRight,
                onPressed: () => context.push(AppRoutes.forgotPassword),
                label: AppStrings.forgotPassword,
              ),
              //login button----------------------------------------------------
              AppButton(
                label: AppStrings.signInButton,
                isLoading: isLoading,
                onPressed: onLogInPressed,
              ),
              SizedBox(height: AppDimensions.spacingMd),
              //sign up link------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.dontHaveAccount),
                  StringLinkButton(
                    alignment: Alignment.center,
                    onPressed: () {
                      context.go(AppRoutes.register);
                    },
                    label: AppStrings.signUp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
