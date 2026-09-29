import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/constants/app_strings.dart';
import 'package:pebble_type/core/widgets/app_button.dart';
import 'package:pebble_type/core/widgets/app_text_field.dart';

class PreferencesStep extends StatelessWidget {
  final GlobalKey<FormState> _formKey;
  final String? _selectedGender;
  final ValueChanged<String?> _onGenderChanged;
  final DateTime? _selectedBirthday;
  final ValueChanged<DateTime?> _onBirthdayChanged;
  final bool _newsletterOptIn;
  final ValueChanged<bool?> _onNewsletterChanged;
  final VoidCallback _onNext;
  final bool _isLoading;
  const PreferencesStep({
    super.key,
    required GlobalKey<FormState> formKey,
    required String? selectedGender,
    required ValueChanged<String?> onGenderChanged,
    required DateTime? selectedBirthday,
    required ValueChanged<DateTime?> onBirthdayChanged,
    required bool newsletterOptIn,
    required ValueChanged<bool?> onNewsletterChanged,
    required VoidCallback onNext,
    required bool isLoading,
  }) : _formKey = formKey,
       _selectedGender = selectedGender,
       _onGenderChanged = onGenderChanged,
       _selectedBirthday = selectedBirthday,
       _onBirthdayChanged = onBirthdayChanged,
       _newsletterOptIn = newsletterOptIn,
       _onNewsletterChanged = onNewsletterChanged,
       _onNext = onNext,
       _isLoading = isLoading;

  String _formatDate(DateTime? data) {
    if (data == null) return '';
    return '${data.day} / ${data.month} / ${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step title------------------------------------------------
          Text(
            AppStrings.step3Title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppDimensions.spacingXm),
          Text(
            AppStrings.step3Subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppDimensions.spacingLg),
          // Gender------------------------------------------------
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: InputDecoration(
              labelText: AppStrings.genderLabel,
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            items: [
              'Prefer not to say',
              'Male',
              'Female',
            ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: _onGenderChanged,
          ),
          SizedBox(height: AppDimensions.spacingMd),

          // Birthday------------------------------------------------
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(1995, 1, 1),
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                _onBirthdayChanged(picked);
              }
            },
            child: AbsorbPointer(
              child: AppTextField(
                label: AppStrings.birthdayLabel,
                controller: TextEditingController(
                  text: _formatDate(_selectedBirthday),
                ),
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spacingMd),
          // newsletter opt-in------------------------------------------------
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),

            child: SwitchListTile(
              value: _newsletterOptIn,
              onChanged: _onNewsletterChanged,
              title: Text(
                AppStrings.newsletterTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                AppStrings.newsletterSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingXm,
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spacingXl),
          // create account button------------------------------------------------
          AppButton(
            label: AppStrings.createAccount,
            isLoading: _isLoading,
            onPressed: _onNext,
          ),
        ],
      ),
    );
  }
}
