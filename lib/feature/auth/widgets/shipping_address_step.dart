import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/constants/app_strings.dart';
import 'package:pebble_type/core/widgets/app_button.dart';
import 'package:pebble_type/core/widgets/app_text_field.dart';

class ShippingAddressStep extends StatelessWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController _addressCtrl;
  final TextEditingController _address2Ctrl;
  final TextEditingController _cityCtrl;
  final TextEditingController _stateCtrl;
  final TextEditingController _zipCtrl;
  final String _selectedCountry;
  final ValueChanged<String?> _onCountryChanged;
  final VoidCallback _onNext;
  const ShippingAddressStep({
    super.key,
    required GlobalKey<FormState> formKey,
    required TextEditingController addressCtrl,
    required TextEditingController address2Ctrl,
    required TextEditingController cityCtrl,
    required TextEditingController stateCtrl,
    required TextEditingController zipCtrl,
    required String selectedCountry,
    required ValueChanged<String?> onCountryChanged,
    required VoidCallback onBack,
    required VoidCallback onNext,
  }) : _formKey = formKey,
       _addressCtrl = addressCtrl,
       _address2Ctrl = address2Ctrl,
       _cityCtrl = cityCtrl,
       _stateCtrl = stateCtrl,
       _zipCtrl = zipCtrl,
       _selectedCountry = selectedCountry,
       _onCountryChanged = onCountryChanged,
       _onNext = onNext;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step title------------------------------------------------
          Text(
            AppStrings.step2Title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppDimensions.spacingXm),
          Text(
            AppStrings.step2Subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppDimensions.spacingLg),
          //country dropdown------------------------------------------------
          DropdownButtonFormField<String>(
            items: [
              'United States',
              'Canada',
              'United Kingdom',
              'Australia',
              'Germany',
              'France',
              'Pakistan',
              'India',
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            initialValue: _selectedCountry,
            onChanged: _onCountryChanged,
            decoration: InputDecoration(
              labelText: AppStrings.countryLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spacingSm),
          //address line 1------------------------------------------------
          AppTextField(
            label: AppStrings.addressLine1Label,
            prefixIcon: Icon(Icons.home_outlined),
            controller: _addressCtrl,
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
          ),
          SizedBox(height: AppDimensions.spacingSm),
          //address line 2------------------------------------------------
          AppTextField(
            label: AppStrings.addressLine2Label,
            prefixIcon: Icon(Icons.home_outlined),
            controller: _address2Ctrl,
          ),
          SizedBox(height: AppDimensions.spacingSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AppTextField(
                  label: AppStrings.cityLabel,
                  controller: _cityCtrl,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppTextField(
                  label: AppStrings.zipLabel,
                  controller: _zipCtrl,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacingSm),
          //state/province------------------------------------------------
          AppTextField(
            label: AppStrings.stateLabel,
            prefixIcon: Icon(Icons.map_outlined),
            controller: _stateCtrl,
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
          ),
          SizedBox(height: AppDimensions.spacingMd),
          AppButton(label: 'Next →', onPressed: _onNext),
          SizedBox(height: AppDimensions.spacingSm),
        ],
      ),
    );
  }
}
