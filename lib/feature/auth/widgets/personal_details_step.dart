import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_assets.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/constants/app_strings.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/widgets/app_button.dart';
import 'package:pebble_type/core/widgets/app_text_field.dart';
import 'package:pebble_type/core/widgets/password_strength.dart';
import 'package:pebble_type/core/widgets/phone_field.dart';
import 'package:pebble_type/core/widgets/social_button.dart';
import 'package:pebble_type/core/widgets/string_link_button.dart';
import 'package:pebble_type/core/widgets/terms_checkbox.dart';

class PersonalDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController _firstNameCtrl;
  final TextEditingController _lastNameCtrl;
  final TextEditingController _emailCtrl;
  final TextEditingController _passwordCtrl;
  final TextEditingController _phoneCtrl;
  final bool _termsAccepted;
  final ValueChanged<bool?> _onTermsChanged;
  final VoidCallback _onNext;
  const PersonalDetailsStep({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController firstNameCtrl,
    required TextEditingController lastNameCtrl,
    required TextEditingController emailCtrl,
    required TextEditingController passwordCtrl,
    required TextEditingController phoneCtrl,
    required bool termsAccepted,
    required ValueChanged<bool?> onTermsChanged,
    required VoidCallback onNext,
  }) : _formKey = formKey,
       _firstNameCtrl = firstNameCtrl,
       _lastNameCtrl = lastNameCtrl,
       _emailCtrl = emailCtrl,
       _passwordCtrl = passwordCtrl,
       _phoneCtrl = phoneCtrl,
       _termsAccepted = termsAccepted,
       _onTermsChanged = onTermsChanged,
       _onNext = onNext;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //title and subtitle------------------------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.createAccount,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: AppDimensions.spacingXm),
              Text(
                AppStrings.step1Subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          //first name and last name fields---------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: AppStrings.firstNameLabel,
                  prefixIcon: Icon(Icons.person_outline),
                  controller: _firstNameCtrl,
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Required' : null,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: AppStrings.lastNameLabel,
                  prefixIcon: Icon(Icons.person_outline),
                  controller: _lastNameCtrl,
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingSm),
          //email field---------------------------------------
          AppTextField(
            label: AppStrings.emailHint,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: [AutofillHints.email],
            prefixIcon: Icon(Icons.email_outlined),
            validator: (value) =>
                value!.trim().contains('@') ? null : 'Invalid email',
          ),

          SizedBox(height: AppDimensions.spacingSm),
          //phone field---------------------------------------
          PhoneField(controller: _phoneCtrl),
          SizedBox(height: AppDimensions.spacingSm),
          //password field---------------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: AppStrings.passwordHint,
                controller: _passwordCtrl,
                obscureText: true,
                prefixIcon: Icon(Icons.lock_outline),
                validator: (value) => value!.length >= 6
                    ? null
                    : 'Password must be at least 6 characters',
              ),
              SizedBox(height: 8),
              PasswordStrength(passwordController: _passwordCtrl),
            ],
          ),
          TermsCheckbox(value: _termsAccepted, onChanged: _onTermsChanged),
          SizedBox(height: AppDimensions.spacingMd),
          //next button----------------------------------------------------
          AppButton(label: 'Next →', onPressed: _onNext),
          SizedBox(height: AppDimensions.spacingMd),
          //divider with text------------------------------------------------
          Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(AppStrings.orSignUp),
              ),
              Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: AppDimensions.spacingMd),
          //social login buttons------------------------------------------------
          Row(
            children: [
              SocialButton(label: 'Google', iconAsset: AppAssets.googleLogo),
              SizedBox(width: 3),
              SocialButton(label: 'Apple', iconAsset: AppAssets.appleLogo),
              SizedBox(width: 3),
              SocialButton(
                label: 'Facebook',
                iconAsset: AppAssets.facebookLogo,
              ),
            ],
          ),
          //already have an account link------------------------------------------------
          SizedBox(height: AppDimensions.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.alreadyHaveAcc),
              StringLinkButton(
                alignment: Alignment.center,
                label: 'Sign In',
                onPressed: () {
                  context.go(AppRoutes.login);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
