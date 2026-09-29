import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/services/auth_service.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/feature/profile/models/user_model.dart';
import 'package:pebble_type/feature/profile/providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _address1Ctrl;
  late final TextEditingController _address2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _zipCtrl;
  late final TextEditingController _countryCtrl;

  bool _loading = false;
  bool _initialized = false;

  void _init(UserModel user) {
    if (_initialized) return;
    _firstNameCtrl = TextEditingController(text: user.firstName);
    _lastNameCtrl = TextEditingController(text: user.lastName);
    _phoneCtrl = TextEditingController(text: user.phone);
    _genderCtrl = TextEditingController(text: user.gender);
    _address1Ctrl = TextEditingController(text: user.addressLine1);
    _address2Ctrl = TextEditingController(text: user.addressLine2);
    _cityCtrl = TextEditingController(text: user.city);
    _stateCtrl = TextEditingController(text: user.state);
    _zipCtrl = TextEditingController(text: user.zipCode);
    _countryCtrl = TextEditingController(text: user.country);
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _firstNameCtrl.dispose();
      _lastNameCtrl.dispose();
      _phoneCtrl.dispose();
      _genderCtrl.dispose();
      _address1Ctrl.dispose();
      _address2Ctrl.dispose();
      _cityCtrl.dispose();
      _stateCtrl.dispose();
      _zipCtrl.dispose();
      _countryCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        gender: _genderCtrl.text.trim(),
        addressLine1: _address1Ctrl.text.trim(),
        addressLine2: _address2Ctrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        zipCode: _zipCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
      );
      await ref.read(profileProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
        context.pop();
      }
    } catch (e) {
      String message = 'Failed to update profile.';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) message = data.values.first.toString();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (user) {
          _init(user);
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.radiusMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('Personal'),
                  const SizedBox(height: AppDimensions.spacingMd),
                  _Field(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    validator: _required,
                  ),
                  _Field(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    validator: _required,
                  ),
                  _Field(
                    controller: _phoneCtrl,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                  ),
                  _Field(controller: _genderCtrl, label: 'Gender'),
                  const SizedBox(height: AppDimensions.spacingMd),
                  _Label('Shipping Address'),
                  const SizedBox(height: AppDimensions.spacingMd),
                  _Field(controller: _address1Ctrl, label: 'Address Line 1'),
                  _Field(
                    controller: _address2Ctrl,
                    label: 'Address Line 2 (optional)',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(controller: _cityCtrl, label: 'City'),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: _Field(controller: _stateCtrl, label: 'State'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _zipCtrl,
                          label: 'Zip Code',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: _Field(
                          controller: _countryCtrl,
                          label: 'Country',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: AppDimensions.spacingSm),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: AppTextStyles.bodyMd,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingMd,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
