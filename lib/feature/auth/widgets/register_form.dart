import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/widgets/step_progress_bar.dart';
import 'package:pebble_type/feature/auth/widgets/personal_details_step.dart';
import 'package:pebble_type/feature/auth/widgets/preferences_step.dart';
import 'package:pebble_type/feature/auth/widgets/shipping_address_step.dart'
    show ShippingAddressStep;

class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController _firstNameCtrl;
  final TextEditingController _lastNameCtrl;
  final TextEditingController _emailCtrl;
  final TextEditingController _passwordCtrl;
  final TextEditingController _phoneCtrl;
  final bool _termsAccepted;
  final ValueChanged<bool?> _onTermsChanged;
  final VoidCallback _onNext;
  final VoidCallback _onBack;
  final int _currentStep;
  final TextEditingController _addressCtrl;
  final TextEditingController _address2Ctrl;
  final TextEditingController _cityCtrl;
  final TextEditingController _stateCtrl;
  final TextEditingController _zipCtrl;
  final String _selectedCountry;
  final ValueChanged<String?> _onCountryChanged;
  final String? _selectedGender;
  final DateTime? _selectedBirthday;
  final bool _newsletterOptIn;
  final bool _isLoading;
  final ValueChanged<String?> _onGenderChanged;
  final ValueChanged<DateTime?> _onBirthdayChanged;
  final ValueChanged<bool?> _onNewsletterChanged;

  const RegisterForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController firstNameCtrl,
    required TextEditingController lastNameCtrl,
    required TextEditingController emailCtrl,
    required TextEditingController passwordCtrl,
    required TextEditingController phoneCtrl,
    required TextEditingController addressCtrl,
    required TextEditingController address2Ctrl,
    required TextEditingController cityCtrl,
    required TextEditingController stateCtrl,
    required TextEditingController zipCtrl,
    required String selectedCountry,
    required ValueChanged<String?> onCountryChanged,
    required ValueChanged<bool?> onTermsChanged,
    required bool termsAccepted,
    required VoidCallback onNext,
    required VoidCallback onBack,
    required int currentStep,
    required String? selectedGender,
    required DateTime? selectedBirthday,
    required bool newsletterOptIn,
    required bool isLoading,
    required ValueChanged<String?> onGenderChanged,
    required ValueChanged<DateTime?> onBirthdayChanged,
    required ValueChanged<bool?> onNewsletterChanged,
  }) : _formKey = formKey,
       _firstNameCtrl = firstNameCtrl,
       _lastNameCtrl = lastNameCtrl,
       _emailCtrl = emailCtrl,
       _passwordCtrl = passwordCtrl,
       _phoneCtrl = phoneCtrl,
       _onTermsChanged = onTermsChanged,
       _termsAccepted = termsAccepted,
       _onNext = onNext,
       _onBack = onBack,
       _currentStep = currentStep,
       _addressCtrl = addressCtrl,
       _address2Ctrl = address2Ctrl,
       _cityCtrl = cityCtrl,
       _stateCtrl = stateCtrl,
       _zipCtrl = zipCtrl,
       _selectedCountry = selectedCountry,
       _selectedGender = selectedGender,
       _selectedBirthday = selectedBirthday,
       _newsletterOptIn = newsletterOptIn,
       _onGenderChanged = onGenderChanged,
       _onBirthdayChanged = onBirthdayChanged,
       _onNewsletterChanged = onNewsletterChanged,
       _isLoading = isLoading,
       _onCountryChanged = onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //back button and progress indicator-----------------------------------------------
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              style: IconButton.styleFrom(
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(
                    AppDimensions.radiusSm,
                  ),
                ),
                fixedSize: Size(36, 36),
              ),
              onPressed: _onBack,
              icon: Icon(Icons.arrow_back_ios_new_rounded),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StepProgressBar(totalSteps: 3, currentStep: _currentStep),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingLg),

        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: switch (_currentStep) {
            1 => PersonalDetailsStep(
              key: ValueKey(1),
              formKey: _formKey,
              firstNameCtrl: _firstNameCtrl,
              lastNameCtrl: _lastNameCtrl,
              emailCtrl: _emailCtrl,
              passwordCtrl: _passwordCtrl,
              phoneCtrl: _phoneCtrl,
              termsAccepted: _termsAccepted,
              onTermsChanged: _onTermsChanged,
              onNext: _onNext,
            ),
            2 => ShippingAddressStep(
              key: ValueKey(2),
              formKey: _formKey,
              addressCtrl: _addressCtrl,
              address2Ctrl: _address2Ctrl,
              cityCtrl: _cityCtrl,
              stateCtrl: _stateCtrl,
              zipCtrl: _zipCtrl,
              selectedCountry: _selectedCountry,
              onCountryChanged: _onCountryChanged,
              onBack: _onBack,
              onNext: _onNext,
            ),
            3 => PreferencesStep(
              key: ValueKey(3),
              formKey: _formKey,
              selectedGender: _selectedGender,
              onGenderChanged: _onGenderChanged,
              selectedBirthday: _selectedBirthday,
              onBirthdayChanged: _onBirthdayChanged,
              newsletterOptIn: _newsletterOptIn,
              onNewsletterChanged: _onNewsletterChanged,
              onNext: _onNext,
              isLoading: _isLoading,
            ),
            _ => SizedBox.shrink(key: ValueKey(_currentStep)),
          },
        ),
      ],
    );
  }
}
